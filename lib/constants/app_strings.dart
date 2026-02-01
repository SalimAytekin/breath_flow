import 'package:easy_localization/easy_localization.dart';

/// 🌍 Çoklu Dil Destekli String Sınıfı
/// 
/// Tüm metinler artık seçili dile göre otomatik değişir.
/// Desteklenen Diller: Türkçe (tr-TR), İngilizce (en-US)
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
  
  // Sleep Screens
  static String get sleepDataEntry => 'sleepDataEntry'.tr();
  static String get sleepDataEdit => 'sleepDataEdit'.tr();
  static String get sleepTracking => 'sleepTracking'.tr();
  static String get sleepTrackingDesc => 'sleepTrackingDesc'.tr();
  static String get selectDateLabel => 'selectDateLabel'.tr();
  static String get sleptDuration => 'sleptDuration'.tr();
  static String get saveAndAnalyze => 'saveAndAnalyze'.tr();
  static String get editAndAnalyze => 'editAndAnalyze'.tr();
  static String get sleepSummary => 'sleepSummary'.tr();
  static String get sleepStatus => 'sleepStatus'.tr();
  static String get perfectSleep => 'perfectSleep'.tr();
  static String get sleepMinimumError => 'sleepMinimumError'.tr();
  static String get sleepMaximumError => 'sleepMaximumError'.tr();
  static String get existingEntryWarning => 'existingEntryWarning'.tr();
  static String get overwrite => 'overwrite'.tr();
  static String get bedTime => 'bedTime'.tr();
  static String get wakeTime => 'wakeTime'.tr();
  static String get sleepDuration => 'sleepDuration'.tr();
  static String get target => 'target'.tr();
  
  // Sleep Analysis
  static String get sleepAnalysisMainTitle => 'sleepAnalysisMainTitle'.tr();
  static String get sleepTrackingSummary => 'sleepTrackingSummary'.tr();
  static String get activeDaysRecord => 'activeDaysRecord'.tr();
  static String get clickToSeeAll => 'clickToSeeAll'.tr();
  static String get lookingTired => 'lookingTired'.tr();
  static String get sleepDeficit => 'sleepDeficit'.tr();
  static String get weeklyAdvice => 'weeklyAdvice'.tr();
  static String get weeklySleepDebt => 'weeklySleepDebt'.tr();
  static String get weeklyAverage => 'weeklyAverage'.tr();
  static String get thisWeek => 'thisWeek'.tr();
  static String get qualityScore => 'qualityScore'.tr();
  static String get closeToTarget => 'closeToTarget'.tr();
  static String get qualityScoreInfo => 'qualityScoreInfo'.tr();
  static String get weeklyTrendChart => 'weeklyTrendChart'.tr();
  static String get trackTrendsVisually => 'trackTrendsVisually'.tr();
  static String daysActiveFormat(int days, int total) => 'daysActiveFormat'.tr(args: [days.toString(), total.toString()]);
  static String get weeklyDebtInfoText => 'weeklyDebtInfoText'.tr();
  static String get proximityToTargetText => 'proximityToTargetText'.tr();
  static String get thisWeekRangeText => 'thisWeekRangeText'.tr();
  static String get sleepDebtAdvice => 'sleepDebtAdvice'.tr();
  static String hoursMinFormat(int hours, int minutes) => 'hoursMinFormat'.tr(args: [hours.toString(), minutes.toString()]);
  static String deficitFormat(String deficit) => 'deficitFormat'.tr(args: [deficit]);
  static String surplusFormat(String surplus) => 'surplusFormat'.tr(args: [surplus]);
  static String get onTargetText => 'onTargetText'.tr();
  static String get weeklyChartTitle => 'weeklyChartTitle'.tr();
  static String get last7DaysPerformanceText => 'last7DaysPerformance'.tr();
  static String get longestSleepLabel => 'longestSleepLabel'.tr();
  static String get shortestSleepLabel => 'shortestSleepLabel'.tr();
  static String get monthlySleepStatusTitle => 'monthlySleepStatusTitle'.tr();
  static String get legendIdealText => 'legendIdealText'.tr();
  static String get legendModerateText => 'legendModerateText'.tr();
  static String get legendPoorText => 'legendPoorText'.tr();
  static String get noDataText => 'noDataText'.tr();
  static String get seeRecordsAfter2DaysText => 'seeRecordsAfter2DaysText'.tr();
  static String get averageSleepLabelText => 'averageSleepLabel'.tr();
  static String get statusLabelText => 'statusLabel'.tr();
  static String get healthyStatusText => 'healthyStatus'.tr();
  static String get needsImprovementStatusText => 'needsImprovementStatus'.tr();
  static String get needMoreDataForAnalysisText => 'needMoreDataForAnalysis'.tr();
  static String get sleepRecordsTitleText => 'sleepRecordsTitle'.tr();
  static String get bestAndWorstPerformanceText => 'bestAndWorstPerformance'.tr();
  static String get dayMonText => 'dayMon'.tr();
  static String get dayTueText => 'dayTue'.tr();
  static String get dayWedText => 'dayWed'.tr();
  static String get dayThuText => 'dayThu'.tr();
  static String get dayFriText => 'dayFri'.tr();
  static String get daySatText => 'daySat'.tr();
  static String get daySunText => 'daySun'.tr();
  static String get legendInsufficientText => 'legendInsufficient'.tr();
  static String get targetLabelText => 'targetLabel'.tr();
  static String last30DaysFormatText(int days) => 'last30DaysFormat'.tr(args: [days.toString()]);
  static String get yourSleepPerformanceText => 'yourSleepPerformance'.tr();
  static String get mySleepRecordsText => 'mySleepRecords'.tr();
  static String get clickForDetailsText => 'clickForDetails'.tr();
  static String get idealSleepDurationText => 'idealSleepDuration'.tr();
  static String get idealSleepStatusText => 'idealSleepStatus'.tr();
  static String get insufficientSleepStatusText => 'insufficientSleepStatus'.tr();
  static String get bedTimeLabelText => 'bedTimeLabel'.tr();
  static String get wakeTimeLabelText => 'wakeTimeLabel'.tr();
  static String get deleteButtonText => 'deleteButton'.tr();
  static String get editButtonText => 'editButton'.tr();
  static String get closeButtonText => 'closeButton'.tr();
  static String get sleepJournalTitleText => 'sleepJournalTitle'.tr();
  static String get recordDreamsAndNotesText => 'recordDreamsAndNotes'.tr();
  static String get dateLabelText => 'dateLabel'.tr();
  static String get dreamNotesPlaceholderText => 'dreamNotesPlaceholder'.tr();
  static String get generalNotesPlaceholderText => 'generalNotesPlaceholder'.tr();
  static String get journalTipText => 'journalTip'.tr();
  static String get saveJournalButtonText => 'saveJournalButton'.tr();
  static String get pastRecordsTitleText => 'pastRecordsTitle'.tr();
  static String get dreamNotesLabelText => 'dreamNotesLabel'.tr();
  static String get generalNotesLabelText => 'generalNotesLabel'.tr();
  static String get greatMoodText => 'greatMood'.tr();
  static String get goodMoodText => 'goodMood'.tr();
  static String get neutralMoodText => 'neutralMood'.tr();
  static String get tiredMoodText => 'tiredMood'.tr();
  static String get badMoodText => 'badMood'.tr();
  static String get monthlySummaryTitle => 'monthlySummaryTitle'.tr();
  static String get monthlyStatsDesc => 'monthlyStatsDesc'.tr();
  static String get idealSleepMessage => 'idealSleepMessage'.tr();
  static String get tooLittleSleepMessage => 'tooLittleSleepMessage'.tr();
  static String get tooMuchSleepMessage => 'tooMuchSleepMessage'.tr();
  static String get targetHoursLabel => 'targetHoursLabel'.tr();
  static String get last30Days => 'last30Days'.tr();
  static String get healthySleeping => 'healthySleeping'.tr();
  static String get healthySleepingDesc => 'healthySleepingDesc'.tr();
  static String get unhealthySleepWarning => 'unhealthySleepWarning'.tr();
  static String get unhealthySleepDesc => 'unhealthySleepDesc'.tr();
  static String get urgentSleepWarning => 'urgentSleepWarning'.tr();
  static String get urgentSleepDesc => 'urgentSleepDesc'.tr();
  static String get onTargetButWarning => 'onTargetButWarning'.tr();
  static String get needMoreSleepHealth => 'needMoreSleepHealth'.tr();
  static String get tooMuchSleepWarning => 'tooMuchSleepWarning'.tr();
  static String get healthyRangeSleep => 'healthyRangeSleep'.tr();
  static String get needMoreSleepDeserve => 'needMoreSleepDeserve'.tr();
  static String get exceededTargetWarning => 'exceededTargetWarning'.tr();
  static String get perfectOnTarget => 'perfectOnTarget'.tr();
  static String get upgradeToPremiumBtn => 'upgradeToPremiumBtn'.tr();
  static String get pro => 'pro'.tr();
  
  // Sleep Journal
  static String get sleepJournal => 'sleepJournal'.tr();
  static String get sleepJournalDesc => 'sleepJournalDesc'.tr();
  static String get howDidYouFeel => 'howDidYouFeel'.tr();
  static String get dreamNotes => 'dreamNotes'.tr();
  static String get dreamNotesHint => 'dreamNotesHint'.tr();
  static String get generalNotes => 'generalNotes'.tr();
  static String get generalNotesHint => 'generalNotesHint'.tr();
  static String get moodGreat => 'moodGreat'.tr();
  static String get moodGood => 'moodGood'.tr();
  static String get moodNeutral => 'moodNeutral'.tr();
  static String get moodTired => 'moodTired'.tr();
  static String get moodBad => 'moodBad'.tr();
  
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
  static String get firstSessionPrompt => 'firstSessionPrompt'.tr();
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
  static String get startCycles => 'startCycles'.tr();
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
  static String get audioFailedToPlay => 'audioFailedToPlay'.tr();
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
  static String get sleepTrackingSubtitle => 'sleepTrackingSubtitle'.tr();
  static String get sleepAnalysisSubtitle => 'sleepAnalysisSubtitle'.tr();
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
  static String get continue_ => 'continue_'.tr();
  static String get apply => 'apply'.tr();
  static String get reset => 'reset'.tr();
  static String get clear => 'clear'.tr();
  static String get search => 'search'.tr();
  static String get filter => 'filter'.tr();
  static String get sort => 'sort'.tr();
  static String get share => 'share'.tr();
  static String get export => 'export'.tr();
  // ignore: non_constant_identifier_names
  static String get import_ => 'import'.tr();
  
  // Profile Screen - Dialogs
  static String get breatheFlowApp => 'breatheFlowApp'.tr();
  static String get notificationsActive => 'notificationsActive'.tr();
  static String get favoriteSoundsAndExercises => 'favoriteSoundsAndExercises'.tr();
  static String get soundsAndExercisesCount => 'soundsAndExercisesCount'.tr();
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
  
  // Terms of Service - Detailed
  static String get termsAcceptance => 'termsAcceptance'.tr();
  static String get appPurpose => 'appPurpose'.tr();
  static String get appPurposeDesc => 'appPurposeDesc'.tr();
  static String get disclaimerTitle => 'disclaimerTitle'.tr();
  static String get disclaimerDesc => 'disclaimerDesc'.tr();
  static String get contentUsage => 'contentUsage'.tr();
  static String get contentUsageDesc => 'contentUsageDesc'.tr();
  static String get premiumSubscription => 'premiumSubscription'.tr();
  static String get premiumSubscriptionDesc => 'premiumSubscriptionDesc'.tr();
  
  // Health Warning - Detailed
  static String get importantSafetyInfo => 'importantSafetyInfo'.tr();
  static String get aboutBreathingExercises => 'aboutBreathingExercises'.tr();
  static String get breathingExercisesWarning => 'breathingExercisesWarning'.tr();
  static String get sideEffects => 'sideEffects'.tr();
  static String get doNotUse => 'doNotUse'.tr();
  static String get contraindicationsList => 'contraindicationsList'.tr();
  static String get safeUsage => 'safeUsage'.tr();
  static String get safeUsageTips => 'safeUsageTips'.tr();
  static String get medicalToolDisclaimer => 'medicalToolDisclaimer'.tr();
  
  // Login Screen
  static String get loginFailed => 'loginFailed'.tr();
  static String get loginError => 'loginError'.tr();
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

  // Weekly Summary - This Week Label
  static String get thisWeekLabel => 'thisWeekLabel'.tr();
  
  // Weekly Summary - Motivational Messages
  static String get noSessionsBreathingPrompt => 'noSessionsBreathingPrompt'.tr();
  static String get noSessionsSoundPrompt => 'noSessionsSoundPrompt'.tr();
  static String firstSessionComplete(String activityName) => 'firstSessionComplete'.tr(args: [activityName]);
  static String fewSessionsMessage(int sessions) => 'fewSessionsMessage'.tr(args: [sessions.toString()]);
  static String manySessionsMessage(int sessions) => 'manySessionsMessage'.tr(args: [sessions.toString()]);
  static String championMessage(int sessions) => 'championMessage'.tr(args: [sessions.toString()]);

  static String get firstStepMessage => 'firstStepMessage'.tr();
  static String get greatStartBreathing => 'greatStartBreathing'.tr();
  static String get twoSessions => 'twoSessions'.tr();
  static String multipleSessions(int count) => 'multipleSessions'.tr(args: [count.toString()]);
  static String get keepGoingShort => 'keepGoingShort'.tr();

  // Premium Plans & Features
  static String get monthlyPlan => 'monthlyPlan'.tr();
  static String get yearlyPlan => 'yearlyPlan'.tr();
  static String get perMonth => 'perMonth'.tr();
  static String get perYear => 'perYear'.tr();
  static String get renewsMonthly => 'renewsMonthly'.tr();
  static String get yearlySavings => 'yearlySavings'.tr();
  static String get bestValueBadge => 'bestValueBadge'.tr();
  static String get featureAdFree => 'featureAdFree'.tr();
  static String get featureAllExercises => 'featureAllExercises'.tr();
  static String get featurePremiumSounds => 'featurePremiumSounds'.tr();
  static String get featureAdvancedAnalytics => 'featureAdvancedAnalytics'.tr();
  static String get premiumSuccessTitle => 'premiumSuccessTitle'.tr();
  static String get premiumSuccessMessage => 'premiumSuccessMessage'.tr();
  static String get restorePurchase => 'restorePurchase'.tr();
  static String get restoreSuccess => 'restoreSuccess'.tr();
  static String get startPremium => 'startPremium'.tr();
  static String get getSpecialOffer => 'getSpecialOffer'.tr();
  static String get purchaseStarted => 'purchaseStarted'.tr();

  // Weekly Summary Details
  static String get weeklyStatistics => 'weeklyStatistics'.tr();
  static String get weekDefinition => 'weekDefinition'.tr();
  static String get weekDefinitionDesc => 'weekDefinitionDesc'.tr();
  static String get sessionCount => 'sessionCount'.tr();
  static String get sessionCountDesc => 'sessionCountDesc'.tr();
  static String get totalMinutesLabel => 'totalMinutesLabel'.tr();
  static String get totalMinutesDesc => 'totalMinutesDesc'.tr();
  static String get understoodButton => 'understoodButton'.tr();

  // ============ ESKİ UYUMLULUK İÇİN CONST DEĞERLER ============
  // Bu değerler JSON'da olmayan veya özel formatlı metinler için
  
  // Explore Screen - Additional (const)
  static const String meditationRelaxationTitle = 'Meditasyon & Rahatlama';
  static const String focusWorkTitle = 'Odaklanma & Çalışma';
  static const String recordSleepData = 'Ne kadar uyuduğunu kaydet';
  static const String explorePageLabel = 'Keşfet sayfası';
  static const String allFeaturesHere = 'Tüm özellikler ve içerikler burada';
  static const String categoryLabel = '{title} kategorisi';
  static const String scrollHint = 'Yatay kaydırarak {count} farklı seçenek arasından gezinebilirsiniz';
  static const String exerciseNotFound = 'Egzersiz bulunamadı, tüm egzersizler sayfasına yönlendiriliyorsunuz';
  static const String startWithCycles = 'Başlat ({cycles} tekrar)';
  
  // Exercise Names (const)
  static const String boxBreathingExerciseName = 'Kutu Nefesi (4-4-4-4)';
  static const String slowingBreathExerciseName = 'Yavaşlatıcı Nefes';
  static const String diaphragmBreathExerciseName = 'Diyafram Nefesi';
  static const String extendedExhaleExerciseName = 'Uzunca Nefes Ver (4-6)';
  
  // Profile Screen - Additional
  static String get soundsLabel => 'soundsLabel'.tr();
  static String get exercisesLabel => 'exercisesLabel'.tr();
  static String soundsAndExercisesFormat(int sounds, int exercises) => 
      'soundsAndExercisesFormat'.tr(args: [sounds.toString(), exercises.toString()]);
  
  // Time Units
  static const String minutesShort = 'dk';
  static const String hoursShort = 'sa';
  
  // Breathing Screen (localized getters)
  static String get breathingExercisesScreenTitle => 'breathingExercisesScreenTitle'.tr();
  static String get focusAndConcentrationTitle => 'focusAndConcentrationTitle'.tr();
  static String get focusAndConcentrationSubtitle => 'focusAndConcentrationSubtitle'.tr();
  static String get relaxationAndPeaceTitle => 'relaxationAndPeaceTitle'.tr();
  static String get relaxationAndPeaceSubtitle => 'relaxationAndPeaceSubtitle'.tr();
  static String get peacefulSleepTitle => 'peacefulSleepTitle'.tr();
  static String get peacefulSleepSubtitle => 'peacefulSleepSubtitle'.tr();
  static String get energyAndVitalityTitle => 'energyAndVitalityTitle'.tr();
  static String get energyAndVitalitySubtitle => 'energyAndVitalitySubtitle'.tr();
  static String percentCompleted(int percent) => 'percentCompleted'.tr(args: [percent.toString()]);
  
  // Sleep Journal Screen - Additional (const - unique names)
  static const String sleepJournalScreenTitle = 'Uyku Günlüğü';
  static const String fillAtLeastOne = 'Lütfen rüya veya genel notlardan en az birini doldurun';
  static const String editMode = 'Düzenleme modu - Formu düzenleyip kaydedin';
  static const String recordDeleted = 'Kayıt silindi';
  
  // Sleep Analytics Screen - Additional (const)
  static const String deleteRecord = 'Kaydı Sil?';
  static const String confirmDeleteSleep = 'Bu uyku kaydını silmek istediğinize emin misiniz?';
  
  // Common Dialog Actions (const)
  static const String deleteButton = 'Sil';
  static const String editButton = 'Düzenle';
  static const String closeButton = 'Kapat';
  
  // Breathing Screen - Additional (localized getters)
  static String get loadingAd => 'loadingAd'.tr();
  static String get breathingExerciseDefault => 'breathingExerciseDefault'.tr();
  static String get selectYourNeed => 'selectYourNeed'.tr();
  static String todaySessionsCount(int count) => 'todaySessionsCount'.tr(args: [count.toString()]);
  static String get noSessionsToday => 'noSessionsToday'.tr();
  static String get dailyStreakLabel => 'dailyStreakLabel'.tr();
  static String get keepGoing => 'keepGoing'.tr();
  static String get letsBegin => 'letsBegin'.tr();
  static String cyclesProgress(int completed, int total) => 'cyclesProgress'.tr(args: [completed.toString(), total.toString()]);
  static String get selectBackgroundSound => 'selectBackgroundSound'.tr();
  static String get silenceOption => 'silenceOption'.tr();
  
  // Sleep Journal Screen - Complete (const - unique names only)
  static const String pastRecords = 'Geçmiş Kayıtlar';
  static const String sleepJournalMainTitle = 'Uyku Günlüğü';
  static const String recordDreamsAndNotes = 'Rüyalarını ve uyku notlarını kaydet';
  static const String dateLabel = 'Tarih';
  static const String writeDreamHere = 'Rüyanı buraya yaz...';
  static const String writeSleepQuality = 'Uyku kaliteni, gece uyanma sayını veya diğer gözlemlerini yaz...';
  static const String journalTip = 'İpucu: Düzenli günlük tutmak uyku kaliteni anlamana yardımcı olur';
  static const String saveChanges = 'Değişiklikleri Kaydet';
  static const String saveJournal = 'Günlüğü Kaydet';
  static const String monthJanuary = 'Ocak';
  static const String monthFebruary = 'Şubat';
  static const String monthMarch = 'Mart';
  static const String monthApril = 'Nisan';
  static const String monthMay = 'Mayıs';
  static const String monthJune = 'Haziran';
  static const String monthJuly = 'Temmuz';
  static const String monthAugust = 'Ağustos';
  static const String monthSeptember = 'Eylül';
  static const String monthOctober = 'Ekim';
  static const String monthNovember = 'Kasım';
  static const String monthDecember = 'Aralık';
  static const String selectDateTitle = 'Tarih Seç';
  static const String recordExistsTitle = 'Bu Tarihte Kayıt Var';
  static const String recordExistsMessage = '{date} tarihinde zaten bir günlük kaydınız var. Üzerine yazmak ister misiniz?';
  static const String journalUpdated = 'Günlük güncellendi! ✏️';
  static const String journalSaved = 'Günlük kaydedildi! 📝';
  static const String dreamNotesIcon = '💭 Rüya Notları';
  static const String generalNotesIcon = '📝 Genel Notlar';
  static const String deleteRecordTitle = 'Kaydı Sil';
  static const String confirmDeleteJournal = 'Bu günlük kaydını silmek istediğinize emin misiniz?';
  static const String pastRecordsTitle = 'Geçmiş Kayıtlar';
  static const String noRecordsYet = 'Henüz Kayıt Yok';
  static const String createFirstRecord = 'İlk günlük kaydını oluştur';
  
  // Sleep Analytics Screen - Complete (const - unique names only)
  static const String preparingAnalysis = 'Uyku Analiziniz Hazırlanıyor';
  static const String startAnalysisDesc = 'Uyku düzeninizi analiz etmeye başlamak için\nilk verinizi girin ve kişiselleştirilmiş\nönerilerinizi keşfedin.';
  static const String recordFirstSleep = 'İlk Uykunu Kaydet';
  static const String mySleepRecords = 'Uyku Kayıtlarım';
  static const String clickForDetails = 'Detay görmek için kayda tıkla';
  static const String noRecordsYetShort = 'Henüz kayıt yok';
  static const String idealSleep = 'İdeal Uyku ✓';
  static const String insufficientSleep = 'Yetersiz Uyku';
  static const String bedTimeLabel = 'Yatma Saati';
  static const String wakeTimeLabel = 'Uyanma Saati';
  static const String targetHours = 'Hedef: 8s';
  static const String idealSleepDuration = '✓ İdeal uyku süresi';
  static const String tryToSleepMore = '⚠️ Daha fazla uyumaya çalış';
  static const String sleptTooMuch = '⚠️ Çok fazla uyudun';
  static const String monthJan = 'Oca';
  static const String monthFeb = 'Şub';
  static const String monthMar = 'Mar';
  static const String monthApr = 'Nis';
  static const String monthMay2 = 'May';
  static const String monthJun = 'Haz';
  static const String monthJul = 'Tem';
  static const String monthAug = 'Ağu';
  static const String monthSep = 'Eyl';
  static const String monthOct = 'Eki';
  static const String monthNov = 'Kas';
  static const String monthDec = 'Ara';
  static const String dayMon = 'Pzt';
  static const String dayTue = 'Sal';
  static const String dayWed = 'Çar';
  static const String dayThu = 'Per';
  static const String dayFri = 'Cum';
  static const String daySat = 'Cmt';
  static const String daySun = 'Paz';
  static const String waitingForData = 'Veri Bekleniyor';
  static const String enterDataForDebt = 'Uyku borcu hesaplamak için veri girin.';
  static const String perfectBalance = 'Süpersin! Tam dengede uyuyorsun 🎯';
  static const String perfectBalanceDesc = 'Uyku süren hedefinde. Uyku düzenin harika, böyle devam et 🌟';
  static const String lookingTiredDesc = 'Bu hafta biraz uykun eksik kalmış. Yarın biraz erken yatmayı dene, kendini daha dinç hissedeceksin!';
  static const String sleepingTooMuch = 'Çok mu uyuyorsun? 🛌';
  static const String sleepingTooMuchDesc = 'Fazla uyku bazen daha çok yorar, 8 saat civarı tutmaya çalış';
  static const String weeklyDebtInfo = 'Haftalık uyku borcun (Pzt-Paz). Günlük ortalama 8 saat hedefe göre hesaplanır.';
  static const String thisWeekRange = 'Bu hafta (Pzt-Paz)';
  static const String proximityToTarget = 'Hedefe yakınlık';
  static const String weeklyChart = 'Haftalık Uyku Grafiği';
  static const String last7DaysPerformance = 'Son 7 günün uyku performansı';
  static const String legendIdeal = 'İdeal';
  static const String legendModerate = 'Orta';
  static const String legendInsufficient = 'Yetersiz';
  static const String noDataYet = 'Henüz veri yok';
  static const String noDataShort = 'Veri yok';
  static const String hoursMinutesFormat = '{hours}s {minutes}dk';
  static const String hoursShortLabel = '8s';
  static const String healthy = 'Sağlıklı';
  static const String needsImprovement = 'Geliştirilmeli';
  static const String monthlySleepStatus = 'Aylık Uyku Durumu';
  static const String last30DaysFormat = 'Son 30 gün • {days} gün aktif';
  static const String averageSleepLabel = 'Ortalama Uyku';
  static const String statusLabel = 'Durum';
  static const String needMoreDataForAnalysis = 'Daha doğru analiz için en az 7 gün veri gir.';
  static const String monthlyHealthyMessage = 'Aylık ortalamanız sağlıklı, böyle devam edin!';
  static const String monthlyNeedsImprovementMessage = 'Uyku sürenizi artırmaya çalışın.';
  static const String sleepRecords = 'Uyku Rekorları';
  static const String bestAndWorstPerformance = 'En iyi ve en kötü uyku performansın';
  static const String noSleepDataYet = 'Henüz hiç uyku verisi yok.';
  static const String needMoreDataForComparison = 'Karşılaştırma için daha fazla veri gerekli.';
  static const String seeRecordsAfter2Days = 'En az 2 gün veri girdiğinde rekorlarını görebilirsin';
  static const String longestSleep = 'En Uzun Uyku';
  static const String shortestSleep = 'En Kısa Uyku';
  static const String healthWarningTitle = 'Sağlık Uyarısı ⚠️';
  static const String standardTarget8Hours = 'Standart hedef 8 saat. Veri girdikçe kişiselleştirilecek.';
  static const String healthStatus = 'Sağlık Durumu';
  static const String healthyStatus = 'Sağlıklı';
  static const String standardTargetMessage = 'Standart hedef 8 saattir. Sağlığın için bu hedefe ulaşmaya çalış.';
  
  // Exercise List Screen (localized)
  static String get focusConcentrationDesc => 'focusConcentrationDesc'.tr();
  static String get relaxationPeaceDesc => 'relaxationPeaceDesc'.tr();
  static String get peacefulSleepDesc => 'peacefulSleepDesc'.tr();
  static String get energyVitalityDesc => 'energyVitalityDesc'.tr();
  
  // Exercise Descriptions (const)
  static const String boxBreathingDesc = 'Nefesini dört aşamada düzenle: al, tut, ver ve bekle. Zihinsel dengeyi artırır.';
  static const String simpleCountingBreathDesc = 'Nefes alırken ve verirken sayılara odaklan. Zihni toparlamaya yardımcı olur.';
  static const String awarenessBreathDesc = 'Nefesini doğal akışında gözlemle. Değiştirmeden sadece fark et.';
  static const String longExhaleDesc = 'Kısa al, uzun ver. Bu ritim sinir sistemini sakinleştirir.';
  static const String diaphragmBreathDesc = 'Nefesi karına doğru al. Göğüsten değil karından nefes almak stresi azaltır.';
  static const String equalBreathDesc = 'Nefesi aynı sürede alıp ver. Zihinsel denge ve iç huzur sağlar.';
  static String get slowingBreathDesc => 'slowingBreathDesc'.tr();
  static const String bodyAwarenessBreathDesc = 'Nefes alırken bedenine odaklan. Gerginlikleri fark et ve bırak.';
  static const String relaxationBreathDesc = 'Kısa nefes al, uzun nefes ver. Vücudun derin rahatlama yaşar.';
  static const String energizingDiaphragmDesc = 'Diyaframdan derin nefes alıp vermek bedene enerji kazandırır.';
  static const String morningBreathDesc = 'Güne derin ve canlı nefeslerle başla. Sabah enerjini yükseltir.';
  static const String dayStartBreathDesc = 'Pozitif enerjiyle nefes al, hafif şekilde ver. Güne hazırlar.';
  
  // Cycle Selection (localized getters)
  static String get howManyCyclesQuestion => 'howManyCyclesQuestion'.tr();
  static String get cyclesLabel => 'cyclesLabel'.tr();
  static String startWithCyclesFormat(int cycles) => 'startWithCyclesFormat'.tr(args: [cycles.toString()]);
  static String estimatedMinutes(int minutes) => 'estimatedMinutes'.tr(args: [minutes.toString()]);
  static String get secondsShort => 'secondsShort'.tr();
  
  // Favorites Screen
  static String get myFavoritesTitle => 'myFavoritesTitle'.tr();
  static String get breathLabel => 'breathLabel'.tr();
  static String get soundLabel => 'soundLabel'.tr();
  static const String noFavoriteExercises = 'Henüz Favori Egzersiz Yok';
  static const String addFavoriteExercises = 'Beğendiğiniz nefes egzersizlerini favorilere ekleyin';
  static const String exploreExercises = 'Egzersizleri Keşfet';
  static const String noFavoriteSounds = 'Henüz Favori Ses Yok';
  static const String addFavoriteSounds = 'Beğendiğiniz ses içeriklerini favorilere ekleyin';
  static const String exploreSounds = 'Sesleri Keşfet';
  static String get howManyMinutesQuestion => 'howManyMinutesQuestion'.tr();
  static String get minutesLabel => 'minutesLabel'.tr();
  static String startWithMinutesFormat(int minutes) => 'startWithMinutesFormat'.tr(args: [minutes.toString()]);
  static const String favoriteStats = 'Favori İstatistikleri';
  static const String breathingExercisesLabel = 'Nefes Egzersizleri';
  static const String soundContents = 'Ses İçerikleri';
  static const String totalFavorites = 'Toplam Favori';
  static const String closeLabel = 'Kapat';
  
  // Home Screen - Additional (const)
  static const String morningBreathName = 'Sabah Nefesi';
  static const String boxBreathingName = 'Kutu Nefesi (4-4-4-4)';
  static const String longExhaleName = 'Uzunca Nefes Ver (4-6)';
  static const String slowingBreathName = 'Yavaşlatıcı Nefes';
  static const String dailyGoalQuestion = 'Her gün kaç dakika aktivite yapmak istiyorsun?';
  static const String minutesUnit = 'dakika';
  static const String fiveMinutesShort = '5 dk';
  static const String sixtyMinutes = '60 dk';
  static const String saveButton = 'Kaydet';
  
  // Sleep Screen (const)
  static const String sleepSoundsTitle = 'Uyku Sesleri';
  static const String sleepSoundsDesc = 'Rahatlatıcı seslerle daha hızlı uykuya dalın.';
  
  // Notification Service (const)
  static const String notifBreathingTitle = 'Nefes Egzersizi Hatırlatması';
  static const String notifSleepTitle = 'Uyku Verisi Hatırlatması';
  static const String notifTestTitle = 'Breathe Flow Test';
  static const String notifChannelBreathing = 'Nefes Hatırlatmaları';
  static const String notifChannelBreathingDesc = 'Günlük nefes egzersizi hatırlatmaları';
  static const String notifChannelSleep = 'Uyku Verisi Hatırlatmaları';
  static const String notifChannelSleepDesc = 'Sabah uyku verisi girme hatırlatmaları';
  static const String notifChannelTest = 'Test Bildirimleri';
  static const String notifChannelTestDesc = 'Test amaçlı bildirimler';
  static const String notifBreathing1 = 'Bugün 5 dakikanı nefesine ayır 🌬️';
  static const String notifBreathing2 = 'Rahatla ve yenilenmek için nefes egzersizi yap 🧘';
  static const String notifBreathing3 = '5 dakika nefes egzersizi yaparak güne başla ☀️';
  static const String notifBreathing4 = 'Zihnini sakinleştirmek için nefes al 🫁';
  static const String notifBreathing5 = 'Stresi atmak için nefes egzersizi yap 💨';
  static const String notifBreathing6 = 'Odaklanmak için 5 dakika nefes al 🎯';
  static const String notifBreathing7 = 'Bedeni ve zihni dengelemek için nefes egzersizi yap ⚖️';
  static const String notifBreathing8 = 'Bugünkü nefes egzersizi hatırlatması 🧘‍♀️';
  static const String notifBreathing9 = 'Huzurlu bir gün için nefes egzersizi yap ✨';
  static const String notifBreathing10 = 'Enerjini toplamak için nefes al ⚡';
  static const String notifSleep1 = 'Dün kaçta yatıp kalktın? Uyku verilerini gir 📝';
  static const String notifSleep2 = 'Sabah uyku günlüğünü doldurmayı unutma 😴';
  static const String notifSleep3 = 'Gecenin nasıldı? Uyku verilerini kaydet 🌙';
  static const String notifSleep4 = 'Uyku kaliteni ve rüyalarını not al 💭';
  static const String notifSleep5 = 'Dün nasıl uyudun? Hadi kaydet 🌟';
  static const String notifSleep6 = 'Uyku günlüğünü doldurarak analiz oluştur 📊';
  static const String notifBedtime1 = 'İyi geceler! Huzurlu bir uyku dileriz 🌙';
  static const String notifBedtime2 = 'Rahatlamak için uyku sesleri dinle 😴';
  static const String notifBedtime3 = 'Düzenli uyku saatine geçiş zamanı! 🌟';
  static const String notifSound1 = 'Yatmadan önce sakinleştirici sesler dinle 🎵';
  static const String notifSound2 = 'Uykuya dalmana yardımcı olacak sesler var 🌊';
  static const String notifSound3 = 'Rahatlamak için doğa seslerini dinle 🏞️';
  static const String notifTestBody = 'Bildirim sistemi çalışıyor! 🎉';
  
  // A/B Test Service (const)
  static const String priceMonthly = '/ay';
  static const String priceYearly = '/yıl';
  static const String priceFree = 'ücretsiz';
  static const String priceTrialDays = 'gün';
  static const String priceTrial7Days = '7 gün ücretsiz';
  
  // Ad Container (const)
  static const String adPlaceholder = 'Reklam Alanı';
  
  // Sleep Analytics Screen - Additional (const)
  static const String sleepTrackingFormat = '{days} gün aktif • {total} toplam kayıt';
  static const String targetSleepTime = '8s 0dk';
  static const String gunAktif = 'gün aktif';
  static const String toplamKayit = 'toplam kayıt';
  
  // Empty State Widget (const)
  static const String emptyFavoriteSoundTitle = 'Henüz favori ses yok';
  static const String emptyFavoriteExerciseTitle = 'Henüz favori egzersiz yok';
  static const String emptyFavoriteSoundMessage = 'Keşfet sekmesinden beğendiğin sesleri favorilerine ekleyebilirsin';
  static const String emptyFavoriteExerciseMessage = 'Nefes egzersizlerinden favorilerini seç ve hızlıca erişebilsin';
  static const String exploreGoButton = 'Keşfet\'e Git';
  static const String noActivityTitle = 'Henüz aktivite yok';
  static const String noActivityMessage = 'İlk nefes egzersizini veya ses dinleme seansını başlat';
  static const String startNowButton = 'Hemen Başla';
  
  // Profile Photo Widget (const)
  static const String profilePhotoTitle = 'Profil Fotoğrafı';
  static const String takeFromCamera = 'Kameradan Çek';
  static const String chooseFromGallery = 'Galeriden Seç';
  static const String deletePhoto = 'Fotoğrafı Sil';
  
  // Sleep Stats Widget (const)
  static const String qualityPerfect = 'Mükemmel';
  static const String qualityGood = 'İyi';
  static const String qualityNeedsWork = 'Geliştirilmeli';
  static const String sleepQuality = 'Uyku Kalitesi';
  static const String weeklySleepChart = 'Haftalık Uyku Grafiği';
  static const String onTarget = 'Hedefte';
  static const String insufficient = 'Eksik';
  
  // Day abbreviations (const)
  static const String dayMonShort = 'Pzt';
  static const String dayTueShort = 'Sal';
  static const String dayWedShort = 'Çar';
  static const String dayThuShort = 'Per';
  static const String dayFriShort = 'Cum';
  static const String daySatShort = 'Cmt';
  static const String daySunShort = 'Paz';
  
  // Weekly Summary Card (const)
  static const String breathingExerciseActivity = 'nefes egzersizi';
  static const String soundListeningActivity = 'ses dinleme';

  // ===== ADDITIONAL LOCALIZED GETTERS =====
  
  // Profile Screen - Premium Section (yeni eklenenler)
  static String get unlimitedAccess => 'unlimitedAccess'.tr();
  static String get restorePurchases => 'restorePurchases'.tr();
  static String get restoringPurchases => 'restoringPurchases'.tr();
  static String get premiumRestored => 'premiumRestored'.tr();
  static String get noActiveSubscription => 'noActiveSubscription'.tr();
  
  // Premium Dialog - Trigger Messages
  static String get greatStartTitle => 'greatStartTitle'.tr();
  static String get continueWithPremium => 'continueWithPremium'.tr();

  // ===== BREATHING EXERCISES LOCALIZED DATA =====
  
  // Box Breathing
  static String get exerciseBoxBreathingName => 'exercise_box_breathing_name'.tr();
  static String get exerciseBoxBreathingDesc => 'exercise_box_breathing_desc'.tr();
  static String get exerciseBoxBreathingPurpose => 'exercise_box_breathing_purpose'.tr();
  static String get exerciseBoxBreathingStep1 => 'exercise_box_breathing_step1'.tr();
  static String get exerciseBoxBreathingStep2 => 'exercise_box_breathing_step2'.tr();
  static String get exerciseBoxBreathingStep3 => 'exercise_box_breathing_step3'.tr();
  static String get exerciseBoxBreathingStep4 => 'exercise_box_breathing_step4'.tr();
  
  // Simple Counting Breath
  static String get exerciseSimpleCountingName => 'exercise_simple_counting_name'.tr();
  static String get exerciseSimpleCountingDesc => 'exercise_simple_counting_desc'.tr();
  static String get exerciseSimpleCountingPurpose => 'exercise_simple_counting_purpose'.tr();
  static String get exerciseSimpleCountingStep1 => 'exercise_simple_counting_step1'.tr();
  static String get exerciseSimpleCountingStep2 => 'exercise_simple_counting_step2'.tr();
  
  // Awareness Breath
  static String get exerciseAwarenessName => 'exercise_awareness_name'.tr();
  static String get exerciseAwarenessDesc => 'exercise_awareness_desc'.tr();
  static String get exerciseAwarenessPurpose => 'exercise_awareness_purpose'.tr();
  static String get exerciseAwarenessStep1 => 'exercise_awareness_step1'.tr();
  static String get exerciseAwarenessStep2 => 'exercise_awareness_step2'.tr();
  
  // Extended Exhale
  static String get exerciseExtendedExhaleName => 'exercise_extended_exhale_name'.tr();
  static String get exerciseExtendedExhaleDesc => 'exercise_extended_exhale_desc'.tr();
  static String get exerciseExtendedExhalePurpose => 'exercise_extended_exhale_purpose'.tr();
  static String get exerciseExtendedExhaleStep1 => 'exercise_extended_exhale_step1'.tr();
  static String get exerciseExtendedExhaleStep2 => 'exercise_extended_exhale_step2'.tr();
  
  // Diaphragm Breathing
  static String get exerciseDiaphragmName => 'exercise_diaphragm_name'.tr();
  static String get exerciseDiaphragmDesc => 'exercise_diaphragm_desc'.tr();
  static String get exerciseDiaphragmPurpose => 'exercise_diaphragm_purpose'.tr();
  static String get exerciseDiaphragmStep1 => 'exercise_diaphragm_step1'.tr();
  static String get exerciseDiaphragmStep2 => 'exercise_diaphragm_step2'.tr();
  
  // Equal Breathing
  static String get exerciseEqualBreathName => 'exercise_equal_breath_name'.tr();
  static String get exerciseEqualBreathDesc => 'exercise_equal_breath_desc'.tr();
  static String get exerciseEqualBreathPurpose => 'exercise_equal_breath_purpose'.tr();
  static String get exerciseEqualBreathStep1 => 'exercise_equal_breath_step1'.tr();
  static String get exerciseEqualBreathStep2 => 'exercise_equal_breath_step2'.tr();
  
  // Slowing Breath
  static String get exerciseSlowingName => 'exercise_slowing_name'.tr();
  static String get exerciseSlowingDesc => 'exercise_slowing_desc'.tr();
  static String get exerciseSlowingPurpose => 'exercise_slowing_purpose'.tr();
  static String get exerciseSlowingStep1 => 'exercise_slowing_step1'.tr();
  static String get exerciseSlowingStep2 => 'exercise_slowing_step2'.tr();
  
  // Body Awareness Breathing
  static String get exerciseBodyAwarenessName => 'exercise_body_awareness_name'.tr();
  static String get exerciseBodyAwarenessDesc => 'exercise_body_awareness_desc'.tr();
  static String get exerciseBodyAwarenessPurpose => 'exercise_body_awareness_purpose'.tr();
  static String get exerciseBodyAwarenessStep1 => 'exercise_body_awareness_step1'.tr();
  static String get exerciseBodyAwarenessStep2 => 'exercise_body_awareness_step2'.tr();
  
  // Relaxation Breathing
  static String get exerciseRelaxationName => 'exercise_relaxation_name'.tr();
  static String get exerciseRelaxationDesc => 'exercise_relaxation_desc'.tr();
  static String get exerciseRelaxationPurpose => 'exercise_relaxation_purpose'.tr();
  static String get exerciseRelaxationStep1 => 'exercise_relaxation_step1'.tr();
  static String get exerciseRelaxationStep2 => 'exercise_relaxation_step2'.tr();
  
  // Energizing Diaphragm
  static String get exerciseEnergizingDiaphragmName => 'exercise_energizing_diaphragm_name'.tr();
  static String get exerciseEnergizingDiaphragmDesc => 'exercise_energizing_diaphragm_desc'.tr();
  static String get exerciseEnergizingDiaphragmPurpose => 'exercise_energizing_diaphragm_purpose'.tr();
  static String get exerciseEnergizingDiaphragmStep1 => 'exercise_energizing_diaphragm_step1'.tr();
  static String get exerciseEnergizingDiaphragmStep2 => 'exercise_energizing_diaphragm_step2'.tr();
  
  // Morning Breath
  static String get exerciseMorningBreathName => 'exercise_morning_breath_name'.tr();
  static String get exerciseMorningBreathDesc => 'exercise_morning_breath_desc'.tr();
  static String get exerciseMorningBreathPurpose => 'exercise_morning_breath_purpose'.tr();
  static String get exerciseMorningBreathStep1 => 'exercise_morning_breath_step1'.tr();
  static String get exerciseMorningBreathStep2 => 'exercise_morning_breath_step2'.tr();
  
  // Day Start Breathing
  static String get exerciseDayStartName => 'exercise_day_start_name'.tr();
  static String get exerciseDayStartDesc => 'exercise_day_start_desc'.tr();
  static String get exerciseDayStartPurpose => 'exercise_day_start_purpose'.tr();
  static String get exerciseDayStartStep1 => 'exercise_day_start_step1'.tr();
  static String get exerciseDayStartStep2 => 'exercise_day_start_step2'.tr();
  
  // Category Names
  static String get categoryFocus => 'category_focus'.tr();
  static String get categoryStress => 'category_stress'.tr();
  static String get categorySleep => 'category_sleep'.tr();
  static String get categoryEnergy => 'category_energy'.tr();

  // ===== SOUND COLLECTION LOCALIZED DATA =====
  
  static String get soundCollectionTitle => 'soundCollectionTitle'.tr();
  
  // Sound Categories
  static String get soundCategoryNature => 'sound_category_nature'.tr();
  static String get soundCategoryAmbient => 'sound_category_ambient'.tr();
  static String get soundCategoryMeditation => 'sound_category_meditation'.tr();
  static String get soundCategoryNight => 'sound_category_night'.tr();
  
  // Nature Sounds
  static String get soundRainOnTentName => 'sound_rain_on_tent_name'.tr();
  static String get soundRainOnTentDesc => 'sound_rain_on_tent_desc'.tr();
  static String get soundLightRainName => 'sound_light_rain_name'.tr();
  static String get soundLightRainDesc => 'sound_light_rain_desc'.tr();
  static String get soundHeavyRainName => 'sound_heavy_rain_name'.tr();
  static String get soundHeavyRainDesc => 'sound_heavy_rain_desc'.tr();
  static String get soundOceanName => 'sound_ocean_name'.tr();
  static String get soundOceanDesc => 'sound_ocean_desc'.tr();
  static String get soundForestName => 'sound_forest_name'.tr();
  static String get soundForestDesc => 'sound_forest_desc'.tr();
  static String get soundThunderName => 'sound_thunder_name'.tr();
  static String get soundThunderDesc => 'sound_thunder_desc'.tr();
  static String get soundCampfireName => 'sound_campfire_name'.tr();
  static String get soundCampfireDesc => 'sound_campfire_desc'.tr();
  static String get soundRiverName => 'sound_river_name'.tr();
  static String get soundRiverDesc => 'sound_river_desc'.tr();
  
  // Ambient Sounds
  static String get soundWhiteNoiseName => 'sound_white_noise_name'.tr();
  static String get soundWhiteNoiseDesc => 'sound_white_noise_desc'.tr();
  static String get soundRainyCarRideName => 'sound_rainy_car_ride_name'.tr();
  static String get soundRainyCarRideDesc => 'sound_rainy_car_ride_desc'.tr();
  static String get soundBusRideName => 'sound_bus_ride_name'.tr();
  static String get soundBusRideDesc => 'sound_bus_ride_desc'.tr();
  static String get soundLibraryName => 'sound_library_name'.tr();
  static String get soundLibraryDesc => 'sound_library_desc'.tr();
  static String get soundCafeName => 'sound_cafe_name'.tr();
  static String get soundCafeDesc => 'sound_cafe_desc'.tr();
  static String get soundTrainName => 'sound_train_name'.tr();
  static String get soundTrainDesc => 'sound_train_desc'.tr();
  
  // Meditation Sounds
  static String get soundMeditationBellName => 'sound_meditation_bell_name'.tr();
  static String get soundMeditationBellDesc => 'sound_meditation_bell_desc'.tr();
  static String get soundTibetanBowlsName => 'sound_tibetan_bowls_name'.tr();
  static String get soundTibetanBowlsDesc => 'sound_tibetan_bowls_desc'.tr();
  static String get soundPianoName => 'sound_piano_name'.tr();
  static String get soundPianoDesc => 'sound_piano_desc'.tr();
  static String get soundBinauralFocusName => 'sound_binaural_focus_name'.tr();
  static String get soundBinauralFocusDesc => 'sound_binaural_focus_desc'.tr();
  
  // Night Sounds
  static String get soundNightCricketsName => 'sound_night_crickets_name'.tr();
  static String get soundNightCricketsDesc => 'sound_night_crickets_desc'.tr();
}
