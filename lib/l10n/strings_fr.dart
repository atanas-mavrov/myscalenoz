import '../ble/scale_service.dart';
import 'strings.dart';

final stringsFr = Strings(
  languageName: 'Français',
  mWeight: 'Poids',
  mBmi: 'IMC',
  mFat: 'Masse grasse',
  mSkelMuscle: 'Muscle squelettique',
  mMuscleMass: 'Masse musculaire',
  mWater: 'Eau corporelle',
  mProtein: 'Protéines',
  mBone: 'Masse osseuse',
  mLeanMass: 'Masse maigre',
  mSubcutFat: 'Graisse sous-cutanée',
  mVisceral: 'Graisse viscérale (niveau)',
  mBmr: 'Métabolisme de base',
  mBodyScore: 'Score',
  mBodyAge: 'Âge corporel',
  mBodyShape: 'Morphologie',
  impedance: 'Impédance',
  years: 'ans',
  bodyShapes: {
    1: 'Obésité cachée',
    2: 'Manque d\'exercice',
    3: 'Mince',
    4: 'Standard',
    5: 'Mince et musclé',
    6: 'Obésité',
    7: 'Surpoids',
    8: 'Standard musclé',
    9: 'Très musclé',
  },
  helpTitle: 'Ce que signifient les valeurs',
  helpHint: 'Touchez une valeur pour une explication.',
  helpIntro:
      'Tout sauf le poids est une estimation : la balance fait passer '
      'un faible courant par les pieds, mesure la résistance (impédance) et '
      'une formule la combine avec votre taille, votre âge et votre sexe. Les '
      'valeurs servent à suivre l\'évolution dans le temps et ne constituent '
      'pas un diagnostic médical. Pesez-vous pieds nus, à la même heure de la '
      'journée.',
  hWeight:
      'Le poids corporel en kilogrammes — la seule valeur que la balance '
      'mesure directement.',
  hBmi:
      'Indice de masse corporelle : le poids divisé par le carré de la '
      'taille en mètres. Moins de 18,5 — insuffisance pondérale, 18,5–25 — '
      'normal, plus de 25 — surpoids. Il ne distingue pas le muscle de la '
      'graisse.',
  hFat:
      'La part du poids constituée de graisse. L\'algorithme considère '
      'comme standard environ 16 % chez l\'homme et 26 % chez la femme, avec '
      'une plage normale de ±5 points.',
  hSkelMuscle:
      'La part du poids constituée de muscle selon la formule de la '
      'balance (masse maigre sans les os, multipliée par 0,68 chez l\'homme '
      'et 0,62 chez la femme). Elle est plus élevée que les valeurs médicales '
      'de muscle squelettique (en général 33–40 % chez l\'homme) : suivez '
      'l\'évolution plutôt que le chiffre absolu.',
  hMuscleMass:
      'Le poids sans la graisse ni les os, en kilogrammes — '
      'muscles, organes et l\'eau qu\'ils contiennent.',
  hWater:
      'La part du poids constituée d\'eau. Elle est calculée à partir de '
      'la masse maigre ; elle baisse en cas de déshydratation et quand la '
      'masse grasse augmente.',
  hProtein:
      'La part du poids constituée de protéines — ce qui reste après '
      'la graisse, les os et l\'eau.',
  hBone:
      'Masse osseuse estimée en kilogrammes (environ 5–6 % de la masse '
      'maigre). Ce n\'est pas une mesure de densité osseuse.',
  hLeanMass: 'Masse maigre : le poids moins la graisse, en kilogrammes.',
  hSubcutFat:
      'La graisse sous la peau en pourcentage du poids — la part de '
      'la graisse totale qui ne se trouve pas autour des organes internes.',
  hVisceral:
      'Niveau de graisse autour des organes internes sur une échelle '
      'de 1 à 30 — sans unité. Interprétation courante : jusqu\'à 9 — '
      'normal, 10–14 — élevé, 15 et plus — très élevé.',
  hBmr:
      'Métabolisme de base : combien de kilocalories par jour le corps '
      'dépense au repos complet. Calculé à partir de la masse maigre (370 + '
      '21,6 × masse maigre en kg).',
  hBodyScore:
      'Un score global de 0 à 100 — la moyenne de trois sous-scores : '
      'la proximité de votre poids avec le poids standard pour votre taille, '
      'de votre IMC avec 22 et de votre masse grasse avec la norme (16 % '
      'hommes, 26 % femmes). 100 signifie exactement ces valeurs idéales.',
  hBodyAge:
      'Un « âge corporel » indicatif déduit du score : inférieur à '
      'votre âge réel si le score est élevé, supérieur s\'il est bas. Le '
      'minimum est 18.',
  hBodyShape:
      'Un des neuf types selon l\'IMC et la masse grasse — par '
      'exemple « Standard », « Mince et musclé » ou « Obésité cachée » (poids '
      'normal mais masse grasse élevée).',
  hImpedance:
      'La mesure brute : la résistance du corps en ohms à 50 kHz et '
      '500 kHz. Tout le reste est calculé à partir d\'elle et du poids. '
      'Absente si vous portiez des chaussettes ou des chaussures.',
  whyTitle: 'Pourquoi nous avons besoin de ces données',
  whyIntro:
      'La balance mesure seulement le poids et la résistance électrique '
      'du corps. Pour en déduire la masse grasse, les muscles, l\'eau et les '
      'autres valeurs, la formule a besoin de quelques informations sur '
      'vous.',
  whyName:
      'Seulement pour distinguer les utilisateurs si plusieurs personnes '
      'partagent la balance. Un surnom suffit.',
  whyGender:
      'Chez l\'homme et chez la femme, la graisse, les muscles et '
      'l\'eau se répartissent différemment ; la formule utilise donc des '
      'coefficients et des normes différents (par ex. environ 16 % de masse '
      'grasse chez l\'homme et 26 % chez la femme).',
  whyBirthday:
      'L\'âge entre dans la formule de la masse grasse et dans '
      'l\'âge corporel. Nous demandons la date de naissance plutôt que l\'âge '
      'pour qu\'il reste juste avec le temps sans que vous ayez à le mettre à '
      'jour.',
  whyHeight:
      'Le courant traverse le corps sur toute sa longueur, la taille '
      'est donc une donnée clé de la formule. Elle sert aussi à l\'IMC et au '
      'poids standard.',
  whyRefWeight:
      'Facultatif. Votre poids habituel — utilisé uniquement pour '
      'signaler qu\'une mesure semble appartenir à un autre utilisateur.',
  whyStorage:
      'Les données sont stockées uniquement sur ce téléphone. '
      'L\'application n\'a pas de compte et n\'envoie rien sur internet.',
  fmtTitle: 'Format du fichier d\'import',
  fmtIntro: 'L\'import accepte un fichier JSON (UTF-8). Une sauvegarde faite avec « Sauvegarde (JSON) » s\'importe telle quelle. Vous pouvez aussi préparer vous-même un tel fichier, par exemple pour reprendre des mesures d\'une autre application ou d\'un tableur.',
  fmtStructure: 'Structure',
  fmtStructureBody: 'Un objet avec deux listes : « profiles » (utilisateurs) et « measurements » (mesures). Les autres clés (« format », « version », « exportedAt ») sont écrites par l\'application et ignorées à l\'import.',
  fmtProfiles: 'Utilisateur (profiles)',
  fmtMeasurements: 'Mesure (measurements)',
  fmtRequired: 'obligatoire',
  fmtOptional: 'facultatif',
  fmtRules: 'Règles d\'import',
  fmtRulesBody: '• Les données existantes ne sont jamais modifiées ni supprimées : le fichier s\'y ajoute.\n• Un utilisateur avec les mêmes nom, sexe, taille et date de naissance est considéré comme le même utilisateur.\n• Une mesure avec les mêmes utilisateur, heure, poids et impédance est ignorée ; importer deux fois le même fichier n\'ajoute donc rien.\n• Si le fichier n\'est pas valide, rien n\'est importé.\n• Le séparateur décimal est le point (78.6).',
  fmtExample: 'Exemple',
  fmtCopy: 'Copier l\'exemple',
  fmtCopied: 'Exemple copié.',
  fieldDocs: {
    'id': 'Un entier quelconque, unique dans le fichier. Sert uniquement à relier les mesures à l\'utilisateur.',
    'name': 'Nom de l\'utilisateur.',
    'gender': 'Sexe : "male" (homme) ou "female" (femme).',
    'height_cm': 'Taille en centimètres.',
    'birthday': 'Date de naissance au format AAAA-MM-JJ.',
    'ref_weight_kg': 'Poids habituel en kg.',
    'created_at': 'Date de création de l\'utilisateur (ISO 8601). Absente : le moment de l\'import.',
    'profile_id': 'L\'« id » d\'un utilisateur du même fichier.',
    'timestamp_utc': 'Moment de la mesure, p. ex. "2026-10-01T07:30:00Z". Avec « Z », l\'heure est en UTC ; sans, c\'est l\'heure locale du téléphone.',
    'weight_kg': 'Poids en kilogrammes.',
    'r50': 'Impédance à 50 kHz en ohms. 0 ou absente : poids seul.',
    'r500': 'Impédance à 500 kHz en ohms.',
    'source': 'Libellé libre sur l\'origine.',
    'composition': 'Les champs de composition corporelle (fat_pct, water_pct, bmr, etc.) sont facultatifs. Les valeurs présentes dans le fichier sont importées telles quelles, même sans impédance (par ex. déjà calculées par une autre application). Les valeurs manquantes sont calculées à l\'import à partir du profil de l\'utilisateur, comme pour une nouvelle mesure ; sans impédance, seul l\'IMC est calculé.',
  },
  appearanceSection: 'Apparence',
  themeLight: 'Clair',
  themeDark: 'Sombre',
  themeSystem: 'Comme le téléphone',
  cancel: 'Annuler',
  save: 'Enregistrer',
  delete: 'Supprimer',
  close: 'Fermer',
  share: 'Partager',
  ok: 'OK',
  loadError: 'Erreur de chargement',
  obTitle: 'Bienvenue',
  obBody:
      'Saisissez vos informations pour créer le premier profil. '
      'L\'application s\'en sert pour calculer votre composition corporelle à '
      'partir de la mesure de la balance.',
  obStart: 'Commencer',
  newMeasurement: 'Nouvelle mesure',
  statistics: 'Statistiques',
  allMeasurements: 'Toutes les mesures',
  settings: 'Réglages',
  lastMeasurements: 'Mesures récentes',
  trends: 'Tendances',
  noMeasurements: 'Aucune mesure pour l\'instant.',
  phasePreparing: 'Préparation…',
  phaseScanning: 'Montez pieds nus sur la balance — l\'application se connecte toute seule.',
  phaseConnecting: 'Connexion…',
  phaseWaitingLive:
      'Connectée. Si ce n\'est pas déjà fait, montez pieds nus sur la balance.',
  phaseWaitingSync: 'Connectée. Lecture des mesures disponibles…',
  phaseWeighing: 'Mesure en cours… Ne bougez pas.',
  measurementSaved: 'Mesure enregistrée.',
  weightOnlyNote:
      'La balance n\'a pas mesuré l\'impédance (pieds nus ?) — '
      'seul le poids a été enregistré.',
  syncNothing: 'Aucune nouvelle mesure de la balance.',
  syncSaved: (n) =>
      n == 1 ? '1 mesure enregistrée.' : '$n mesures enregistrées.',
  looksLike: (name) =>
      'Ce poids est loin de l\'habitude de cet utilisateur. '
      'Est-ce $name ?',
  reassignTo: (name) => 'Attribuer à $name',
  retry: 'Réessayer',
  scaleErrors: {
    ScaleError.unsupported: 'Cet appareil n\'a pas de Bluetooth LE.',
    ScaleError.bluetoothOff:
        'Le Bluetooth est désactivé. Activez-le et réessayez.',
    ScaleError.permissionDenied:
        'L\'autorisation Bluetooth (« Appareils à '
        'proximité ») est nécessaire. Accordez-la dans les réglages de '
        'l\'application.',
    ScaleError.notFound:
        'Balance introuvable. Réveillez-la d\'une légère '
        'pression du pied et réessayez.',
    ScaleError.connectFailed:
        'Impossible de se connecter à la balance. Réessayez.',
    ScaleError.serviceMissing:
        'La balance n\'est pas encore prête. '
        'Réveillez-la d\'une légère pression du pied et réessayez.',
    ScaleError.noData:
        'La balance n\'a envoyé aucune mesure. Montez pieds '
        'nus et réessayez.',
  },
  openAppSettings: 'Réglages de l\'application',
  period7d: '7 jours',
  period30d: '30 jours',
  period90d: '3 mois',
  period1y: '1 an',
  periodAll: 'Tout',
  periodCustom: 'Choisir…',
  metricsFilter: 'Valeurs',
  chartLine: 'Ligne',
  chartBar: 'Barres',
  chartScatter: 'Points',
  noDataInPeriod: 'Aucune donnée pour la période choisie.',
  measurement: 'Mesure',
  reassign: 'Attribuer à un autre utilisateur',
  deleteMeasurementQ: 'Supprimer cette mesure ?',
  scaleSection: 'Balances',
  scaleNone:
      'Aucune balance enregistrée — l\'application se connecte à la '
      'première trouvée.',
  scaleFind: 'Ajouter une balance',
  scaleName: 'Nom de la balance',
  scaleDefaultName: 'Balance',
  scaleAlreadySaved: 'déjà enregistrée',
  scaleForgetQ: (name) => 'Retirer « $name » ?',
  scaleSearching:
      'Recherche… Réveillez la balance d\'une légère pression du '
      'pied.',
  scaleNoneFound: 'Aucune balance trouvée.',
  usersSection: 'Utilisateurs',
  addProfile: 'Ajouter un utilisateur',
  measuringSection: 'Mesure',
  doneSound: 'Sons',
  doneSoundHint: 'Un carillon quand la mesure est terminée et que vous pouvez descendre de la balance',
  dataSection: 'Export et import',
  exportCsv: 'Exporter en CSV',
  exportCsvHint:
      'Un tableau pour Excel et similaires. Ne peut pas être '
      'réimporté.',
  exportJson: 'Sauvegarde (JSON)',
  exportJsonHint:
      'Une copie complète des utilisateurs et des mesures — en '
      'sauvegarde ou pour passer à un autre téléphone.',
  exportEmpty: 'Aucune mesure à exporter.',
  importJson: 'Importer une sauvegarde',
  importJsonHint:
      'Ajoute les utilisateurs et les mesures d\'une sauvegarde '
      '(JSON). Les données existantes sont conservées ; les doublons sont '
      'ignorés.',
  importDone: (p, m) => 'Importé : $p nouveaux utilisateurs, $m mesures.',
  importInvalid: 'Ce fichier n\'est pas une sauvegarde de cette application.',
  deleteSection: 'Supprimer des données',
  deleteUserData: 'Supprimer les données d\'un utilisateur',
  deleteUserDataHint:
      'Les mesures d\'un utilisateur et, si vous le '
      'souhaitez, l\'utilisateur lui-même',
  deleteAllData: 'Supprimer toutes les données',
  deleteAllDataHint: 'Tous les utilisateurs, mesures, balances et réglages',
  deleteAlsoProfile: 'Supprimer aussi l\'utilisateur',
  deleteIrreversible:
      'Cette action est irréversible. Pour conserver les '
      'données, faites d\'abord une sauvegarde.',
  deleteUserDataQ: (name, n, alsoProfile) => alsoProfile
      ? 'Supprimer l\'utilisateur « $name » et ses $n mesures ?'
      : 'Supprimer les $n mesures de « $name » ? L\'utilisateur est conservé.',
  deleteAllDataQ:
      'Supprimer TOUTES les données de l\'application — '
      'utilisateurs, mesures, balances enregistrées et réglages ?',
  deleteUnderstand:
      'Je comprends que les données seront définitivement '
      'supprimées',
  deleteContinue: 'Continuer',
  deletedUserData: (name) => 'Les données de « $name » ont été supprimées.',
  deletedAllData: 'Toutes les données ont été supprimées.',
  languageSection: 'Langue',
  languageFollowsPhone: 'Suit la langue du téléphone',
  aboutSection: 'À propos',
  version: 'Version',
  privacy: 'Confidentialité',
  privacyBody:
      'Toutes les données (utilisateurs et mesures) sont stockées '
      'uniquement sur cet appareil. L\'application n\'envoie rien sur le '
      'réseau et n\'a pas de compte. Les données ne quittent le téléphone que '
      'si vous choisissez de les exporter ou de les partager.',
  newProfile: 'Nouvel utilisateur',
  editProfile: 'Modifier l\'utilisateur',
  name: 'Nom',
  gender: 'Sexe',
  male: 'Homme',
  female: 'Femme',
  heightCm: 'Taille (cm)',
  birthday: 'Date de naissance',
  refWeight: 'Poids habituel (kg, facultatif)',
  pickDate: 'Choisir une date',
  errName: 'Saisissez un nom',
  errHeight: 'Taille entre 100 et 250 cm',
  errBirthday: 'Choisissez la date de naissance',
  errNumber: 'Nombre non valide',
  deleteProfileQ: (name) => 'Supprimer « $name » avec toutes ses mesures ?',
);
