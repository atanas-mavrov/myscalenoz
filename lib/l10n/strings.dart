import 'dart:ui' show Locale;

import '../ble/scale_service.dart';
import 'strings_bg.dart';
import 'strings_de.dart';
import 'strings_en.dart';
import 'strings_es.dart';
import 'strings_fr.dart';

/// All user-visible text of one language. Every language must provide every
/// field (the constructor parameters are required), so a missing translation
/// is a compile error.
class Strings {
  Strings({
    required this.languageName,
    // metrics
    required this.mWeight,
    required this.mBmi,
    required this.mFat,
    required this.mSkelMuscle,
    required this.mMuscleMass,
    required this.mWater,
    required this.mProtein,
    required this.mBone,
    required this.mLeanMass,
    required this.mSubcutFat,
    required this.mVisceral,
    required this.mBmr,
    required this.mBodyScore,
    required this.mBodyAge,
    required this.mBodyShape,
    required this.impedance,
    required this.years,
    required this.bodyShapes,
    // metric explanations
    required this.helpTitle,
    required this.helpHint,
    required this.helpIntro,
    required this.hWeight,
    required this.hBmi,
    required this.hFat,
    required this.hSkelMuscle,
    required this.hMuscleMass,
    required this.hWater,
    required this.hProtein,
    required this.hBone,
    required this.hLeanMass,
    required this.hSubcutFat,
    required this.hVisceral,
    required this.hBmr,
    required this.hBodyScore,
    required this.hBodyAge,
    required this.hBodyShape,
    required this.hImpedance,
    // why we ask for personal data
    required this.whyTitle,
    required this.whyIntro,
    required this.whyName,
    required this.whyGender,
    required this.whyBirthday,
    required this.whyHeight,
    required this.whyRefWeight,
    required this.whyStorage,
    // import file format
    required this.fmtTitle,
    required this.fmtIntro,
    required this.fmtStructure,
    required this.fmtStructureBody,
    required this.fmtProfiles,
    required this.fmtMeasurements,
    required this.fmtRequired,
    required this.fmtOptional,
    required this.fmtRules,
    required this.fmtRulesBody,
    required this.fmtExample,
    required this.fmtCopy,
    required this.fmtCopied,
    required this.fieldDocs,
    required this.appearanceSection,
    required this.themeLight,
    required this.themeDark,
    required this.themeSystem,
    // common
    required this.cancel,
    required this.save,
    required this.delete,
    required this.close,
    required this.share,
    required this.ok,
    required this.loadError,
    // onboarding
    required this.obTitle,
    required this.obBody,
    required this.obStart,
    // home
    required this.newMeasurement,
    required this.statistics,
    required this.allMeasurements,
    required this.settings,
    required this.lastMeasurements,
    required this.trends,
    required this.noMeasurements,
    // measuring
    required this.phasePreparing,
    required this.phaseScanning,
    required this.phaseConnecting,
    required this.phaseWaitingLive,
    required this.phaseWaitingSync,
    required this.phaseWeighing,
    required this.measurementSaved,
    required this.weightOnlyNote,
    required this.syncNothing,
    required this.syncSaved,
    required this.looksLike,
    required this.reassignTo,
    required this.retry,
    required this.scaleErrors,
    required this.openAppSettings,
    // statistics
    required this.period7d,
    required this.period30d,
    required this.period90d,
    required this.period1y,
    required this.periodAll,
    required this.periodCustom,
    required this.metricsFilter,
    required this.chartLine,
    required this.chartBar,
    required this.chartScatter,
    required this.noDataInPeriod,
    // measurement detail
    required this.measurement,
    required this.reassign,
    required this.deleteMeasurementQ,
    // settings: scales
    required this.scaleSection,
    required this.scaleNone,
    required this.scaleFind,
    required this.scaleName,
    required this.scaleDefaultName,
    required this.scaleAlreadySaved,
    required this.scaleForgetQ,
    required this.scaleSearching,
    required this.scaleNoneFound,
    // settings: users, measuring
    required this.usersSection,
    required this.addProfile,
    required this.measuringSection,
    required this.doneSound,
    required this.doneSoundHint,
    // settings: data
    required this.dataSection,
    required this.exportCsv,
    required this.exportCsvHint,
    required this.exportJson,
    required this.exportJsonHint,
    required this.exportEmpty,
    required this.importJson,
    required this.importJsonHint,
    required this.importDone,
    required this.importInvalid,
    // settings: deleting data
    required this.deleteSection,
    required this.deleteUserData,
    required this.deleteUserDataHint,
    required this.deleteAllData,
    required this.deleteAllDataHint,
    required this.deleteAlsoProfile,
    required this.deleteIrreversible,
    required this.deleteUserDataQ,
    required this.deleteAllDataQ,
    required this.deleteUnderstand,
    required this.deleteContinue,
    required this.deletedUserData,
    required this.deletedAllData,
    // settings: language, about
    required this.languageSection,
    required this.languageFollowsPhone,
    required this.aboutSection,
    required this.version,
    required this.privacy,
    required this.privacyBody,
    // profile editor
    required this.newProfile,
    required this.editProfile,
    required this.name,
    required this.gender,
    required this.male,
    required this.female,
    required this.heightCm,
    required this.birthday,
    required this.refWeight,
    required this.pickDate,
    required this.errName,
    required this.errHeight,
    required this.errBirthday,
    required this.errNumber,
    required this.deleteProfileQ,
  });

