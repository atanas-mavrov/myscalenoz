import '../ble/scale_service.dart';
import 'strings.dart';

final stringsEn = Strings(
  languageName: 'English',
  mWeight: 'Weight',
  mBmi: 'BMI',
  mFat: 'Body fat',
  mSkelMuscle: 'Skeletal muscle',
  mMuscleMass: 'Muscle mass',
  mWater: 'Body water',
  mProtein: 'Protein',
  mBone: 'Bone mass',
  mLeanMass: 'Lean mass',
  mSubcutFat: 'Subcutaneous fat',
  mVisceral: 'Visceral fat (level)',
  mBmr: 'BMR',
  mBodyScore: 'Body score',
  mBodyAge: 'Body age',
  mBodyShape: 'Body type',
  impedance: 'Impedance',
  years: 'y',
  bodyShapes: {
    1: 'Hidden obesity',
    2: 'Lack of exercise',
    3: 'Thin',
    4: 'Standard',
    5: 'Thin and muscular',
    6: 'Obese',
    7: 'Overweight',
    8: 'Standard muscular',
    9: 'Very muscular',
  },
  helpTitle: 'What the values mean',
  helpHint: 'Tap a value for an explanation.',
  helpIntro:
      'Everything except weight is an estimate: the scale sends a weak '
      'current through your feet, measures the resistance (impedance) and a '
      'formula combines it with your height, age and sex. The values are '
      'useful for tracking change over time and are not a medical diagnosis. '
      'Weigh yourself barefoot, at the same time of day.',
  hWeight:
      'Body weight in kilograms — the only value the scale measures '
      'directly.',
  hBmi:
      'Body mass index: weight divided by height in metres squared. Below '
      '18.5 — underweight, 18.5–25 — normal, above 25 — overweight. It does '
      'not tell muscle from fat.',
  hFat:
      'The share of your weight that is fat. The algorithm treats about 16% '
      'for men and 26% for women as standard, with a normal range of ±5 '
      'points.',
  hSkelMuscle:
      'The share of your weight that is muscle according to the '
      'scale\'s formula (lean mass without bone, times 0.68 for men and 0.62 '
      'for women). It comes out higher than medical skeletal-muscle values '
      '(typically 33–40% for men), so follow the trend rather than the '
      'absolute number.',
  hMuscleMass:
      'Weight without fat and without bone, in kilograms — muscles, '
      'organs and the water in them.',
  hWater:
      'The share of your weight that is water. It is derived from lean '
      'mass; it drops with dehydration and as body fat increases.',
  hProtein:
      'The share of your weight that is protein — what remains after '
      'fat, bone and water.',
  hBone:
      'Estimated bone mass in kilograms (about 5–6% of lean mass). It is '
      'not a bone-density measurement.',
  hLeanMass: 'Lean (fat-free) mass: weight minus fat, in kilograms.',
  hSubcutFat:
      'Fat under the skin as a percentage of weight — the part of '
      'total fat that is not around the internal organs.',
  hVisceral:
      'Level of the fat around the internal organs on a scale of 1 to '
      '30 — it has no unit. Common interpretation: up to 9 — normal, 10–14 — '
      'elevated, 15 and above — high.',
  hBmr:
      'Basal metabolic rate: how many kilocalories per day your body uses '
      'at complete rest. Calculated from lean mass (370 + 21.6 × lean mass '
      'in kg).',
  hBodyScore:
      'An overall score from 0 to 100 — the average of three '
      'sub-scores: how close your weight is to the standard weight for your '
      'height, your BMI to 22 and your body fat to the standard (16% men, 26% '
      'women). 100 means exactly on these ideals.',
  hBodyAge:
      'A notional "body age" derived from the body score: lower than '
      'your real age when the score is high, higher when it is low. The '
      'minimum is 18.',
  hBodyShape:
      'One of nine types based on BMI and body fat — for example '
      '"Standard", "Thin and muscular" or "Hidden obesity" (normal weight but '
      'high body fat).',
  hImpedance:
      'The raw measurement: the body\'s resistance in ohms at 50 kHz '
      'and 500 kHz. Everything else is calculated from it and your weight. '
      'Missing if you wore socks or shoes.',
  whyTitle: 'Why we need this data',
  whyIntro:
      'The scale only measures weight and the body\'s electrical '
      'resistance. To turn those into body fat, muscle, water and the other '
      'values, the formula needs a few details about you.',
  whyName:
      'Only to tell users apart if several people share the scale. A '
      'nickname is fine.',
  whyGender:
      'Men and women carry fat, muscle and water differently, so the '
      'formula uses different coefficients and different standards (e.g. '
      'about 16% body fat for men and 26% for women).',
  whyBirthday:
      'Age is part of the body-fat formula and of body age. We ask '
      'for the date of birth rather than the age so that it stays correct '
      'over time without you having to update it.',
  whyHeight:
      'The current flows through the length of your body, so height '
      'is a key input of the formula. It is also used for BMI and the '
      'standard weight.',
  whyRefWeight:
      'Optional. Your usual weight — only used to suggest when a '
      'measurement looks like it belongs to another user.',
  whyStorage:
      'The data is stored only on this phone. The app has no '
      'accounts and sends nothing over the internet.',
  fmtTitle: 'Import file format',
  fmtIntro: 'Import accepts a JSON file (UTF-8). A backup made with "Backup (JSON)" can be imported as is. You can also prepare such a file yourself — for example to bring in measurements from another app or a spreadsheet.',
  fmtStructure: 'Structure',
  fmtStructureBody: 'An object with two lists: "profiles" (users) and "measurements". Other keys ("format", "version", "exportedAt") are written by the app and ignored on import.',
  fmtProfiles: 'User (profiles)',
  fmtMeasurements: 'Measurement (measurements)',
  fmtRequired: 'required',
  fmtOptional: 'optional',
  fmtRules: 'Rules on import',
  fmtRulesBody: '• Existing data is never changed or deleted — the file is added to it.\n• A user with the same name, sex, height and date of birth is treated as the same user.\n• A measurement with the same user, time, weight and impedance is skipped, so importing the same file twice adds nothing.\n• If the file is invalid, nothing is imported.\n• The decimal separator is a dot (78.6).',
  fmtExample: 'Example',
  fmtCopy: 'Copy the example',
  fmtCopied: 'Example copied.',
  fieldDocs: {
    'id': 'Any integer, unique within the file. Only used to link measurements to the user.',
    'name': 'User name.',
    'gender': 'Sex: "male" or "female".',
    'height_cm': 'Height in centimetres.',
    'birthday': 'Date of birth as YYYY-MM-DD.',
    'ref_weight_kg': 'Usual weight in kg.',
    'created_at':
        'When the user was created (ISO 8601). If missing, the time of import.',
    'profile_id': 'The "id" of a user in the same file.',
    'timestamp_utc': 'When it was measured, e.g. "2026-10-01T07:30:00Z". With "Z" the time is UTC; without it, the phone\'s local time.',
    'weight_kg': 'Weight in kilograms.',
    'r50': 'Impedance at 50 kHz in ohms. 0 or missing — weight only.',
    'r500': 'Impedance at 500 kHz in ohms.',
    'source': 'Free label for where it came from.',
    'composition': 'Body-composition fields (fat_pct, water_pct, bmr, etc.) are optional. Values present in the file are imported as they are — also without impedance, e.g. already calculated by another app. Missing ones are computed on import from the user\'s profile, as for a new measurement; without impedance only BMI is computed.',
  },
  appearanceSection: 'Appearance',
  themeLight: 'Light',
  themeDark: 'Dark',
  themeSystem: 'Same as phone',
  cancel: 'Cancel',
  save: 'Save',
  delete: 'Delete',
  close: 'Close',
  share: 'Share',
  ok: 'OK',
  loadError: 'Loading failed',
  obTitle: 'Welcome',
  obBody:
      'Enter your details to create the first profile. The app uses them '
      'to calculate your body composition from the scale\'s measurement.',
  obStart: 'Get started',
  newMeasurement: 'New measurement',
  statistics: 'Statistics',
  allMeasurements: 'All measurements',
  settings: 'Settings',
  lastMeasurements: 'Recent measurements',
  trends: 'Trends',
  noMeasurements: 'No measurements yet.',
  phasePreparing: 'Preparing…',
  phaseScanning: 'Step on the scale barefoot — the app will connect by itself.',
  phaseConnecting: 'Connecting…',
  phaseWaitingLive:
      'Connected. If you haven\'t yet, step on the scale barefoot.',
  phaseWaitingSync: 'Connected. Reading available measurements…',
  phaseWeighing: 'Measuring… Stand still.',
  measurementSaved: 'Measurement saved.',
  weightOnlyNote:
      'The scale did not measure impedance (bare feet?) — only '
      'the weight was saved.',
  syncNothing: 'No new measurements from the scale.',
  syncSaved: (n) => n == 1 ? '1 measurement saved.' : '$n measurements saved.',
  looksLike: (name) =>
      'This weight is far from this user\'s usual. Is it $name?',
  reassignTo: (name) => 'Move to $name',
  retry: 'Try again',
  scaleErrors: {
    ScaleError.unsupported: 'This device has no Bluetooth LE.',
    ScaleError.bluetoothOff: 'Bluetooth is off. Turn it on and try again.',
    ScaleError.permissionDenied:
        'Bluetooth permission ("Nearby devices") is '
        'required. Allow it in the app settings.',
    ScaleError.notFound:
        'Scale not found. Wake it with a quick tap of your '
        'foot and try again.',
    ScaleError.connectFailed: 'Could not connect to the scale. Try again.',
    ScaleError.serviceMissing:
        'The scale is not ready to measure yet. Wake '
        'it with a quick tap of your foot and try again.',
    ScaleError.noData:
        'The scale sent no measurement. Step on barefoot and try again.',
  },
  openAppSettings: 'App settings',
  period7d: '7 days',
  period30d: '30 days',
  period90d: '3 months',
  period1y: '1 year',
  periodAll: 'All',
  periodCustom: 'Custom…',
  metricsFilter: 'Values',
  chartLine: 'Line',
  chartBar: 'Bars',
  chartScatter: 'Points',
  noDataInPeriod: 'No data for the selected period.',
  measurement: 'Measurement',
  reassign: 'Move to another user',
  deleteMeasurementQ: 'Delete this measurement?',
  scaleSection: 'Scales',
  scaleNone: 'No saved scales — the app connects to the first one it finds.',
  scaleFind: 'Add scale',
  scaleName: 'Scale name',
  scaleDefaultName: 'Scale',
  scaleAlreadySaved: 'already saved',
  scaleForgetQ: (name) => 'Remove "$name"?',
  scaleSearching: 'Searching… Wake the scale with a quick tap of your foot.',
  scaleNoneFound: 'No scale found.',
  usersSection: 'Users',
  addProfile: 'Add user',
  measuringSection: 'Measuring',
  doneSound: 'Sounds',
  doneSoundHint:
      'A chime when the measurement is done and you can step off the scale',
  dataSection: 'Export and import',
  exportCsv: 'Export to CSV',
  exportCsvHint:
      'A table for Excel and similar apps. Cannot be imported '
      'back.',
  exportJson: 'Backup (JSON)',
  exportJsonHint:
      'A full copy of users and measurements — as a backup or to '
      'move to another phone.',
  exportEmpty: 'No measurements to export.',
  importJson: 'Import from backup',
  importJsonHint:
      'Adds the users and measurements from a backup (JSON). '
      'Existing data is kept; duplicates are skipped.',
  importDone: (p, m) => 'Imported: $p new users, $m measurements.',
  importInvalid: 'This file is not a backup from this app.',
  deleteSection: 'Delete data',
  deleteUserData: 'Delete a user\'s data',
  deleteUserDataHint: 'One user\'s measurements, and optionally the user',
  deleteAllData: 'Delete all data',
  deleteAllDataHint: 'All users, measurements, scales and settings',
  deleteAlsoProfile: 'Also delete the user',
  deleteIrreversible:
      'This cannot be undone. To keep the data, make a '
      'backup first.',
  deleteUserDataQ: (name, n, alsoProfile) => alsoProfile
      ? 'Delete the user "$name" and all $n of their measurements?'
      : 'Delete all $n measurements of "$name"? The user is kept.',
  deleteAllDataQ:
      'Delete ALL app data — users, measurements, saved scales '
      'and settings?',
  deleteUnderstand: 'I understand the data will be permanently deleted',
  deleteContinue: 'Continue',
  deletedUserData: (name) => 'The data of "$name" was deleted.',
  deletedAllData: 'All data was deleted.',
  languageSection: 'Language',
  languageFollowsPhone: 'Follows the phone\'s language',
  aboutSection: 'About',
  version: 'Version',
  privacy: 'Privacy',
  privacyBody:
      'All data (users and measurements) is stored only on this '
      'device. The app sends nothing over the network and has no accounts. '
      'Data leaves the phone only when you choose to export or share it.',
  newProfile: 'New user',
  editProfile: 'Edit user',
  name: 'Name',
  gender: 'Sex',
  male: 'Male',
  female: 'Female',
  heightCm: 'Height (cm)',
  birthday: 'Date of birth',
  refWeight: 'Usual weight (kg, optional)',
  pickDate: 'Pick a date',
  errName: 'Enter a name',
  errHeight: 'Height between 100 and 250 cm',
  errBirthday: 'Pick a date of birth',
  errNumber: 'Invalid number',
  deleteProfileQ: (name) =>
      'Delete "$name" together with all their '
      'measurements?',
);
