import 'package:easy_localization/easy_localization.dart';

/// 🌍 Çoklu Dil Destekli String Sınıfı
/// 
/// Kullanım: AppStrings.appName (otomatik olarak seçili dile göre döner)
/// 
/// Desteklenen Diller:
/// - Türkçe (tr-TR) - Varsayılan
/// - İngilizce (en-US)
class AppStrings {
  // App Info
  static String get appName => 'appName'.tr();
  static String get appTagline => 'appTagline'.tr();
  
  // Main Screen
  static String get howDoYouWantToFeel => 'howDoYouWantToFeel'.tr();
  static String get chooseYourMood => 'chooseYourMood'.tr();
  
  // Mood Types
  static String get relaxation => 'relaxation'.tr();
  static String get focus => 'focus'.tr();
  static String get sleep => 'sleep'.tr();
  
  // Mood Descriptions
  static String get relaxationDesc => 'relaxationDesc'.tr();
  static String get focusDesc => 'focusDesc'.tr();
  static String get sleepDesc => 'sleepDesc'.tr();
  
  // Navigation
  static String get home => 'home'.tr();
  static String get breathing => 'breathing'.tr();
  static String get sounds => 'sounds'.tr();
  static String get journeys => 'journeys'.tr();
  static String get sleepMode => 'sleepMode'.tr();
  static String get profile => 'profile'.tr();
  
  // Breathing Exercises
  static String get breathingExercises => 'breathingExercises'.tr();
  static String get breatheIn => 'breatheIn'.tr();
  static String get breatheOut => 'breatheOut'.tr();
  static String get start => 'start'.tr();
  static String get pause => 'pause'.tr();
  static String get stop => 'stop'.tr();
  static String get resume => 'resume'.tr();
  
  // Breathing Techniques
  static String get boxBreathing => 'boxBreathing'.tr();
  static String get breathing478 => 'breathing478'.tr();
  static String get deepBreathing => 'deepBreathing'.tr();
  static String get calmingBreath => 'calmingBreath'.tr();
  
  // Breathing Descriptions
  static String get breathing478Desc => 'breathing478Desc'.tr();
  static String get deepBreathingDesc => 'deepBreathingDesc'.tr();
  static String get calmingBreathDesc => 'calmingBreathDesc'.tr();
  
  // Sounds
  static String get relaxingSounds => 'relaxingSounds'.tr();
  static String get natureSounds => 'natureSounds'.tr();
  static String get rain => 'rain'.tr();
  static String get ocean => 'ocean'.tr();
  static String get forest => 'forest'.tr();
  static String get fireplace => 'fireplace'.tr();
  static String get whitenoise => 'whitenoise'.tr();
  static String get lofi => 'lofi'.tr();
  static String get timer => 'timer'.tr();
  static String get volume => 'volume'.tr();
  
  // Sleep Mode
  static String get sleepModeTitle => 'sleepModeTitle'.tr();
  static String get createSleepAtmosphere => 'createSleepAtmosphere'.tr();
  static String get sleepTimer => 'sleepTimer'.tr();
  static String get goodNight => 'goodNight'.tr();
  
  // Profile
  static String get settings => 'settings'.tr();
  static String get theme => 'theme'.tr();
  static String get notifications => 'notifications'.tr();
  static String get dailyReminder => 'dailyReminder'.tr();
  static String get statistics => 'statistics'.tr();
  static String get dailyGoal => 'dailyGoal'.tr();
  static String get totalSessions => 'totalSessions'.tr();
  static String get totalMinutes => 'totalMinutes'.tr();
  static String get currentStreak => 'currentStreak'.tr();
  
  // Time
  static String get minutes => 'minutes'.tr();
  static String get seconds => 'seconds'.tr();
  static String get hour => 'hour'.tr();
  static String get day => 'day'.tr();
  static String get week => 'week'.tr();
  static String get month => 'month'.tr();
  
