import '../ble/scale_service.dart';
import 'strings.dart';

final stringsDe = Strings(
  languageName: 'Deutsch',
  mWeight: 'Gewicht',
  mBmi: 'BMI',
  mFat: 'Körperfett',
  mSkelMuscle: 'Skelettmuskulatur',
  mMuscleMass: 'Muskelmasse',
  mWater: 'Körperwasser',
  mProtein: 'Protein',
  mBone: 'Knochenmasse',
  mLeanMass: 'Magermasse',
  mSubcutFat: 'Unterhautfett',
  mVisceral: 'Viszeralfett (Stufe)',
  mBmr: 'Grundumsatz',
  mBodyScore: 'Körperwert',
  mBodyAge: 'Körperalter',
  mBodyShape: 'Körpertyp',
  impedance: 'Impedanz',
  years: 'J.',
  bodyShapes: {
    1: 'Verstecktes Übergewicht',
    2: 'Bewegungsmangel',
    3: 'Schlank',
    4: 'Standard',
    5: 'Schlank und muskulös',
    6: 'Adipös',
    7: 'Übergewichtig',
    8: 'Standard muskulös',
    9: 'Sehr muskulös',
  },
  helpTitle: 'Was die Werte bedeuten',
  helpHint: 'Tippen Sie auf einen Wert für eine Erklärung.',
  helpIntro:
      'Alles außer dem Gewicht ist eine Schätzung: Die Waage leitet '
      'einen schwachen Strom durch die Füße, misst den Widerstand (Impedanz) '
      'und eine Formel verrechnet ihn mit Größe, Alter und Geschlecht. Die '
      'Werte eignen sich, um Veränderungen im Zeitverlauf zu verfolgen, und '
      'sind keine medizinische Diagnose. Wiegen Sie sich barfuß und zur '
      'gleichen Tageszeit.',
  hWeight:
      'Das Körpergewicht in Kilogramm — der einzige Wert, den die Waage '
      'direkt misst.',
  hBmi:
      'Body-Mass-Index: Gewicht geteilt durch das Quadrat der Größe in '
      'Metern. Unter 18,5 — Untergewicht, 18,5–25 — normal, über 25 — '
      'Übergewicht. Er unterscheidet nicht zwischen Muskeln und Fett.',
  hFat:
      'Der Anteil des Gewichts, der aus Fett besteht. Der Algorithmus geht '
      'von etwa 16 % bei Männern und 26 % bei Frauen als Standard aus, mit '
      'einem Normalbereich von ±5 Punkten.',
  hSkelMuscle:
      'Der Anteil des Gewichts, der laut Formel der Waage aus '
      'Muskeln besteht (Magermasse ohne Knochen, mal 0,68 bei Männern und '
      '0,62 bei Frauen). Er liegt höher als medizinische Werte für '
      'Skelettmuskulatur (meist 33–40 % bei Männern) — achten Sie daher auf '
      'die Veränderung, nicht auf die absolute Zahl.',
  hMuscleMass:
      'Gewicht ohne Fett und ohne Knochen, in Kilogramm — Muskeln, '
      'Organe und das Wasser darin.',
  hWater:
      'Der Anteil des Gewichts, der aus Wasser besteht. Er wird aus der '
      'Magermasse berechnet und sinkt bei Flüssigkeitsmangel und mit '
      'steigendem Körperfett.',
  hProtein:
      'Der Anteil des Gewichts, der aus Eiweiß besteht — der Rest nach '
      'Fett, Knochen und Wasser.',
  hBone:
      'Geschätzte Knochenmasse in Kilogramm (etwa 5–6 % der Magermasse). '
      'Keine Messung der Knochendichte.',
  hLeanMass:
      'Magermasse (fettfreie Masse): Gewicht minus Fett, in '
      'Kilogramm.',
  hSubcutFat:
      'Fett unter der Haut in Prozent des Gewichts — der Teil des '
      'Gesamtfetts, der nicht um die inneren Organe liegt.',
  hVisceral:
      'Stufe des Fetts um die inneren Organe auf einer Skala von 1 '
      'bis 30 — ohne Einheit. Übliche Deutung: bis 9 — normal, 10–14 — '
      'erhöht, ab 15 — hoch.',
  hBmr:
      'Grundumsatz: wie viele Kilokalorien der Körper pro Tag in völliger '
      'Ruhe verbraucht. Berechnet aus der Magermasse (370 + 21,6 × Magermasse '
      'in kg).',
  hBodyScore:
      'Eine Gesamtbewertung von 0 bis 100 — der Mittelwert aus drei '
      'Teilwerten: wie nah das Gewicht am Standardgewicht für die Größe '
      'liegt, der BMI an 22 und das Körperfett am Standard (16 % Männer, '
      '26 % Frauen). 100 bedeutet genau bei diesen Idealwerten.',
  hBodyAge:
      'Ein rechnerisches „Körperalter“, abgeleitet vom Körperwert: '
      'bei hohem Wert niedriger als das tatsächliche Alter, bei niedrigem '
      'höher. Das Minimum ist 18.',
  hBodyShape:
      'Einer von neun Typen nach BMI und Körperfett — zum Beispiel '
      '„Standard“, „Schlank und muskulös“ oder „Verstecktes Übergewicht“ '
      '(normales Gewicht, aber hoher Fettanteil).',
  hImpedance:
      'Die Rohmessung: der Widerstand des Körpers in Ohm bei 50 kHz '
      'und 500 kHz. Daraus und aus dem Gewicht wird alles andere berechnet. '
      'Fehlt, wenn Sie Socken oder Schuhe getragen haben.',
  whyTitle: 'Warum wir diese Daten brauchen',
  whyIntro:
      'Die Waage misst nur das Gewicht und den elektrischen Widerstand '
      'des Körpers. Um daraus Körperfett, Muskeln, Wasser und die übrigen '
      'Werte zu berechnen, braucht die Formel einige Angaben zu Ihnen.',
  whyName:
      'Nur um die Benutzer zu unterscheiden, wenn mehrere Personen die '
      'Waage teilen. Ein Spitzname genügt.',
  whyGender:
      'Bei Männern und Frauen verteilen sich Fett, Muskeln und Wasser '
      'unterschiedlich, daher nutzt die Formel andere Koeffizienten und '
      'andere Standardwerte (z. B. etwa 16 % Körperfett bei Männern und 26 % '
      'bei Frauen).',
  whyBirthday:
      'Das Alter fließt in die Körperfett-Formel und in das '
      'Körperalter ein. Wir fragen nach dem Geburtsdatum statt nach dem '
      'Alter, damit es mit der Zeit stimmt, ohne dass Sie es aktualisieren '
      'müssen.',
  whyHeight:
      'Der Strom fließt durch die Länge des Körpers, daher ist die '
      'Größe eine zentrale Eingabe der Formel. Sie wird auch für den BMI und '
      'das Standardgewicht verwendet.',
  whyRefWeight:
      'Optional. Ihr übliches Gewicht — wird nur für einen Hinweis '
      'genutzt, wenn eine Messung eher zu einem anderen Benutzer passt.',
  whyStorage:
      'Die Daten werden nur auf diesem Telefon gespeichert. Die App '
      'hat keine Konten und sendet nichts über das Internet.',
  fmtTitle: 'Format der Importdatei',
  fmtIntro: 'Der Import akzeptiert eine JSON-Datei (UTF-8). Eine mit „Sicherung (JSON)“ erstellte Datei lässt sich unverändert importieren. Sie können eine solche Datei auch selbst erstellen — etwa um Messungen aus einer anderen App oder einer Tabelle zu übernehmen.',
  fmtStructure: 'Aufbau',
  fmtStructureBody: 'Ein Objekt mit zwei Listen: „profiles“ (Benutzer) und „measurements“ (Messungen). Weitere Schlüssel („format“, „version“, „exportedAt“) schreibt die App; beim Import werden sie ignoriert.',
  fmtProfiles: 'Benutzer (profiles)',
  fmtMeasurements: 'Messung (measurements)',
  fmtRequired: 'Pflicht',
  fmtOptional: 'optional',
  fmtRules: 'Regeln beim Import',
  fmtRulesBody: '• Vorhandene Daten werden nie geändert oder gelöscht — die Datei wird hinzugefügt.\n• Ein Benutzer mit gleichem Namen, Geschlecht, gleicher Größe und gleichem Geburtsdatum gilt als derselbe Benutzer.\n• Eine Messung mit gleichem Benutzer, Zeitpunkt, Gewicht und gleicher Impedanz wird übersprungen; ein zweiter Import derselben Datei fügt also nichts hinzu.\n• Ist die Datei ungültig, wird nichts importiert.\n• Das Dezimaltrennzeichen ist ein Punkt (78.6).',
  fmtExample: 'Beispiel',
  fmtCopy: 'Beispiel kopieren',
  fmtCopied: 'Beispiel kopiert.',
  fieldDocs: {
    'id': 'Beliebige ganze Zahl, eindeutig in der Datei. Dient nur zur Zuordnung der Messungen.',
    'name': 'Name des Benutzers.',
    'gender': 'Geschlecht: "male" (Mann) oder "female" (Frau).',
    'height_cm': 'Größe in Zentimetern.',
    'birthday': 'Geburtsdatum als JJJJ-MM-TT.',
    'ref_weight_kg': 'Übliches Gewicht in kg.',
    'created_at': 'Wann der Benutzer angelegt wurde (ISO 8601). Fehlt es, der Zeitpunkt des Imports.',
    'profile_id': 'Die „id“ eines Benutzers aus derselben Datei.',
    'timestamp_utc': 'Zeitpunkt der Messung, z. B. "2026-10-01T07:30:00Z". Mit „Z“ ist die Zeit UTC, ohne die Ortszeit des Telefons.',
    'weight_kg': 'Gewicht in Kilogramm.',
    'r50': 'Impedanz bei 50 kHz in Ohm. 0 oder fehlend — nur Gewicht.',
    'r500': 'Impedanz bei 500 kHz in Ohm.',
    'source': 'Freie Angabe zur Herkunft.',
    'composition': 'Die Felder zur Körperzusammensetzung (fat_pct, water_pct, bmr usw.) sind optional. Werte in der Datei werden unverändert übernommen — auch ohne Impedanz, z. B. bereits von einer anderen App berechnet. Fehlende Werte berechnet die App beim Import aus dem Benutzerprofil wie bei einer neuen Messung; ohne Impedanz nur den BMI.',
  },
  appearanceSection: 'Darstellung',
  themeLight: 'Hell',
  themeDark: 'Dunkel',
  themeSystem: 'Wie das Telefon',
  cancel: 'Abbrechen',
  save: 'Speichern',
  delete: 'Löschen',
  close: 'Schließen',
  share: 'Teilen',
  ok: 'OK',
  loadError: 'Fehler beim Laden',
  obTitle: 'Willkommen',
  obBody:
      'Geben Sie Ihre Daten ein, um das erste Profil anzulegen. Die App '
      'berechnet damit Ihre Körperzusammensetzung aus der Messung der Waage.',
  obStart: 'Los geht\'s',
  newMeasurement: 'Neue Messung',
  statistics: 'Statistik',
  allMeasurements: 'Alle Messungen',
  settings: 'Einstellungen',
  lastMeasurements: 'Letzte Messungen',
  trends: 'Verlauf',
  noMeasurements: 'Noch keine Messungen.',
  phasePreparing: 'Vorbereitung…',
  phaseScanning: 'Stellen Sie sich barfuß auf die Waage — die App verbindet sich von selbst.',
  phaseConnecting: 'Verbinde…',
  phaseWaitingLive: 'Verbunden. Falls noch nicht geschehen, stellen Sie sich barfuß auf die Waage.',
  phaseWaitingSync: 'Verbunden. Lese verfügbare Messungen…',
  phaseWeighing: 'Messe… Bitte stillstehen.',
  measurementSaved: 'Messung gespeichert.',
  weightOnlyNote:
      'Die Waage hat keine Impedanz gemessen (barfuß?) — nur das '
      'Gewicht wurde gespeichert.',
  syncNothing: 'Keine neuen Messungen von der Waage.',
  syncSaved: (n) =>
      n == 1 ? '1 Messung gespeichert.' : '$n Messungen gespeichert.',
  looksLike: (name) =>
      'Dieses Gewicht weicht stark vom Üblichen dieses '
      'Benutzers ab. Ist es $name?',
  reassignTo: (name) => 'Zu $name verschieben',
  retry: 'Erneut versuchen',
  scaleErrors: {
    ScaleError.unsupported: 'Dieses Gerät hat kein Bluetooth LE.',
    ScaleError.bluetoothOff:
        'Bluetooth ist aus. Schalten Sie es ein und versuchen Sie es erneut.',
    ScaleError.permissionDenied:
        'Die Bluetooth-Berechtigung („Geräte in '
        'der Nähe“) ist erforderlich. Erlauben Sie sie in den '
        'App-Einstellungen.',
    ScaleError.notFound:
        'Waage nicht gefunden. Wecken Sie sie mit kurzem '
        'Antippen und versuchen Sie es erneut.',
    ScaleError.connectFailed:
        'Verbindung zur Waage fehlgeschlagen. Versuchen Sie es erneut.',
    ScaleError.serviceMissing:
        'Die Waage ist noch nicht messbereit. Wecken '
        'Sie sie mit kurzem Antippen und versuchen Sie es erneut.',
    ScaleError.noData:
        'Die Waage hat keine Messung gesendet. Stellen Sie '
        'sich barfuß darauf und versuchen Sie es erneut.',
  },
  openAppSettings: 'App-Einstellungen',
  period7d: '7 Tage',
  period30d: '30 Tage',
  period90d: '3 Monate',
  period1y: '1 Jahr',
  periodAll: 'Alles',
  periodCustom: 'Auswahl…',
  metricsFilter: 'Werte',
  chartLine: 'Linie',
  chartBar: 'Balken',
  chartScatter: 'Punkte',
  noDataInPeriod: 'Keine Daten für den gewählten Zeitraum.',
  measurement: 'Messung',
  reassign: 'Zu anderem Benutzer verschieben',
  deleteMeasurementQ: 'Diese Messung löschen?',
  scaleSection: 'Waagen',
  scaleNone:
      'Keine gespeicherten Waagen — die App verbindet sich mit der '
      'ersten gefundenen.',
  scaleFind: 'Waage hinzufügen',
  scaleName: 'Name der Waage',
  scaleDefaultName: 'Waage',
  scaleAlreadySaved: 'bereits gespeichert',
  scaleForgetQ: (name) => '„$name“ entfernen?',
  scaleSearching: 'Suche… Wecken Sie die Waage mit kurzem Antippen.',
  scaleNoneFound: 'Keine Waage gefunden.',
  usersSection: 'Benutzer',
  addProfile: 'Benutzer hinzufügen',
  measuringSection: 'Messen',
  doneSound: 'Töne',
  doneSoundHint:
      'Ein Glockenton, wenn die Messung fertig ist und Sie absteigen können',
  dataSection: 'Export und Import',
  exportCsv: 'Als CSV exportieren',
  exportCsvHint:
      'Eine Tabelle für Excel und ähnliche Programme. Kann nicht '
      'wieder importiert werden.',
  exportJson: 'Sicherung (JSON)',
  exportJsonHint:
      'Eine vollständige Kopie der Benutzer und Messungen — als '
      'Sicherung oder für ein anderes Telefon.',
  exportEmpty: 'Keine Messungen zum Exportieren.',
  importJson: 'Aus Sicherung importieren',
  importJsonHint:
      'Fügt die Benutzer und Messungen aus einer Sicherung (JSON) '
      'hinzu. Vorhandene Daten bleiben erhalten; Duplikate werden '
      'übersprungen.',
  importDone: (p, m) => 'Importiert: $p neue Benutzer, $m Messungen.',
  importInvalid: 'Diese Datei ist keine Sicherung dieser App.',
  deleteSection: 'Daten löschen',
  deleteUserData: 'Daten eines Benutzers löschen',
  deleteUserDataHint:
      'Die Messungen eines Benutzers, auf Wunsch auch den '
      'Benutzer',
  deleteAllData: 'Alle Daten löschen',
  deleteAllDataHint: 'Alle Benutzer, Messungen, Waagen und Einstellungen',
  deleteAlsoProfile: 'Auch den Benutzer löschen',
  deleteIrreversible:
      'Dies kann nicht rückgängig gemacht werden. Um die '
      'Daten zu behalten, erstellen Sie zuerst eine Sicherung.',
  deleteUserDataQ: (name, n, alsoProfile) => alsoProfile
      ? 'Benutzer „$name“ und alle $n Messungen löschen?'
      : 'Alle $n Messungen von „$name“ löschen? Der Benutzer bleibt erhalten.',
  deleteAllDataQ:
      'ALLE Daten der App löschen — Benutzer, Messungen, '
      'gespeicherte Waagen und Einstellungen?',
  deleteUnderstand: 'Ich verstehe, dass die Daten endgültig gelöscht werden',
  deleteContinue: 'Weiter',
  deletedUserData: (name) => 'Die Daten von „$name“ wurden gelöscht.',
  deletedAllData: 'Alle Daten wurden gelöscht.',
  languageSection: 'Sprache',
  languageFollowsPhone: 'Folgt der Sprache des Telefons',
  aboutSection: 'Über die App',
  version: 'Version',
  privacy: 'Datenschutz',
  privacyBody:
      'Alle Daten (Benutzer und Messungen) werden nur auf diesem '
      'Gerät gespeichert. Die App sendet nichts über das Netzwerk und hat '
      'keine Konten. Daten verlassen das Telefon nur, wenn Sie sie '
      'exportieren oder teilen.',
  newProfile: 'Neuer Benutzer',
  editProfile: 'Benutzer bearbeiten',
  name: 'Name',
  gender: 'Geschlecht',
  male: 'Mann',
  female: 'Frau',
  heightCm: 'Größe (cm)',
  birthday: 'Geburtsdatum',
  refWeight: 'Übliches Gewicht (kg, optional)',
  pickDate: 'Datum wählen',
  errName: 'Namen eingeben',
  errHeight: 'Größe zwischen 100 und 250 cm',
  errBirthday: 'Geburtsdatum wählen',
  errNumber: 'Ungültige Zahl',
  deleteProfileQ: (name) => '„$name“ mit allen Messungen löschen?',
);
