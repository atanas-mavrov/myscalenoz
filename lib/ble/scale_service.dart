import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_config.dart';
import 'scale_parser.dart';

enum ScalePhase {
  preparing,
  scanning,
  connecting,
  waiting,
  weighing,
  done,
  failed,
}

enum ScaleError {
  unsupported,
  bluetoothOff,
  permissionDenied,
  notFound,
  connectFailed,
  serviceMissing,
  noData,
}

class ScaleException implements Exception {
  const ScaleException(this.error);
  final ScaleError error;
}

/// A raw reading as delivered by the scale; r50 == 0 means weight only.
class RawReading {
  const RawReading({
    required this.weightKg,
    required this.r50,
    required this.r500,
    this.scaleTime,
  });

  final double weightKg;
  final int r50;
  final int r500;
  final DateTime? scaleTime;
}

class ScaleStatus {
  const ScaleStatus(this.phase, {this.liveKg, this.error});
  final ScalePhase phase;
  final double? liveKg;
  final ScaleError? error;
}

final _ble = FlutterReactiveBle();

/// Implemented in android/.../MainActivity.kt.
const _bluetoothChannel = MethodChannel('app.smallapps.myscalenoz/bluetooth');

/// Requests the runtime permissions BLE needs; true if scanning can proceed.
Future<bool> ensureBlePermissions() async {
  final res = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    // Only declared (and only needed) up to Android 11; ignored above that.
    Permission.locationWhenInUse,
  ].request();
  return res[Permission.bluetoothScan]!.isGranted &&
      res[Permission.bluetoothConnect]!.isGranted;
}

/// Usable for scanning and connecting. Location services are irrelevant: the
/// app declares that it never derives location from scans.
bool _usable(BleStatus s) =>
    s == BleStatus.ready || s == BleStatus.locationServicesDisabled;

Future<BleStatus> _settledStatus(Duration timeout) => _ble.statusStream
    .where((s) => s != BleStatus.unknown)
    .first
    .timeout(timeout, onTimeout: () => BleStatus.unknown);

/// Makes sure Bluetooth is on; returns false if it can't be.
///
/// If Bluetooth is off, Android's own "turn on Bluetooth?" dialog is shown;
/// apps can't switch it on silently since Android 13, nor switch it off.
Future<bool> ensureBluetoothOn() async {
  final status = await _settledStatus(const Duration(seconds: 5));
  debugPrint('scale: ble status $status');
  if (_usable(status)) return true;
  if (status != BleStatus.poweredOff || !Platform.isAndroid) return false;
  try {
    final accepted =
        await _bluetoothChannel.invokeMethod<bool>('requestEnable') ?? false;
    if (!accepted) return false;
  } on PlatformException catch (e) {
    debugPrint('scale: bluetooth not turned on: $e');
    return false;
  }
  return _ble.statusStream
      .firstWhere(_usable)
      .then((_) => true)
      .timeout(const Duration(seconds: 10), onTimeout: () => false);
}

bool _isScale(DiscoveredDevice d) => d.name == AppConfig.scaleName;

/// Scans for scales for [timeout]; emits each distinct device once.
Stream<DiscoveredDevice> scanForScales({
  Duration timeout = const Duration(seconds: 15),
}) {
  final seen = <String>{};
  return _ble
      .scanForDevices(
        withServices: const [],
        requireLocationServicesEnabled: false,
      )
      .where((d) => _isScale(d) && seen.add(d.id))
      .timeout(timeout, onTimeout: (sink) => sink.close());
}

/// One connection to the scale. The scale stays silent unless the vendor
/// SDK's session startup is reproduced (see RESEARCH.md): set its clock and
/// open the non-persistent *visitor* session. No user is registered and no
/// profile is written; body composition is computed on the phone.
///
/// Live mode ([sync] == false) waits for the user to step on and finishes
/// after the first stabilised reading. Sync mode collects every record the
/// scale delivers (e.g. buffered offline ones) until it goes quiet.
class ScaleSession {
  ScaleSession({required this.sync, this.deviceIds = const [], this.onReading});

  final bool sync;

  /// Saved scales to look for (the first one found wins); any
  /// [AppConfig.scaleName] if empty.
  final List<String> deviceIds;

  /// Called the moment a reading is complete (the user may step off).
  final void Function()? onReading;

  static final _weightUuid = Uuid.parse('2A9D');
  static final _bodyUuid = Uuid.parse('2A9C');
  static final _timeUuid = Uuid.parse('2A2B');
  static final _userControlUuid = Uuid.parse('2A9F');
  static final _vendorNotifyUuid = Uuid.parse('FFE1');

  /// User Control Point "consent" for the SDK's visitor: index 0xAA, key 9999.
  static const _visitorConsent = [0x02, 0xAA, 0x0F, 0x27];

