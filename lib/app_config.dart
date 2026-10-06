/// App-wide constants.
abstract final class AppConfig {
  /// Display name. To rename the app change this line and `android:label` in
  /// android/app/src/main/AndroidManifest.xml.
  static const appName = 'MyScaleNoz';

  /// Keep in sync with `version:` in pubspec.yaml.
  static const appVersion = '1.0.0';

  /// Advertised BLE name of the supported scales.
  static const scaleName = 'QN-Scale';
}