  // Common
  static String get ok => 'ok'.tr();
  static String get cancel => 'cancel'.tr();
  static String get save => 'save'.tr();
  static String get delete => 'delete'.tr();
  static String get edit => 'edit'.tr();
  static String get done => 'done'.tr();
  static String get loading => 'loading'.tr();
  static String get error => 'error'.tr();
  static String get retry => 'retry'.tr();
  static String get noData => 'noData'.tr();
  
  // Onboarding
  static String get welcome => 'welcome'.tr();
  static String get welcomeMessage => 'welcomeMessage'.tr();
  static String get getStarted => 'getStarted'.tr();
  static String get skip => 'skip'.tr();
  static String get next => 'next'.tr();
  static String get previous => 'previous'.tr();
  
  // Permissions
  static String get permissionRequired => 'permissionRequired'.tr();
  static String get notificationPermission => 'notificationPermission'.tr();
  static String get audioPermission => 'audioPermission'.tr();
  static String get grantPermission => 'grantPermission'.tr();
  
  // Premium
  static String get premium => 'premium'.tr();
  static String get upgradeToPremium => 'upgradeToPremium'.tr();
  static String get premiumFeatures => 'premiumFeatures'.tr();
  static String get unlockAllFeatures => 'unlockAllFeatures'.tr();
  static String get adFree => 'adFree'.tr();
  static String get moreSounds => 'moreSounds'.tr();
  static String get advancedBreathing => 'advancedBreathing'.tr();
  static String get aiRecommendations => 'aiRecommendations'.tr();
  
  // Greetings
  static String get morningGreeting => 'morningGreeting'.tr();
  static String get afternoonGreeting => 'afternoonGreeting'.tr();
  static String get eveningGreeting => 'eveningGreeting'.tr();
  static String get nightGreeting => 'nightGreeting'.tr();
  
  // Hero Cards
  static String get energeticStart => 'energeticStart'.tr();
  static String get energeticStartDesc => 'energeticStartDesc'.tr();
  static String get lunchBreak => 'lunchBreak'.tr();
  static String get lunchBreakDesc => 'lunchBreakDesc'.tr();
  static String get eveningRelax => 'eveningRelax'.tr();
  static String get eveningRelaxDesc => 'eveningRelaxDesc'.tr();
  static String get sleepPrep => 'sleepPrep'.tr();
  static String get sleepPrepDesc => 'sleepPrepDesc'.tr();
  
  // Discover Section
  static String get discover => 'discover'.tr();
  static String get boxBreathingTitle => 'boxBreathingTitle'.tr();
  static String get boxBreathingSubtitle => 'boxBreathingSubtitle'.tr();
  static String get forestSounds => 'forestSounds'.tr();
  static String get forestSoundsSubtitle => 'forestSoundsSubtitle'.tr();
  static String get binauralBeats => 'binauralBeats'.tr();
  static String get binauralBeatsSubtitle => 'binauralBeatsSubtitle'.tr();
  
  // Weekly Summary
  static String get thisWeek => 'thisWeek'.tr();
  static String get activitySummary => 'activitySummary'.tr();
  static String get sessions => 'sessions'.tr();
  static String get breath => 'breath'.tr();
  static String get sound => 'sound'.tr();
  
  // Motivational
  static String get todaysInspiration => 'todaysInspiration'.tr();
  static String get fiveMinutes => 'fiveMinutes'.tr();
  
  // Mood Selector
  static String get whatDoYouWantToDo => 'whatDoYouWantToDo'.tr();
  static String get relaxationMood => 'relaxationMood'.tr();
  static String get calmnessMood => 'calmnessMood'.tr();
  static String get sleepMood => 'sleepMood'.tr();
  static String get personalRecommendations => 'personalRecommendations'.tr();
  
  // Motivational Messages
  static String get letsStart => 'letsStart'.tr();
  static String firstSessionPrompt(String activity) => 'firstSessionPrompt'.tr(args: [activity]);
  static String get greatStart => 'greatStart'.tr();
  static String get goingSuperb => 'goingSuperb'.tr();
  static String get amazingWeek => 'amazingWeek'.tr();
  