  static const _scanTimeout = Duration(seconds: 30);
  static const _connectAttempts = 4;
  static const _stepOnTimeout = Duration(seconds: 90);
  static const _bodyFrameTimeout = Duration(seconds: 10);
  static const _syncIdleTimeout = Duration(seconds: 8);

  /// Lets enabled notifications/indications take effect before the writes
  /// that depend on them (the plugin gives no completion signal for them).
  static const _subscribeSettle = Duration(milliseconds: 400);

  final _status = StreamController<ScaleStatus>.broadcast();
  Stream<ScaleStatus> get status => _status.stream;

  final _readings = <RawReading>[];
  final _assembler = BodyFrameAssembler();
  final _subs = <StreamSubscription<Object?>>[];
  final _finished = Completer<void>();
  StreamSubscription<ConnectionStateUpdate>? _connection;
  Completer<String?>? _scanResult;
  Timer? _timer;
  WeightReading? _pendingFinal;
  double? _lastLiveKg;
  bool _cancelled = false;

  void _emit(ScalePhase phase, {double? liveKg, ScaleError? error}) {
    if (!_status.isClosed) {
      _status.add(ScaleStatus(phase, liveKg: liveKg, error: error));
    }
  }

  void _finish() {
    if (!_finished.isCompleted) _finished.complete();
  }

  void _arm(Duration d, void Function() onTimeout) {
    _timer?.cancel();
    _timer = Timer(d, onTimeout);
  }

