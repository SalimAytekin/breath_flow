import 'dart:async';
import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../constants/app_colors.dart';

class BreathingProvider extends ChangeNotifier {
  // --- Private State Variables ---
  BreathingExercise? _currentExercise;
  bool _isRunning = false;
  Timer? _timer;

  // Step and cycle tracking
  int _stepIndex = 0;
  BreathingStep? _currentStep;
  int _countdown = 0;
  
  // Session duration and progress
  int _sessionDuration = 5; // Default 5 minutes
  int _totalCycles = 0;
  int _completedCycles = 0;

  // Progress within a single step (0.0 to 1.0)
  double _stepProgress = 0.0;
  
  // Callback for when a session is fully completed
  VoidCallback? _onSessionCompleted;

  // --- Public Getters for UI ---
  BreathingExercise? get currentExercise => _currentExercise;
  bool get isRunning => _isRunning;
  BreathingStep? get currentStep => _currentStep;
  int get countdown => _countdown;
  int get sessionDuration => _sessionDuration;
  int get totalCycles => _totalCycles;
  int get completedCycles => _completedCycles;
  double get stepProgress => _stepProgress;
  
  // --- Public Methods ---

  void setOnSessionCompleted(VoidCallback callback) {
    _onSessionCompleted = callback;
  }

  void setExercise(BreathingExercise exercise) {
    if (_isRunning) {
      stop(); // Stop any previous session
    }
    _currentExercise = exercise;
    _calculateTotalCycles();
    start(); // Automatically start when an exercise is set
  }

  void setSessionDuration(int minutes) {
    _sessionDuration = minutes;
    _calculateTotalCycles();
    notifyListeners();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _currentExercise = null; // Clear exercise on stop to return to selection screen
    notifyListeners();
  }

  // --- Private Internal Logic ---
  
  void start() {
    if (_currentExercise == null || _isRunning) return;

    _isRunning = true;
    _completedCycles = 0;
    _stepIndex = -1; // Start with -1 to trigger _nextStep immediately
    _nextStep();
    _startTimer();
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
        _onSessionCompleted?.call();
        stop();
        return;
      }
    }
    _currentStep = _currentExercise!.steps[_stepIndex];
    _countdown = _currentStep!.duration;
    _stepProgress = 0.0;
  }

  void _tick(Timer timer) {
    if (!_isRunning || _currentStep == null) {
      timer.cancel();
      return;
    }

    _countdown--;
    
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
} 