  /// The language's own name for itself, e.g. "Deutsch".
  final String languageName;

  final String mWeight;
  final String mBmi;
  final String mFat;
  final String mSkelMuscle;
  final String mMuscleMass;
  final String mWater;
  final String mProtein;
  final String mBone;
  final String mLeanMass;
  final String mSubcutFat;
  final String mVisceral;
  final String mBmr;
  final String mBodyScore;
  final String mBodyAge;
  final String mBodyShape;
  final String impedance;
  final String years;

  /// Body shape 1..9.
  final Map<int, String> bodyShapes;

  final String helpTitle;
  final String helpHint;
  final String helpIntro;
  final String hWeight;
  final String hBmi;
  final String hFat;
  final String hSkelMuscle;
  final String hMuscleMass;
  final String hWater;
  final String hProtein;
  final String hBone;
  final String hLeanMass;
  final String hSubcutFat;
  final String hVisceral;
  final String hBmr;
  final String hBodyScore;
  final String hBodyAge;
  final String hBodyShape;
  final String hImpedance;

  final String whyTitle;
  final String whyIntro;
  final String whyName;
  final String whyGender;
  final String whyBirthday;
  final String whyHeight;
  final String whyRefWeight;
  final String whyStorage;

  final String fmtTitle;
  final String fmtIntro;
  final String fmtStructure;
  final String fmtStructureBody;
  final String fmtProfiles;
  final String fmtMeasurements;
  final String fmtRequired;
  final String fmtOptional;
  final String fmtRules;
  final String fmtRulesBody;
  final String fmtExample;
  final String fmtCopy;
  final String fmtCopied;

  /// Field name -> explanation, for the import file format page.
  final Map<String, String> fieldDocs;

  final String appearanceSection;
  final String themeLight;
  final String themeDark;
  final String themeSystem;

  final String cancel;
  final String save;
  final String delete;
  final String close;
  final String share;
  final String ok;
  final String loadError;

  final String obTitle;
  final String obBody;
  final String obStart;

  final String newMeasurement;
  final String statistics;
  final String allMeasurements;
  final String settings;
  final String lastMeasurements;
  final String trends;
  final String noMeasurements;

  final String phasePreparing;
  final String phaseScanning;
  final String phaseConnecting;
  final String phaseWaitingLive;
  final String phaseWaitingSync;
  final String phaseWeighing;
  final String measurementSaved;
  final String weightOnlyNote;
  final String syncNothing;
  final String Function(int n) syncSaved;
  final String Function(String name) looksLike;
  final String Function(String name) reassignTo;
  final String retry;
  final Map<ScaleError, String> scaleErrors;
  final String openAppSettings;

  final String period7d;
  final String period30d;
  final String period90d;
  final String period1y;
  final String periodAll;
  final String periodCustom;
  final String metricsFilter;
  final String chartLine;
  final String chartBar;
  final String chartScatter;
  final String noDataInPeriod;

  final String measurement;
  final String reassign;
  final String deleteMeasurementQ;

  final String scaleSection;
  final String scaleNone;
  final String scaleFind;
  final String scaleName;
  final String scaleDefaultName;
  final String scaleAlreadySaved;
  final String Function(String name) scaleForgetQ;
  final String scaleSearching;
  final String scaleNoneFound;

  final String usersSection;
  final String addProfile;
  final String measuringSection;
  final String doneSound;
  final String doneSoundHint;

  final String dataSection;
  final String exportCsv;
  final String exportCsvHint;
  final String exportJson;
  final String exportJsonHint;
  final String exportEmpty;
  final String importJson;
  final String importJsonHint;
  final String Function(int profiles, int measurements) importDone;
  final String importInvalid;

  final String deleteSection;
  final String deleteUserData;
  final String deleteUserDataHint;
  final String deleteAllData;
  final String deleteAllDataHint;
  final String deleteAlsoProfile;
  final String deleteIrreversible;
  final String Function(String name, int measurements, bool alsoProfile)
  deleteUserDataQ;
  final String deleteAllDataQ;
  final String deleteUnderstand;
  final String deleteContinue;
  final String Function(String name) deletedUserData;
  final String deletedAllData;

  final String languageSection;
  final String languageFollowsPhone;
  final String aboutSection;
  final String version;
  final String privacy;
  final String privacyBody;

  final String newProfile;
  final String editProfile;
  final String name;
  final String gender;
  final String male;
  final String female;
  final String heightCm;
  final String birthday;
  final String refWeight;
  final String pickDate;
  final String errName;
  final String errHeight;
  final String errBirthday;
  final String errNumber;
  final String Function(String name) deleteProfileQ;

  String scaleError(ScaleError e) => scaleErrors[e]!;
}

/// Supported languages; the first one is the fallback.
final Map<String, Strings> languages = {
  'en': stringsEn,
  'bg': stringsBg,
  'de': stringsDe,
  'es': stringsEs,
  'fr': stringsFr,
};

/// The first of the phone's preferred languages that the app supports,
/// otherwise English.
String resolveLanguage(List<Locale> preferred) {
  for (final l in preferred) {
    if (languages.containsKey(l.languageCode)) return l.languageCode;
  }
  return languages.keys.first;
}

String _language = languages.keys.first;

/// Code of the language the UI currently uses, e.g. "de".
String get currentLanguage => _language;

void setLanguage(String code) {
  assert(languages.containsKey(code));
  _language = code;
}

/// The texts in the current language.
Strings get S => languages[_language]!;