  Future<void> _disconnect() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    // Cancelling the connection stream is how the plugin disconnects.
    await _connection?.cancel();
    _connection = null;
  }

  /// Runs the session to completion and returns the collected readings.
  /// Throws [ScaleException] on failure; returns what it has on [cancel].
  Future<List<RawReading>> run() async {
    try {
      await _run();
      _flushPending();
      if (_readings.isEmpty && !sync && !_cancelled) {
        throw const ScaleException(ScaleError.noData);
      }
      _emit(ScalePhase.done, liveKg: _lastLiveKg);
      return _readings;
    } on ScaleException catch (e) {
      _emit(ScalePhase.failed, error: e.error);
      rethrow;
    } finally {
      _timer?.cancel();
      await _disconnect();
      await _status.close();
    }
  }

  Future<void> cancel() async {
    _cancelled = true;
    _finish();
    final scan = _scanResult;
    if (scan != null && !scan.isCompleted) scan.complete(null);
  }

  Future<void> _run() async {
    _emit(ScalePhase.preparing);
    if (await _settledStatus(const Duration(seconds: 5)) ==
        BleStatus.unsupported) {
      throw const ScaleException(ScaleError.unsupported);
    }
    if (!await ensureBlePermissions()) {
      throw const ScaleException(ScaleError.permissionDenied);
    }
    if (!await ensureBluetoothOn()) {
      throw const ScaleException(ScaleError.bluetoothOff);
    }
    if (_cancelled) return;

    // Right after a dropped session the scale accepts connections but exposes
    // only its generic services until it has been woken again, so a
    // connection without the measurement characteristics is retried.
    for (var attempt = 1; !await _connect(); attempt++) {
      if (_cancelled) return;
      if (attempt == _connectAttempts) {
        throw const ScaleException(ScaleError.serviceMissing);
      }
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    if (_cancelled) return;

    _emit(ScalePhase.waiting);
    _arm(sync ? _syncIdleTimeout : _stepOnTimeout, _finish);
    await _finished.future;
  }

  /// Finds the scale, connects and starts the measurement session. Returns
  /// false if this connection can't be used and another attempt makes sense.
  Future<bool> _connect() async {
    _emit(ScalePhase.scanning);
    final id = await _scan();
    if (_cancelled) return false;
    if (id == null) throw const ScaleException(ScaleError.notFound);

    _emit(ScalePhase.connecting);
    final connected = Completer<void>();
    _connection = _ble
        .connectToDevice(id: id, connectionTimeout: const Duration(seconds: 20))
        .listen(
          (u) {
            if (u.connectionState == DeviceConnectionState.connected) {
              if (!connected.isCompleted) connected.complete();
            } else if (u.connectionState ==
                DeviceConnectionState.disconnected) {
              if (connected.isCompleted) {
                _finish();
              } else {
                connected.completeError(u.failure ?? 'disconnected');
              }
            }
          },
          onError: (Object e) {
            if (connected.isCompleted) {
              _finish();
            } else {
              connected.completeError(e);
            }
          },
        );
    try {
      await connected.future;
      final chars = {
        for (final s in await _ble.getDiscoveredServices(id))
          for (final c in s.characteristics) c.id.expanded: c,
      };
      final weight = chars[_weightUuid.expanded];
      final body = chars[_bodyUuid.expanded];
      final time = chars[_timeUuid.expanded];
      final userControl = chars[_userControlUuid.expanded];
      final vendorNotify = chars[_vendorNotifyUuid.expanded];
      if (weight == null ||
          body == null ||
          time == null ||
          userControl == null ||
          vendorNotify == null) {
        debugPrint('scale: measurement services missing: ${chars.keys}');
        await _disconnect();
        return false;
      }

      await _openVisitorSession(
        time: time,
        userControl: userControl,
        vendorNotify: vendorNotify,
      );
      // Notify for 2A9D, indicate for 2A9C, chosen from their properties.
      _listen(weight, _onWeight);
      _listen(body, _onBody);
      await Future<void>.delayed(_subscribeSettle);
      return true;
    } catch (e) {
      debugPrint('scale: connect failed: $e');
      await _disconnect();
      if (_cancelled) return false;
      throw const ScaleException(ScaleError.connectFailed);
    }
  }

  void _listen(Characteristic c, void Function(List<int>) onData) {
    _subs.add(
      c.subscribe().listen(
        onData,
        onError: (Object e) => debugPrint('scale: ${c.id} failed: $e'),
      ),
    );
  }

  /// Current Time (2A2B) value: UTC, as the vendor app wrote it.
  static List<int> _currentTime() {
    final t = DateTime.now().toUtc();
    return [
      t.year & 0xFF, t.year >> 8, t.month, t.day, t.hour, t.minute, t.second, //
      t.weekday, 0, 0,
    ];
  }

  Future<void> _openVisitorSession({
    required Characteristic time,
    required Characteristic userControl,
    required Characteristic vendorNotify,
  }) async {
    final reply = Completer<void>();
    _listen(time, (_) {});
    _listen(userControl, (d) {
      debugPrint('scale: 2a9f ${_hex(d)}');
      if (!reply.isCompleted) reply.complete();
    });
    _listen(vendorNotify, (_) {});
    await Future<void>.delayed(_subscribeSettle);
    await time.write(_currentTime());
    await userControl.write(_visitorConsent);
    // Expected reply is `20 02 01`; don't hang the session if it never comes.
    await reply.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('scale: no reply to visitor consent');
      },
    );
  }

  Future<String?> _scan() async {
    final found = _scanResult = Completer<String?>();
    final sub = _ble
        .scanForDevices(
          withServices: const [],
          requireLocationServicesEnabled: false,
        )
        .listen(
          (d) {
            final match = deviceIds.isEmpty
                ? _isScale(d)
                : deviceIds.contains(d.id);
            if (match && !found.isCompleted) found.complete(d.id);
          },
          onError: (Object e) {
            debugPrint('scale: scan failed: $e');
            if (!found.isCompleted) found.complete(null);
          },
        );
    final timer = Timer(_scanTimeout, () {
      if (!found.isCompleted) found.complete(null);
    });
    try {
      return await found.future;
    } finally {
      timer.cancel();
      await sub.cancel();
    }
  }

  static String _hex(List<int> d) =>
      d.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  void _onWeight(List<int> data) {
    debugPrint('scale: 2a9d ${_hex(data)}');
    final w = parseWeight(data);
    if (w == null) return;
    _lastLiveKg = w.kg;
    if (!w.isFinal) {
      _emit(ScalePhase.weighing, liveKg: w.kg);
      // Still settling; keep waiting, but don't cut a slow weigh-in short.
      if (_pendingFinal == null) {
        _arm(sync ? _syncIdleTimeout : _stepOnTimeout, _finish);
      }
      return;
    }
    // A new record before the previous one got its body frame: weight only.
    _flushPending();
    _pendingFinal = w;
    _emit(ScalePhase.weighing, liveKg: w.kg);
    _arm(sync ? _syncIdleTimeout : _bodyFrameTimeout, _finish);
  }

  void _onBody(List<int> data) {
    debugPrint('scale: 2a9c ${_hex(data)}');
    for (final f in _assembler.add(data)) {
      final w = _pendingFinal;
      final kg = w?.kg ?? _lastLiveKg;
      _pendingFinal = null;
      if (kg == null) continue;
      _readings.add(
        RawReading(
          weightKg: kg,
          r50: f.r50,
          r500: f.r500,
          scaleTime: w?.scaleTime ?? f.scaleTime,
        ),
      );
      onReading?.call();
      if (sync) {
        _arm(_syncIdleTimeout, _finish);
      } else {
        _finish();
      }
    }
  }

  void _flushPending() {
    final w = _pendingFinal;
    if (w == null) return;
    _pendingFinal = null;
    _readings.add(
      RawReading(weightKg: w.kg, r50: 0, r500: 0, scaleTime: w.scaleTime),
    );
    onReading?.call();
  }
}
