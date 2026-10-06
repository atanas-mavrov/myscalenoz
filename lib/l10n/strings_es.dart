import '../ble/scale_service.dart';
import 'strings.dart';

final stringsEs = Strings(
  languageName: 'Español',
  mWeight: 'Peso',
  mBmi: 'IMC',
  mFat: 'Grasa corporal',
  mSkelMuscle: 'Músculo esquelético',
  mMuscleMass: 'Masa muscular',
  mWater: 'Agua corporal',
  mProtein: 'Proteína',
  mBone: 'Masa ósea',
  mLeanMass: 'Masa magra',
  mSubcutFat: 'Grasa subcutánea',
  mVisceral: 'Grasa visceral (nivel)',
  mBmr: 'Metabolismo basal',
  mBodyScore: 'Puntuación',
  mBodyAge: 'Edad corporal',
  mBodyShape: 'Tipo de cuerpo',
  impedance: 'Impedancia',
  years: 'años',
  bodyShapes: {
    1: 'Obesidad oculta',
    2: 'Falta de ejercicio',
    3: 'Delgado',
    4: 'Estándar',
    5: 'Delgado y musculoso',
    6: 'Obesidad',
    7: 'Sobrepeso',
    8: 'Estándar musculoso',
    9: 'Muy musculoso',
  },
  helpTitle: 'Qué significan los valores',
  helpHint: 'Toque un valor para ver su explicación.',
  helpIntro:
      'Todo excepto el peso es una estimación: la báscula hace pasar '
      'una corriente débil por los pies, mide la resistencia (impedancia) y '
      'una fórmula la combina con su altura, edad y sexo. Los valores sirven '
      'para seguir la evolución en el tiempo y no son un diagnóstico médico. '
      'Pésese descalzo y a la misma hora del día.',
  hWeight:
      'El peso corporal en kilogramos — el único valor que la báscula '
      'mide directamente.',
  hBmi:
      'Índice de masa corporal: el peso dividido por la altura en metros '
      'al cuadrado. Por debajo de 18,5 — bajo peso, 18,5–25 — normal, por '
      'encima de 25 — sobrepeso. No distingue entre músculo y grasa.',
  hFat:
      'La parte del peso que es grasa. El algoritmo considera estándar '
      'alrededor del 16 % en hombres y del 26 % en mujeres, con un rango '
      'normal de ±5 puntos.',
  hSkelMuscle:
      'La parte del peso que es músculo según la fórmula de la '
      'báscula (masa magra sin hueso, por 0,68 en hombres y 0,62 en '
      'mujeres). Sale más alta que los valores médicos de músculo esquelético '
      '(normalmente 33–40 % en hombres), así que fíjese en la evolución, no '
      'en la cifra absoluta.',
  hMuscleMass:
      'El peso sin grasa y sin hueso, en kilogramos — músculos, '
      'órganos y el agua que contienen.',
  hWater:
      'La parte del peso que es agua. Se calcula a partir de la masa '
      'magra; baja con la deshidratación y al aumentar la grasa.',
  hProtein:
      'La parte del peso que son proteínas — lo que queda tras la '
      'grasa, el hueso y el agua.',
  hBone:
      'Masa ósea estimada en kilogramos (alrededor del 5–6 % de la masa '
      'magra). No es una medición de densidad ósea.',
  hLeanMass:
      'Masa magra (libre de grasa): el peso menos la grasa, en '
      'kilogramos.',
  hSubcutFat:
      'La grasa bajo la piel como porcentaje del peso — la parte de '
      'la grasa total que no está alrededor de los órganos internos.',
  hVisceral:
      'Nivel de grasa alrededor de los órganos internos en una escala '
      'de 1 a 30 — no tiene unidad. Interpretación habitual: hasta 9 — '
      'normal, 10–14 — elevado, 15 o más — alto.',
  hBmr:
      'Metabolismo basal: cuántas kilocalorías al día gasta el cuerpo en '
      'reposo absoluto. Se calcula a partir de la masa magra (370 + 21,6 × '
      'masa magra en kg).',
  hBodyScore:
      'Una puntuación global de 0 a 100 — la media de tres '
      'subpuntuaciones: cuánto se acerca su peso al peso estándar para su '
      'altura, su IMC a 22 y su grasa al estándar (16 % hombres, 26 % '
      'mujeres). 100 significa exactamente en esos ideales.',
  hBodyAge:
      'Una «edad corporal» orientativa derivada de la puntuación: menor '
      'que su edad real si la puntuación es alta y mayor si es baja. El '
      'mínimo es 18.',
  hBodyShape:
      'Uno de nueve tipos según el IMC y la grasa corporal — por '
      'ejemplo «Estándar», «Delgado y musculoso» u «Obesidad oculta» (peso '
      'normal pero grasa alta).',
  hImpedance:
      'La medición en bruto: la resistencia del cuerpo en ohmios a '
      '50 kHz y 500 kHz. A partir de ella y del peso se calcula todo lo '
      'demás. Falta si llevaba calcetines o zapatos.',
  whyTitle: 'Por qué necesitamos estos datos',
  whyIntro:
      'La báscula solo mide el peso y la resistencia eléctrica del '
      'cuerpo. Para convertirlos en grasa, músculo, agua y los demás '
      'valores, la fórmula necesita algunos datos sobre usted.',
  whyName:
      'Solo para distinguir a los usuarios si varias personas comparten '
      'la báscula. Puede ser un apodo.',
  whyGender:
      'Hombres y mujeres distribuyen la grasa, el músculo y el agua de '
      'forma distinta, por eso la fórmula usa coeficientes y estándares '
      'diferentes (p. ej. alrededor del 16 % de grasa en hombres y del 26 % '
      'en mujeres).',
  whyBirthday:
      'La edad forma parte de la fórmula de la grasa y de la edad '
      'corporal. Pedimos la fecha de nacimiento en lugar de la edad para que '
      'siga siendo correcta con el tiempo sin que tenga que actualizarla.',
  whyHeight:
      'La corriente recorre el cuerpo a lo largo, así que la altura '
      'es un dato clave de la fórmula. También se usa para el IMC y el peso '
      'estándar.',
  whyRefWeight:
      'Opcional. Su peso habitual — solo se usa para avisar cuando '
      'una medición parece de otro usuario.',
  whyStorage:
      'Los datos se guardan solo en este teléfono. La aplicación no '
      'tiene cuentas y no envía nada por internet.',
  fmtTitle: 'Formato del archivo de importación',
  fmtIntro: 'La importación acepta un archivo JSON (UTF-8). Una copia hecha con «Copia de seguridad (JSON)» se importa tal cual. También puede preparar usted mismo un archivo así, por ejemplo para traer mediciones de otra aplicación o de una hoja de cálculo.',
  fmtStructure: 'Estructura',
  fmtStructureBody: 'Un objeto con dos listas: «profiles» (usuarios) y «measurements» (mediciones). Las demás claves («format», «version», «exportedAt») las escribe la aplicación y se ignoran al importar.',
  fmtProfiles: 'Usuario (profiles)',
  fmtMeasurements: 'Medición (measurements)',
  fmtRequired: 'obligatorio',
  fmtOptional: 'opcional',
  fmtRules: 'Reglas de importación',
  fmtRulesBody: '• Los datos existentes nunca se modifican ni se eliminan: el archivo se añade a ellos.\n• Un usuario con el mismo nombre, sexo, altura y fecha de nacimiento se considera el mismo usuario.\n• Una medición con el mismo usuario, hora, peso e impedancia se omite, así que importar dos veces el mismo archivo no añade nada.\n• Si el archivo no es válido, no se importa nada.\n• El separador decimal es el punto (78.6).',
  fmtExample: 'Ejemplo',
  fmtCopy: 'Copiar el ejemplo',
  fmtCopied: 'Ejemplo copiado.',
  fieldDocs: {
    'id': 'Cualquier número entero, único en el archivo. Solo sirve para vincular las mediciones con el usuario.',
    'name': 'Nombre del usuario.',
    'gender': 'Sexo: "male" (hombre) o "female" (mujer).',
    'height_cm': 'Altura en centímetros.',
    'birthday': 'Fecha de nacimiento como AAAA-MM-DD.',
    'ref_weight_kg': 'Peso habitual en kg.',
    'created_at': 'Cuándo se creó el usuario (ISO 8601). Si falta, el momento de la importación.',
    'profile_id': 'El «id» de un usuario del mismo archivo.',
    'timestamp_utc': 'Cuándo se midió, p. ej. "2026-10-01T07:30:00Z". Con «Z» la hora es UTC; sin ella, la hora local del teléfono.',
    'weight_kg': 'Peso en kilogramos.',
    'r50': 'Impedancia a 50 kHz en ohmios. 0 o ausente: solo peso.',
    'r500': 'Impedancia a 500 kHz en ohmios.',
    'source': 'Etiqueta libre sobre el origen.',
    'composition': 'Los campos de composición corporal (fat_pct, water_pct, bmr, etc.) son opcionales. Los valores presentes en el archivo se importan tal cual, también sin impedancia (p. ej. ya calculados por otra aplicación). Los que faltan se calculan al importar a partir del perfil del usuario, como en una medición nueva; sin impedancia solo se calcula el IMC.',
  },
  appearanceSection: 'Apariencia',
  themeLight: 'Claro',
  themeDark: 'Oscuro',
  themeSystem: 'Como el teléfono',
  cancel: 'Cancelar',
  save: 'Guardar',
  delete: 'Eliminar',
  close: 'Cerrar',
  share: 'Compartir',
  ok: 'Aceptar',
  loadError: 'Error al cargar',
  obTitle: 'Bienvenido',
  obBody:
      'Introduzca sus datos para crear el primer perfil. La aplicación '
      'los usa para calcular su composición corporal a partir de la medición '
      'de la báscula.',
  obStart: 'Empezar',
  newMeasurement: 'Nueva medición',
  statistics: 'Estadísticas',
  allMeasurements: 'Todas las mediciones',
  settings: 'Ajustes',
  lastMeasurements: 'Mediciones recientes',
  trends: 'Tendencias',
  noMeasurements: 'Aún no hay mediciones.',
  phasePreparing: 'Preparando…',
  phaseScanning:
      'Súbase descalzo a la báscula; la aplicación se conectará sola.',
  phaseConnecting: 'Conectando…',
  phaseWaitingLive:
      'Conectada. Si aún no lo ha hecho, súbase descalzo a la báscula.',
  phaseWaitingSync: 'Conectada. Leyendo las mediciones disponibles…',
  phaseWeighing: 'Midiendo… Quédese quieto.',
  measurementSaved: 'Medición guardada.',
  weightOnlyNote:
      'La báscula no midió la impedancia (¿pies descalzos?) — '
      'solo se guardó el peso.',
  syncNothing: 'No hay mediciones nuevas de la báscula.',
  syncSaved: (n) =>
      n == 1 ? '1 medición guardada.' : '$n mediciones guardadas.',
  looksLike: (name) =>
      'Este peso está lejos del habitual de este usuario. '
      '¿Es de $name?',
  reassignTo: (name) => 'Pasar a $name',
  retry: 'Reintentar',
  scaleErrors: {
    ScaleError.unsupported: 'Este dispositivo no tiene Bluetooth LE.',
    ScaleError.bluetoothOff:
        'El Bluetooth está desactivado. Actívelo e inténtelo de nuevo.',
    ScaleError.permissionDenied:
        'Se necesita el permiso de Bluetooth '
        '(«Dispositivos cercanos»). Concédalo en los ajustes de la '
        'aplicación.',
    ScaleError.notFound:
        'No se encontró la báscula. Despiértela con un '
        'toque del pie e inténtelo de nuevo.',
    ScaleError.connectFailed:
        'No se pudo conectar con la báscula. Inténtelo de nuevo.',
    ScaleError.serviceMissing:
        'La báscula aún no está lista para medir. '
        'Despiértela con un toque del pie e inténtelo de nuevo.',
    ScaleError.noData:
        'La báscula no envió ninguna medición. Súbase '
        'descalzo e inténtelo de nuevo.',
  },
  openAppSettings: 'Ajustes de la aplicación',
  period7d: '7 días',
  period30d: '30 días',
  period90d: '3 meses',
  period1y: '1 año',
  periodAll: 'Todo',
  periodCustom: 'Elegir…',
  metricsFilter: 'Valores',
  chartLine: 'Línea',
  chartBar: 'Barras',
  chartScatter: 'Puntos',
  noDataInPeriod: 'No hay datos para el periodo seleccionado.',
  measurement: 'Medición',
  reassign: 'Pasar a otro usuario',
  deleteMeasurementQ: '¿Eliminar esta medición?',
  scaleSection: 'Básculas',
  scaleNone:
      'No hay básculas guardadas — la aplicación se conecta a la '
      'primera que encuentra.',
  scaleFind: 'Añadir báscula',
  scaleName: 'Nombre de la báscula',
  scaleDefaultName: 'Báscula',
  scaleAlreadySaved: 'ya guardada',
  scaleForgetQ: (name) => '¿Quitar «$name»?',
  scaleSearching: 'Buscando… Despierte la báscula con un toque del pie.',
  scaleNoneFound: 'No se encontró ninguna báscula.',
  usersSection: 'Usuarios',
  addProfile: 'Añadir usuario',
  measuringSection: 'Medición',
  doneSound: 'Sonidos',
  doneSoundHint: 'Una campanilla cuando la medición ha terminado y puede bajarse de la báscula',
  dataSection: 'Exportar e importar',
  exportCsv: 'Exportar a CSV',
  exportCsvHint:
      'Una tabla para Excel y similares. No se puede volver a '
      'importar.',
  exportJson: 'Copia de seguridad (JSON)',
  exportJsonHint:
      'Una copia completa de usuarios y mediciones — como copia '
      'de seguridad o para pasar a otro teléfono.',
  exportEmpty: 'No hay mediciones para exportar.',
  importJson: 'Importar copia de seguridad',
  importJsonHint:
      'Añade los usuarios y mediciones de una copia de seguridad '
      '(JSON). Los datos existentes se conservan; los duplicados se omiten.',
  importDone: (p, m) => 'Importado: $p usuarios nuevos, $m mediciones.',
  importInvalid:
      'Este archivo no es una copia de seguridad de esta '
      'aplicación.',
  deleteSection: 'Eliminar datos',
  deleteUserData: 'Eliminar los datos de un usuario',
  deleteUserDataHint:
      'Las mediciones de un usuario y, si lo desea, el '
      'propio usuario',
  deleteAllData: 'Eliminar todos los datos',
  deleteAllDataHint: 'Todos los usuarios, mediciones, básculas y ajustes',
  deleteAlsoProfile: 'Eliminar también el usuario',
  deleteIrreversible:
      'Esta acción no se puede deshacer. Si quiere conservar '
      'los datos, haga primero una copia de seguridad.',
  deleteUserDataQ: (name, n, alsoProfile) => alsoProfile
      ? '¿Eliminar el usuario «$name» y sus $n mediciones?'
      : '¿Eliminar las $n mediciones de «$name»? El usuario se conserva.',
  deleteAllDataQ:
      '¿Eliminar TODOS los datos de la aplicación — usuarios, '
      'mediciones, básculas guardadas y ajustes?',
  deleteUnderstand: 'Entiendo que los datos se eliminarán para siempre',
  deleteContinue: 'Continuar',
  deletedUserData: (name) => 'Se eliminaron los datos de «$name».',
  deletedAllData: 'Se eliminaron todos los datos.',
  languageSection: 'Idioma',
  languageFollowsPhone: 'Sigue el idioma del teléfono',
  aboutSection: 'Acerca de',
  version: 'Versión',
  privacy: 'Privacidad',
  privacyBody:
      'Todos los datos (usuarios y mediciones) se guardan solo en '
      'este dispositivo. La aplicación no envía nada por la red y no tiene '
      'cuentas. Los datos salen del teléfono solo cuando usted decide '
      'exportarlos o compartirlos.',
  newProfile: 'Nuevo usuario',
  editProfile: 'Editar usuario',
  name: 'Nombre',
  gender: 'Sexo',
  male: 'Hombre',
  female: 'Mujer',
  heightCm: 'Altura (cm)',
  birthday: 'Fecha de nacimiento',
  refWeight: 'Peso habitual (kg, opcional)',
  pickDate: 'Elegir fecha',
  errName: 'Introduzca un nombre',
  errHeight: 'Altura entre 100 y 250 cm',
  errBirthday: 'Elija la fecha de nacimiento',
  errNumber: 'Número no válido',
  deleteProfileQ: (name) =>
      '¿Eliminar a «$name» junto con todas sus '
      'mediciones?',
);
