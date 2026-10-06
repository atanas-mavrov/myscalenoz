import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myscalenoz/data/models.dart';
import 'package:myscalenoz/l10n/strings.dart';
import 'package:myscalenoz/state/providers.dart';
import 'package:myscalenoz/ui/home_screen.dart';
import 'package:myscalenoz/ui/settings_screen.dart';

final _profile = Profile(
  id: 1,
  name: 'Иван',
  gender: Gender.male,
  heightCm: 180,
  birthday: DateTime(1978, 3, 15),
  createdAt: DateTime.utc(2026, 1, 1),
);

/// Newest first, one per day, the last one weight-only.
List<Measurement> _measurements(int n) => [
  for (var i = 0; i < n; i++)
    Measurement.fromMap({
      ...Measurement.compute(
        profile: _profile,
        timestampUtc: DateTime.now().toUtc().subtract(Duration(days: i)),
        weightKg: 78.6 + i * 0.1,
        r50: i == n - 1 ? 0 : 467,
        r500: i == n - 1 ? 0 : 427,
      ).toMap(),
      'id': i + 1,
    }),
];

Widget _app(List<Profile> profiles, List<Measurement> measurements) =>
    ProviderScope(
      overrides: [
        profilesProvider.overrideWith((_) => profiles),
        measurementsProvider.overrideWith((_, _) => measurements),
      ],
      child: const MaterialApp(
        locale: Locale('bg'),
        supportedLocales: [Locale('bg')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: HomeScreen(),
      ),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    setLanguage('bg');
  });

  // Tall enough that the lazily-built lists show everything without scrolling.
  Future<void> pump(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(1080, 9000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('no profiles: first-start form, with the why page', (
    tester,
  ) async {
    await pump(tester, _app(const [], const []));
    expect(find.text(S.obTitle), findsOneWidget);
    expect(find.text(S.obStart), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.byTooltip(S.whyTitle));
    await tester.pumpAndSettle();
    expect(find.text(S.whyHeight), findsOneWidget);
  });

  testWidgets('home lists at most 10 measurements and opens the detail', (
    tester,
  ) async {
    await pump(tester, _app([_profile], _measurements(12)));
    expect(find.text(S.newMeasurement), findsOneWidget);
    expect(find.text(S.trends), findsOneWidget);

    expect(find.byType(ListTile), findsNWidgets(10));

    await tester.tap(find.byType(ListTile).last);
    await tester.pumpAndSettle();
    expect(find.text(S.measurement), findsOneWidget);
    expect(find.text(S.mBodyShape), findsOneWidget);

    await tester.tap(find.text(S.mVisceral));
    await tester.pumpAndSettle();
    expect(find.text(S.hVisceral), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(S.helpTitle));
    await tester.pumpAndSettle();
    expect(find.text(S.helpIntro), findsOneWidget);
    expect(find.text(S.hBodyScore), findsOneWidget);
  });

  testWidgets('statistics draws each chart kind, also for a single point', (
    tester,
  ) async {
    for (final n in [12, 1]) {
      await pump(tester, _app([_profile], _measurements(n + 1)));
      await tester.tap(find.text(S.statistics));
      await tester.pumpAndSettle();
      expect(find.byType(LineChart), findsWidgets);
      await tester.tap(find.text(S.chartBar));
      await tester.pumpAndSettle();
      expect(find.byType(BarChart), findsWidgets);
      await tester.tap(find.text(S.chartScatter));
      await tester.pumpAndSettle();
      expect(find.byType(ScatterChart), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('delete all data needs an explicit acknowledgement', (
    tester,
  ) async {
    await pump(tester, _app([_profile], _measurements(3)));
    await tester.tap(find.byTooltip(S.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text(S.deleteAllData));
    await tester.pumpAndSettle();
    FilledButton deleteButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.delete),
    );
    expect(deleteButton().onPressed, isNull);

    await tester.tap(find.text(S.deleteUnderstand));
    await tester.pumpAndSettle();
    expect(deleteButton().onPressed, isNotNull);

    await tester.tap(find.text(S.cancel));
    await tester.pumpAndSettle();
    expect(find.text(S.deleteUnderstand), findsNothing);
  });
}
