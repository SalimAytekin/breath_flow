/// 🎯 Application-wide constants
/// All magic numbers and hardcoded values should be defined here
class AppConstants {
  // 🔢 Numeric Constants
  
  /// Widget Sizes
  static const double cardHeight = 220.0;
  static const double categoryCardHeight = 180.0;
  static const double profilePhotoSize = 80.0;
  static const double progressCircleSize = 50.0;
  
  /// Animation Durations (milliseconds)
  static const int fadeInDuration = 600;
  static const int fadeInDelay = 100;
  static const int categoryAnimationDelay = 100; // per category
  static const int breathingAnimationDuration = 2500;
  static const int colorTransitionDuration = 2000;
  
  /// Session & Activity
  static const int defaultBreathingCycles = 10;
  static const int defaultSessionDurationMinutes = 5;
  static const int minSessionDurationSeconds = 30; // For tracking
  static const int minSoundListeningSeconds = 30;
  static const int dailyGoalMinutesDefault = 10;
  static const int weeklyGoalSessions = 7;
  
  /// Audio System
  static const double defaultVolume = 0.5;
  static const double masterVolumeDefault = 1.0;
  
  /// AdMob Configuration
  static const int soundSessionsForAd = 3;
  static const int breathSessionsForAd = 4;
  static const int maxInterstitialsPerDay = 8;
  static const int minMinutesBetweenAds = 5;
  
  /// Data Management
  static const int maxWeeklyActivityDays = 30; // Keep 30 days of history
  static const int dataBackupIntervalDays = 7;
  
  /// Streak & Progress
  static const int minStreakDays = 1;
  static const int maxStreakDisplay = 99; // Show "99+" after
  
  /// Cycle Options for Breathing Exercises
  static const List<int> breathingCycleOptions = [5, 10, 15, 20, 25, 30];
  
  /// Daily Goal Options (minutes)
  static const int minDailyGoalMinutes = 5;
  static const int maxDailyGoalMinutes = 120;
  static const int dailyGoalStep = 5;
  
  /// Error & Retry
  static const int maxRetryAttempts = 3;
  static const int retryDelaySeconds = 2;
  
  /// UI Thresholds
  static const int motivationalMessageThreshold1 = 5; // sessions
  static const int motivationalMessageThreshold2 = 10; // sessions
  
  /// Network & Timeout
  static const int networkTimeoutSeconds = 30;
  static const int cacheValidityHours = 24;
  
  // 📝 String Constants (Defaults)
  
  /// Default Values
  static const String defaultMood = 'rahatlama';
  static const String defaultLanguage = 'tr';
  static const String defaultCountry = 'TR';
  
  /// Storage Keys
  static const String keyWeeklyActivities = 'weekly_activities';
  static const String keyWeeklyActivitiesBackup = 'weekly_activities_backup';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyDailyGoalMinutes = 'daily_goal_minutes';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyPreferredMood = 'preferred_mood';
  static const String keyTotalSessions = 'total_sessions';
  static const String keyTotalMinutes = 'total_minutes';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyLastSessionDate = 'last_session_date';
  static const String keyFavoriteExercises = 'favorite_exercises';
  static const String keyFavoriteSounds = 'favorite_sounds';
  
  /// Feature Flags
  static const bool enableHRVFeature = false; // v2.0 feature
  static const bool enableJourneysFeature = false; // v2.0 feature
  static const bool enableStoriesFeature = false; // v2.0 feature
  static const bool enableOfflineMode = false; // Future feature
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  /// App Info
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String supportEmail = 'support@breatheflow.app';
  static const String websiteUrl = 'www.breatheflow.app';
}

