import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app_config.dart';
import 'data/db.dart';
import 'l10n/strings.dart';
import 'state/providers.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Only the app's languages, not every locale intl knows.
  for (final code in languages.keys) {
    await initializeDateFormatting(code);
  }
  final dir = await getApplicationDocumentsDirectory();
  final db = await AppDb.open(p.join(dir.path, 'app.db'));
  final settings = await db.settings();
  runApp(
    ProviderScope(
      overrides: [
        dbProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
      ],
      child: const App(),
    ),
  );
}

/// Uses the language chosen in the settings, or else the phone's language
/// when the app has it, otherwise English; follows changes of either.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final language =
        ref.watch(settingsProvider.select((s) => s.language)) ??
        resolveLanguage(WidgetsBinding.instance.platformDispatcher.locales);
    setLanguage(language);
    return MaterialApp(
      // Rebuilds every screen when the language changes.
      key: ValueKey(language),
      title: AppConfig.appName,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: ref.watch(settingsProvider.select((s) => s.themeMode)),
      locale: Locale(language),
      supportedLocales: [for (final code in languages.keys) Locale(code)],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const HomeScreen(),
    );
  }
}