  // Breathing Exercises
  static String get awarenessBreath => 'awarenessBreath'.tr();
  static String get forestSoundsTitle => 'forestSoundsTitle'.tr();
  static String get forestSoundsDesc => 'forestSoundsDesc'.tr();
  static String get extendedExhale => 'extendedExhale'.tr();
  static String get extendedExhaleDesc => 'extendedExhaleDesc'.tr();
  static String get heavyRainTitle => 'heavyRainTitle'.tr();
  static String get heavyRainDesc => 'heavyRainDesc'.tr();
  static String get slowingBreath => 'slowingBreath'.tr();
  static String get nightCrickets => 'nightCrickets'.tr();
  static String get nightCricketsDesc => 'nightCricketsDesc'.tr();
  static String get campfireTitle => 'campfireTitle'.tr();
  static String get campfireDesc => 'campfireDesc'.tr();
  static String get lightRainTitle => 'lightRainTitle'.tr();
  static String get lightRainDesc => 'lightRainDesc'.tr();
  
  // Breathing Screen
  static String get howManyCycles => 'howManyCycles'.tr();
  static String get cycles => 'cycles'.tr();
  static String startCycles(int count) => 'startCycles'.tr(args: [count.toString()]);
  static String get backgroundSound => 'backgroundSound'.tr();
  static String get silence => 'silence'.tr();
  
  // Weekly Summary Details
  static String get session => 'session'.tr();
  static String get breathActivity => 'breathActivity'.tr();
  static String get soundActivity => 'soundActivity'.tr();
  
  // Error Messages
  static String get connectionError => 'connectionError'.tr();
  static String get checkConnection => 'checkConnection'.tr();
  static String get audioPlaybackError => 'audioPlaybackError'.tr();
  static String audioFailedToPlay(String sound) => 'audioFailedToPlay'.tr(args: [sound]);
  static String get tryAgain => 'tryAgain'.tr();
  
  // Breathing Categories
  static String get focusAndConcentration => 'focusAndConcentration'.tr();
  static String get focusAndConcentrationDesc => 'focusAndConcentrationDesc'.tr();
  static String get relaxationAndPeace => 'relaxationAndPeace'.tr();
  static String get relaxationAndPeaceDesc => 'relaxationAndPeaceDesc'.tr();
  static String get peacefulSleep => 'peacefulSleep'.tr();
  static String get energyAndVitality => 'energyAndVitality'.tr();
  static String get energyAndVitalityDesc => 'energyAndVitalityDesc'.tr();
  
  // Statistics
  static String get dailyStreak => 'dailyStreak'.tr();
  static String get weeklyGoalLabel => 'weeklyGoalLabel'.tr();
  static String get completed => 'completed'.tr();
  static String get goingGreat => 'goingGreat'.tr();
  static String get letsGetStarted => 'letsGetStarted'.tr();
  
  // Profile Screen
  static String get settingsTitle => 'settingsTitle'.tr();
  static String get settingsSubtitle => 'settingsSubtitle'.tr();
  static String get notificationSettings => 'notificationSettings'.tr();
  static String get notificationsOn => 'notificationsOn'.tr();
  static String get notificationsOff => 'notificationsOff'.tr();
  static String get dailyReminderMessage => 'dailyReminderMessage'.tr();
  static String get reminders => 'reminders'.tr();
  static String get dailyRemindersActive => 'dailyRemindersActive'.tr();
  static String get notificationsClosed => 'notificationsClosed'.tr();
  static String get notificationInfo => 'notificationInfo'.tr();
  static String get healthWarning => 'healthWarning'.tr();
  static String get healthWarningSubtitle => 'healthWarningSubtitle'.tr();
  static String get privacyPolicy => 'privacyPolicy'.tr();
  static String get privacyPolicySubtitle => 'privacyPolicySubtitle'.tr();
  static String get termsOfService => 'termsOfService'.tr();
  static String get termsOfServiceSubtitle => 'termsOfServiceSubtitle'.tr();
  static String get contact => 'contact'.tr();
  static String get contactSubtitle => 'contactSubtitle'.tr();
  static String get about => 'about'.tr();
  static String get version => 'version'.tr();
  static String get myFavorites => 'myFavorites'.tr();
  
