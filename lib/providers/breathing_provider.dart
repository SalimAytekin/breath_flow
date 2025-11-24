import 'dart:async';
import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../constants/app_colors.dart';
import '../core/analytics/analytics_service.dart';
import '../core/crashlytics/crashlytics_service.dart';

class BreathingProvider extends ChangeNotifier {
  // --- Private State Variables ---
  BreathingExercise? _currentExercise;
  bool _isRunning = false;
  bool _isPaused = false;
  Timer? _timer;

  // Step and cycle tracking
  int _stepIndex = 0;
  BreathingStep? _currentStep;
  int _countdown = 0;
  
  // Session duration and progress
  int _sessionDuration = 5; // Default 5 minutes
  int _totalCycles = 0;
  int _completedCycles = 0;
  
  // Real-time session tracking
  DateTime? _sessionStartTime;
  int _actualSessionDurationSeconds = 0;

  // Progress within a single step (0.0 to 1.0)
  double _stepProgress = 0.0;
  
  // Callback for when a session is fully completed
  VoidCallback? _onSessionCompleted;

  // --- Public Getters for UI ---
  BreathingExercise? get currentExercise => _currentExercise;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  BreathingStep? get currentStep => _currentStep;
  int get countdown => _countdown;
  int get sessionDuration => _sessionDuration;
  int get totalCycles => _totalCycles;
  int get completedCycles => _completedCycles;
  double get stepProgress => _stepProgress;
  
  // Real-time session duration getters
  int get actualSessionDurationSeconds => _actualSessionDurationSeconds;
  int get actualSessionDurationMinutes => (_actualSessionDurationSeconds / 60).round();
  Duration get actualSessionDuration => Duration(seconds: _actualSessionDurationSeconds);
  
  // --- Public Methods ---

  void setOnSessionCompleted(VoidCallback callback) {
    _onSessionCompleted = callback;
  }

  void setExercise(BreathingExercise exercise, {int? customCycles}) {
    if (_isRunning) {
      stop(); // Stop any previous session
    }
    _currentExercise = exercise;
    if (customCycles != null) {
      _totalCycles = customCycles;
    } else {
      _calculateTotalCycles();
    }
    start(); // Automatically start when an exercise is set
  }

  void setSessionDuration(int minutes) {
    _sessionDuration = minutes;
    _calculateTotalCycles();
    notifyListeners();
  }

  void pause() {
    if (_isRunning && !_isPaused) {
      _isPaused = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resume() {
    if (_isRunning && _isPaused) {
      _isPaused = false;
      _startTimer();
      notifyListeners();
    }
  }

  void stop() {
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    
    // Calculate final session duration
    if (_sessionStartTime != null) {
      final endTime = DateTime.now();
      _actualSessionDurationSeconds = endTime.difference(_sessionStartTime!).inSeconds;
      
      // Analytics event - Egzersiz tamamlandı
      if (_currentExercise != null) {
        AnalyticsService.instance.logExerciseCompleted(
          exerciseId: _currentExercise!.type.name,
          durationSeconds: _actualSessionDurationSeconds,
        );
      }
    }
    
    _currentExercise = null; // Clear exercise on stop to return to selection screen
    notifyListeners();
  }

  // --- Private Internal Logic ---
  
  void start() {
    if (_currentExercise == null || _isRunning) return;

    _isRunning = true;
    _completedCycles = 0;
    _stepIndex = -1; // Start with -1 to trigger _nextStep immediately
    _sessionStartTime = DateTime.now(); // Start tracking real time
    _actualSessionDurationSeconds = 0;
    _nextStep();
    _startTimer();
    
    // Analytics event - Egzersiz başladı
    AnalyticsService.instance.logExerciseStarted(
      exerciseId: _currentExercise!.type.name,
      from: 'breathing_screen', // Bu parametre çağıran yerden geçilebilir
    );
    
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _calculateTotalCycles() {
    if (_currentExercise == null) {
      _totalCycles = 10; // Fallback
      return;
    }
    // Use session duration if it makes sense
    if (_sessionDuration > 0) {
      final cycleTimeInSeconds = _currentExercise!.steps.fold<int>(0, (prev, step) => prev + step.duration);
      if (cycleTimeInSeconds > 0) {
        final totalDurationInSeconds = _sessionDuration * 60;
        _totalCycles = (totalDurationInSeconds / cycleTimeInSeconds).ceil();
        return;
      }
    }
    // Default to a reasonable number of cycles if duration isn't set
    _totalCycles = _currentExercise!.category == BreathingCategory.uykuVeRahatlama ? 15 : 10;
  }


  void _nextStep() {
    _stepIndex++;
    // Check if one full cycle is completed
    if (_stepIndex >= _currentExercise!.steps.length) {
      _stepIndex = 0;
      _completedCycles++;
      // Check if the entire session is completed
      if (_completedCycles >= _totalCycles) {
        // Session finished based on cycles
        _isRunning = false;
        _isPaused = false;
        _timer?.cancel();
        
        // Calculate final session duration
        if (_sessionStartTime != null) {
          final endTime = DateTime.now();
          _actualSessionDurationSeconds = endTime.difference(_sessionStartTime!).inSeconds;
        }
        
        // Callback'i çağır ama currentExercise'ı temizleme
        _onSessionCompleted?.call();
        return;
      }
    }
    _currentStep = _currentExercise!.steps[_stepIndex];
    _countdown = _currentStep!.duration;
    _stepProgress = 0.0;
  }

  void _tick(Timer timer) {
    if (!_isRunning || _currentStep == null || _isPaused) {
      timer.cancel();
      return;
    }

    _countdown--;
    
    // Update actual session duration
    if (_sessionStartTime != null) {
      _actualSessionDurationSeconds = DateTime.now().difference(_sessionStartTime!).inSeconds;
    }
    
    final int stepDuration = _currentStep!.duration;
    // Calculate progress (0.0 to 1.0)
    if (stepDuration > 0) {
        _stepProgress = (stepDuration - _countdown) / stepDuration;
    } else {
        _stepProgress = 1.0;
    }
    
    if (_countdown <= 0) {
      _nextStep();
    }
    notifyListeners();
  }

  // --- UI Dependent Getters ---

  Color get animationColor {
    if (_currentStep == null) return AppColors.primary;

    switch (_currentStep!.type) {
      case BreathingStepType.inhale:
        return AppColors.primary;
      case BreathingStepType.hold:
        return AppColors.focus;
      case BreathingStepType.exhale:
        return AppColors.relaxation;
      case BreathingStepType.holdAfterExhale:
        return AppColors.sleep;
    }
  }
  
  @override
  void dispose() {
    // 🛡️ CRITICAL FIX: Ensure timer is cancelled
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
} 