  // Explore Screen
  static String get breathingExercisesTitle => 'breathingExercisesTitle'.tr();
  static String get breathingExercisesSubtitle => 'breathingExercisesSubtitle'.tr();
  static String get allExercises => 'allExercises'.tr();
  static String get allExercisesSubtitle => 'allExercisesSubtitle'.tr();
  static String get boxBreathingShort => 'boxBreathingShort'.tr();
  static String get boxBreathingShortDesc => 'boxBreathingShortDesc'.tr();
  static String get slowingBreathShort => 'slowingBreathShort'.tr();
  static String get slowingBreathShortDesc => 'slowingBreathShortDesc'.tr();
  static String get diaphragmBreath => 'diaphragmBreath'.tr();
  static String get soundCollection => 'soundCollection'.tr();
  static String get soundCollectionSubtitle => 'soundCollectionSubtitle'.tr();
  static String get allSounds => 'allSounds'.tr();
  static String get allSoundsSubtitle => 'allSoundsSubtitle'.tr();
  static String get forSleep => 'forSleep'.tr();
  static String get forSleepSubtitle => 'forSleepSubtitle'.tr();
  static String get meditationRelaxation => 'meditationRelaxation'.tr();
  static String get meditationRelaxationSubtitle => 'meditationRelaxationSubtitle'.tr();
  static String get focusWork => 'focusWork'.tr();
  static String get focusWorkSubtitle => 'focusWorkSubtitle'.tr();
  static String get sleepTracking => 'sleepTracking'.tr();
  static String get sleepTrackingSubtitle => 'sleepTrackingSubtitle'.tr();
  static String get sleepAnalysisSubtitle => 'sleepAnalysisSubtitle'.tr();
  static String get sleepJournal => 'sleepJournal'.tr();
  static String get sleepJournalSubtitle => 'sleepJournalSubtitle'.tr();
  static String get sleepStories => 'sleepStories'.tr();
  static String get sleepStoriesSubtitle => 'sleepStoriesSubtitle'.tr();
  static String get comingSoon => 'comingSoon'.tr();
  
  // Sleep Analytics
  static String get sleepAnalysisTitle => 'sleepAnalysisTitle'.tr();
  static String get weeklyTrend => 'weeklyTrend'.tr();
  static String get excellent => 'excellent'.tr();
  static String get good => 'good'.tr();
  static String get fair => 'fair'.tr();
  static String get poor => 'poor'.tr();
  static String get noSleepData => 'noSleepData'.tr();
  static String get startTrackingSleep => 'startTrackingSleep'.tr();
  static String get addSleepData => 'addSleepData'.tr();
  
  // Sleep Journal
  static String get sleepJournalTitle => 'sleepJournalTitle'.tr();
  static String get addEntry => 'addEntry'.tr();
  static String get editEntry => 'editEntry'.tr();
  static String get selectDate => 'selectDate'.tr();
  static String get howDidYouSleep => 'howDidYouSleep'.tr();
  static String get sleepNotes => 'sleepNotes'.tr();
  static String get sleepNotesHint => 'sleepNotesHint'.tr();
  static String get dreams => 'dreams'.tr();
  static String get dreamsHint => 'dreamsHint'.tr();
  static String get mood => 'mood'.tr();
  static String get great => 'great'.tr();
  static String get tired => 'tired'.tr();
  static String get bad => 'bad'.tr();
  static String get neutral => 'neutral'.tr();
  static String get saveEntry => 'saveEntry'.tr();
  static String get deleteEntry => 'deleteEntry'.tr();
  static String get noJournalEntries => 'noJournalEntries'.tr();
  static String get startJournaling => 'startJournaling'.tr();
  
  // Common Actions
  static String get close => 'close'.tr();
  static String get confirm => 'confirm'.tr();
  static String get back => 'back'.tr();
  static String get continueText => 'continue_'.tr();
  static String get apply => 'apply'.tr();
  static String get reset => 'reset'.tr();
  static String get clear => 'clear'.tr();
  static String get search => 'search'.tr();
  static String get filter => 'filter'.tr();
  static String get sort => 'sort'.tr();
  static String get share => 'share'.tr();
  static String get exportText => 'export'.tr();
  static String get importText => 'import'.tr();
  
  // Profile Screen - Dialogs
  static String get breatheFlowApp => 'breatheFlowApp'.tr();
  static String get notificationsActive => 'notificationsActive'.tr();
  static String get favoriteSoundsAndExercises => 'favoriteSoundsAndExercises'.tr();
  static String soundsAndExercisesCount(int sounds, int exercises) => 
      'soundsAndExercisesCount'.tr(args: [sounds.toString(), exercises.toString()]);
  static String get noFavoriteContent => 'noFavoriteContent'.tr();
  static String get aboutDescription => 'aboutDescription'.tr();
  static String get copyright => 'copyright'.tr();
  
  // Privacy Policy
  static String get dataCollectionAndUsage => 'dataCollectionAndUsage'.tr();
  static String get dataCollectionDesc => 'dataCollectionDesc'.tr();
  static String get storedData => 'storedData'.tr();
  static String get storedDataList => 'storedDataList'.tr();
  static String get notificationsTitle => 'notificationsTitle'.tr();
  static String get notificationsDesc => 'notificationsDesc'.tr();
  static String get adsTitle => 'adsTitle'.tr();
  static String get adsDesc => 'adsDesc'.tr();
  
  // Terms of Service
  static String get serviceUsage => 'serviceUsage'.tr();
  static String get serviceUsageDesc => 'serviceUsageDesc'.tr();
  static String get medicalDisclaimer => 'medicalDisclaimer'.tr();
  static String get medicalDisclaimerDesc => 'medicalDisclaimerDesc'.tr();
  static String get userResponsibilities => 'userResponsibilities'.tr();
  static String get userResponsibilitiesDesc => 'userResponsibilitiesDesc'.tr();
  static String get intellectualProperty => 'intellectualProperty'.tr();
  static String get intellectualPropertyDesc => 'intellectualPropertyDesc'.tr();
  
  // Health Warning
  static String get importantHealthInfo => 'importantHealthInfo'.tr();
  static String get healthWarningTitle1 => 'healthWarningTitle1'.tr();
  static String get healthWarningDesc1 => 'healthWarningDesc1'.tr();
  static String get healthWarningTitle2 => 'healthWarningTitle2'.tr();
  static String get healthWarningDesc2 => 'healthWarningDesc2'.tr();
  static String get healthWarningTitle3 => 'healthWarningTitle3'.tr();
  static String get healthWarningDesc3 => 'healthWarningDesc3'.tr();
  static String get healthWarningTitle4 => 'healthWarningTitle4'.tr();
  static String get healthWarningDesc4 => 'healthWarningDesc4'.tr();
  
  // Contact
  static String get contactUs => 'contactUs'.tr();
  static String get feedbackAndSupport => 'feedbackAndSupport'.tr();
  static String get feedbackDesc => 'feedbackDesc'.tr();
  static String get email => 'email'.tr();
  static String get supportEmail => 'supportEmail'.tr();
  static String get responseTime => 'responseTime'.tr();
  static String get responseTimeDesc => 'responseTimeDesc'.tr();
  static String get contactMessage => 'contactMessage'.tr();
  static String get feedbackValuable => 'feedbackValuable'.tr();
  static String get understood => 'understood'.tr();
  
  // Login Screen
  static String get loginFailed => 'loginFailed'.tr();
  static String loginError(String error) => 'loginError'.tr(args: [error]);
  static String get welcomeBack => 'welcomeBack'.tr();
  static String get continueJourney => 'continueJourney'.tr();
  static String get emailAddress => 'emailAddress'.tr();
  static String get emailPlaceholder => 'emailPlaceholder'.tr();
  static String get emailRequired => 'emailRequired'.tr();
  static String get emailInvalid => 'emailInvalid'.tr();
  static String get password => 'password'.tr();
  static String get passwordPlaceholder => 'passwordPlaceholder'.tr();
  static String get passwordRequired => 'passwordRequired'.tr();
  static String get passwordMinLength => 'passwordMinLength'.tr();
  static String get forgotPassword => 'forgotPassword'.tr();
  static String get loginButton => 'loginButton'.tr();
  static String get noAccountYet => 'noAccountYet'.tr();
  static String get signUpButton => 'signUpButton'.tr();
  
  // Main Navigation
  static String get navHome => 'navHome'.tr();
  static String get navExplore => 'navExplore'.tr();
  static String get navProfile => 'navProfile'.tr();
  
  // Signup Screen
  static String get signupFailed => 'signupFailed'.tr();
  static String get joinUs => 'joinUs'.tr();
  static String get startJourney => 'startJourney'.tr();
  static String get fullName => 'fullName'.tr();
  static String get fullNamePlaceholder => 'fullNamePlaceholder'.tr();
  static String get fullNameRequired => 'fullNameRequired'.tr();
  static String get fullNameMinLength => 'fullNameMinLength'.tr();
  static String get confirmPassword => 'confirmPassword'.tr();
  static String get confirmPasswordRequired => 'confirmPasswordRequired'.tr();
  static String get passwordsNotMatch => 'passwordsNotMatch'.tr();
  static String get signUpNow => 'signUpNow'.tr();
  static String get alreadyHaveAccount => 'alreadyHaveAccount'.tr();
  static String get loginNow => 'loginNow'.tr();
  
  // Breathing Step Types
  static String get inhale => 'inhale'.tr();
  static String get hold => 'hold'.tr();
  static String get exhale => 'exhale'.tr();
  static String get holdAfterExhale => 'holdAfterExhale'.tr();
  
  // Premium Dialog
  static String get laterButton => 'laterButton'.tr();
  static String get dontShowAgainButton => 'dontShowAgainButton'.tr();
  static String get billingNotAvailable => 'billingNotAvailable'.tr();
  static String get productDetailsNotFound => 'productDetailsNotFound'.tr();
  static String get purchaseCannotStart => 'purchaseCannotStart'.tr();
  static String get exploreButton => 'exploreButton'.tr();
  static String get unlockWithPremium => 'unlockWithPremium'.tr();
  
  // Sound Card
  static String get mixButton => 'mixButton'.tr();
  static String get premiumLabel => 'premiumLabel'.tr();
  static String get proBadge => 'proBadge'.tr();
  
  // Theme
  static String get darkTheme => 'darkTheme'.tr();
  static String get lightTheme => 'lightTheme'.tr();
  static String get themeSelection => 'themeSelection'.tr();
  static String get systemSetting => 'systemSetting'.tr();
  
  // Mixer Panel
  static String get stopAllButton => 'stopAllButton'.tr();
  
  // Session Completion
  static String get thankYouMessage => 'thankYouMessage'.tr();
  static String get continueButton => 'continueButton'.tr();
  
  // Sleep Stats
  static String get sleepDebt => 'sleepDebt'.tr();
  static String get sleepAnalysis => 'sleepAnalysis'.tr();
  static String get averageSleep => 'averageSleep'.tr();
  static String get saveTodayButton => 'saveTodayButton'.tr();
  static String get viewAnalysisButton => 'viewAnalysisButton'.tr();
}
