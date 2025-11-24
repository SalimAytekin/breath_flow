import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sound_item.dart';
import '../core/ads/ad_manager.dart';
import '../core/analytics/analytics_service.dart';
import '../core/crashlytics/crashlytics_service.dart';
import 'user_preferences_provider.dart';

enum PlayerState { playing, paused, stopped }

class AudioProvider with ChangeNotifier {
  // --- MIKSER VE ÖZEL ÇALAR ---
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Set<String> _mixerSoundIds = {};
  final Map<String, double> _volumes = {};
  SoundItem? _exclusiveSound;
  PlayerState _exclusivePlayerState = PlayerState.stopped;

  // --- REKLAM TAKİP SİSTEMİ ---
  DateTime? _lastSoundStartTime;
  int _soundSessionCount = 0;
  DateTime? _lastSoundInterstitialTime;
  Duration _totalSoundListeningTime = Duration.zero;
  // Moved to AppConstants.soundSessionsForAd
  
  // 🎵 SES DİNLEME TAKİBİ
  Timer? _soundListeningTimer;
  UserPreferencesProvider? _userPrefsProvider;
  bool _soundSessionRecorded = false;

  // --- MEDİTASYON OYNATICI ---
  final AudioPlayer _meditationPlayer = AudioPlayer();
  String? _currentMeditationId;
  bool _isMeditationPlaying = false;

  // --- ZAMANLAYICI VE ANA SES SEVİYESİ ---
  double _masterVolume = 1.0;
  Timer? _timer;
  int _timerDurationMinutes = 0; // Dakika cinsinden
  int _remainingSeconds = 0;
  bool get isTimerActive => _timer != null && _timer!.isActive;
  
  // --- GETTER'LAR ---
  List<SoundItem> get mixerSounds => _mixerSoundIds
      .map((id) => SoundItem.allSounds.firstWhere((s) => s.id == id))
      .toList();
  bool get isMixerActive => _mixerSoundIds.isNotEmpty;
  SoundItem? get exclusiveSound => _exclusiveSound;
  PlayerState get exclusivePlayerState => _exclusivePlayerState;
  
  // Meditasyon getter'ları
  String? get currentMeditationId => _currentMeditationId;
  bool get isMeditationPlaying => _isMeditationPlaying;

  // Zamanlayıcı ve ses seviyesi getter'ları
  double get masterVolume => _masterVolume;
  int get timerDuration => _timerDurationMinutes;
  int get remainingTime => (_remainingSeconds / 60).ceil(); // Kalan süreyi dakika olarak ver

  AudioProvider() {
    for (var sound in SoundItem.allSounds) {
      _volumes[sound.id] = 0.5; // AppConstants.defaultVolume
    }
  }
  
  // 🎵 UserPreferencesProvider'i bağla
  void setUserPreferencesProvider(UserPreferencesProvider provider) {
    _userPrefsProvider = provider;
  }
  
  // --- MİKSER VE ÖZEL ÇALAR METOTLARI ---
  Future<void> playExclusive(SoundItem sound) async {
    await stopAllSounds();
    _exclusiveSound = sound;
    _exclusivePlayerState = PlayerState.playing; // Set state immediately for UI responsiveness
    
    // 🎯 Ses dinleme takibi - reklam sistemi için
    _trackSoundSession();
    
    // 🎵 Ses dinleme timer'ı başlat (1 dakika sonra kaydet)
    _startSoundListeningTimer();
    
    final player = await _createAndPlay(sound);
    if (player != null) {
      _audioPlayers[sound.id] = player;
      // ⚡ Success log removed - production optimization
    } else {
      if (kDebugMode) debugPrint('❌ Audio player failed: ${sound.id}');
      _exclusivePlayerState = PlayerState.stopped;
    }
    notifyListeners();
  }

  Future<void> toggleMixerSound(SoundItem sound) async {
    // ⚡ Debug log removed - production optimization
    
    if (_exclusiveSound != null) {
      await stopAllSounds();
    }
    
    if (_mixerSoundIds.contains(sound.id)) {
      await _stopAndRemovePlayer(sound.id);
      _mixerSoundIds.remove(sound.id);
      // ⚡ Success log removed
    } else {
      final player = await _createAndPlay(sound);
      if (player != null) {
        _audioPlayers[sound.id] = player;
        _mixerSoundIds.add(sound.id);
        // ⚡ Success log removed
      } else {
        if (kDebugMode) debugPrint('❌ Mixer add failed: ${sound.id}');
      }
    }
    
    notifyListeners(); // ⚡ Log removed
  }
  
  Future<void> setVolume(String soundId, double volume) async {
    // Clamp volume to avoid near-zero muting artifacts
    final clamped = volume.clamp(0.02, 1.0);
    _volumes[soundId] = clamped;
    if (_audioPlayers.containsKey(soundId)) {
      await _audioPlayers[soundId]!.setVolume(clamped * _masterVolume);
    }
    notifyListeners();
  }

  double getVolume(String soundId) {
    return _volumes[soundId] ?? 0.5;
  }

  bool isPlaying(String soundId) {
    if (_exclusiveSound?.id == soundId) {
      return _exclusivePlayerState == PlayerState.playing;
    }
    return _mixerSoundIds.contains(soundId);
  }

  bool isPaused(String soundId) {
    return _exclusiveSound?.id == soundId && _exclusivePlayerState == PlayerState.paused;
  }

  Future<void> stopAllSounds() async {
    // 🎵 Ses dinleme timer'ı iptal et - ama önce kaydı kontrol et
    _checkAndRecordBeforeStop();
    _cancelSoundListeningTimer();
    
    // 🛡️ CRITICAL FIX: Thread-safe cleanup
    if (_exclusiveSound != null) {
      await _stopAndRemovePlayer(_exclusiveSound!.id);
      _exclusiveSound = null;
      _exclusivePlayerState = PlayerState.stopped;
    }
    
    // Create a copy to avoid concurrent modification
    final mixerIds = List<String>.from(_mixerSoundIds);
    _mixerSoundIds.clear(); // Clear first to prevent concurrent access
    
    for (final id in mixerIds) {
      await _stopAndRemovePlayer(id);
    }
    
    
    // Cleanup any orphaned players
    await _cleanupUnusedPlayers();
    
    notifyListeners();
  }
  
  /// Ses durdurmadan önce kaydı kontrol et
  void _checkAndRecordBeforeStop() {
    if (_soundSessionRecorded || _lastSoundStartTime == null) return;
    
    final listeningDuration = DateTime.now().difference(_lastSoundStartTime!);
    // Eğer 30 saniyeden fazla dinlendiyse kaydet
    if (listeningDuration.inSeconds >= 30) { // AppConstants.minSoundListeningSeconds
      _recordSoundSession();
    }
    
    // Timer'ı sıfırla
    _lastSoundStartTime = null;
    _soundSessionRecorded = false;
  }
  
  /// Ses dinleme oturumu başladı
  void _trackSoundSession() {
    _lastSoundStartTime = DateTime.now();
    _soundSessionCount++;
 if (kDebugMode) debugPrint('🎵 Ses oturumu başladı: $_soundSessionCount/${3}'); // AppConstants.soundSessionsForAd
  }

  /// Ses dinleme sonrası reklam kontrolü
  Future<void> _checkAndShowSoundAd() async {
    if (_lastSoundStartTime == null) return;
    
    // En az 10 saniye dinlenmişse sayılsın (test için düşürdük)
    final listeningDuration = DateTime.now().difference(_lastSoundStartTime!);
    if (listeningDuration.inSeconds < 10) {
 if (kDebugMode) debugPrint('⏰ Ses çok kısa dinlendi, reklam sayılmaz: ${listeningDuration.inSeconds}s');
      return;
    }

 if (kDebugMode) debugPrint('🎯 Ses dinleme tamamlandı: ${listeningDuration.inSeconds}s');
 if (kDebugMode) debugPrint('📊 Mevcut ses sayacı: $_soundSessionCount/${3}');
    
    // Belirlenen ses sayısına ulaşıldıysa reklam göster
    if (_soundSessionCount >= 3) { // AppConstants.soundSessionsForAd
 if (kDebugMode) debugPrint('🎬 Ses dinleme reklamı gösteriliyor...');
        final adShown = await AdManager.instance.showInterstitial(placement: 'audio_session_complete');
      if (adShown) {
        _soundSessionCount = 0; // Sayacı sıfırla
 if (kDebugMode) debugPrint('✅ Ses reklamı gösterildi, sayaç sıfırlandı');
      } else {
 if (kDebugMode) debugPrint('❌ Ses reklamı gösterilemedi');
      }
    } else {
 if (kDebugMode) debugPrint('📈 Henüz yeterli ses dinlenmedi: $_soundSessionCount/${3}');
    }
  }

  Future<AudioPlayer?> _createAndPlay(SoundItem sound, {BuildContext? context}) async {
    try {
      final player = AudioPlayer();
      
      // 🎵 just_audio automatically handles audio session
 if (kDebugMode) debugPrint('✅ Audio player created with just_audio');
      
      // 🎯 Audio source preparation for seamless loops
      String assetPath = sound.assetPath.startsWith('assets/')
          ? sound.assetPath.substring(7)
          : sound.assetPath;
      
 if (kDebugMode) debugPrint('🎵 Setting up SEAMLESS audio loop: ${sound.name}');
 if (kDebugMode) debugPrint('📁 Original Asset path: $assetPath');
      
      // 🔄 ENHANCED fallback system with better error handling
      String workingPath = assetPath;
      
      try {
 if (kDebugMode) debugPrint('🔍 Testing audio path: $assetPath');
        await player.setAsset('assets/$assetPath');
 if (kDebugMode) debugPrint('✅ Audio source set successfully: $assetPath');
      } catch (e) {
 if (kDebugMode) debugPrint('❌ Primary audio failed: $assetPath - $e');
        
        // Try removing extra path components
        if (assetPath.contains('/')) {
          workingPath = assetPath.split('/').last;
          workingPath = 'audio/$workingPath';
          try {
 if (kDebugMode) debugPrint('🔍 Trying simplified path: $workingPath');
            await player.setAsset('assets/$workingPath');
 if (kDebugMode) debugPrint('✅ Simplified path works: $workingPath');
          } catch (pathError) {
 if (kDebugMode) debugPrint('❌ Simplified path failed: $workingPath - $pathError');
            
            // Final fallback to a guaranteed working file
            workingPath = 'audio/ocean_waves.mp3';
            try {
 if (kDebugMode) debugPrint('🔍 Using final fallback: $workingPath');
              await player.setAsset('assets/$workingPath');
 if (kDebugMode) debugPrint('✅ Fallback audio loaded: $workingPath');
            } catch (fallbackError) {
 if (kDebugMode) debugPrint('🚨 Complete audio failure: $fallbackError');
              await player.dispose();
              return null;
            }
          }
        } else {
          // Direct fallback
        workingPath = 'audio/ocean_waves.mp3';
        try {
 if (kDebugMode) debugPrint('🔍 Using fallback: $workingPath');
          await player.setAsset('assets/$workingPath');
 if (kDebugMode) debugPrint('✅ Fallback audio loaded: $workingPath');
        } catch (fallbackError) {
 if (kDebugMode) debugPrint('🚨 Complete audio failure: $fallbackError');
            await player.dispose();
          return null;
          }
        }
      }
      
 if (kDebugMode) debugPrint('🎵 Final audio path: $workingPath');
      
      // 🔄 GAPLESS looping configuration
      await player.setLoopMode(LoopMode.one);
      
      // 🎛️ Volume setup
      final targetVolume = getVolume(sound.id) * _masterVolume;
      await player.setVolume(targetVolume);
      
      // 🚀 GAPLESS PLAYBACK optimizations
      
      // Pre-buffer the audio for smooth loops
 if (kDebugMode) debugPrint('🔄 Pre-buffering for gapless playback...');
      
      // Audio player'ı başlat (NON-BLOCKING - mixer için)
      // Mixer'da play() beklemeden devam ediyoruz
      player.play().then((_) {
        if (kDebugMode) debugPrint('✅ player.play() tamamlandı: ${sound.name}');
      }).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ player.play() hatası: $e');
      });
      
      if (kDebugMode) debugPrint('🎵 player.play() çağrıldı (non-blocking)');
      
      if (_exclusiveSound?.id == sound.id) {
        _exclusivePlayerState = PlayerState.playing;
      }
      
      if (kDebugMode) debugPrint('✅ Audio player başlatıldı: ${sound.name}');
      if (kDebugMode) debugPrint('🎵 Volume: $targetVolume');
      if (kDebugMode) debugPrint('🎵 Working Path: $workingPath');
      
      // Analytics event - Ses çalma başladı (non-blocking)
      AnalyticsService.instance.logSoundPlayed(
        soundId: sound.id,
        durationSeconds: 0, // Başlangıçta 0, timer ile güncellenecek
      ).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Analytics log hatası: $e');
      });
      
      if (kDebugMode) debugPrint('🎵 Player return ediliyor...');
      return player;
    } catch (e, stackTrace) {
 if (kDebugMode) debugPrint('❌ Seamless audio setup error - $e');
      
      // Crashlytics error reporting
      await CrashlyticsService.instance.recordMediaError(
        errorType: 'audio_load_failed',
        mediaId: sound.id,
        errorMessage: e.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
      
      // Note: Context will be passed from the calling method for user notification
      return null;
    }
  }

  Future<void> _stopAndRemovePlayer(String soundId) async {
    if (_audioPlayers.containsKey(soundId)) {
      final player = _audioPlayers.remove(soundId)!;
      try {
        await player.stop();
        await player.dispose();
 if (kDebugMode) debugPrint('✅ Player stopped and disposed: $soundId');
      } catch (e) {
 if (kDebugMode) debugPrint('❌ Error stopping player $soundId: $e');
      }
    }
  }
  
  /// 🧹 Cleanup unused players (prevent memory leak)
  Future<void> _cleanupUnusedPlayers() async {
    final List<String> toRemove = [];
    
    for (final entry in _audioPlayers.entries) {
      // If player is not in mixer and not exclusive, remove it
      if (!_mixerSoundIds.contains(entry.key) && 
          _exclusiveSound?.id != entry.key) {
        toRemove.add(entry.key);
      }
    }
    
    for (final id in toRemove) {
      await _stopAndRemovePlayer(id);
    }
    
    if (toRemove.isNotEmpty) {
 if (kDebugMode) debugPrint('🧹 Cleaned up ${toRemove.length} unused players');
    }
  }
  
  
  // --- ZAMANLAYICI VE SES SEVİYESİ METOTLARI ---
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    // Batch apply to reduce glitches
    final futures = <Future<void>>[];
    for (var id in _audioPlayers.keys) {
      final per = getVolume(id).clamp(0.02, 1.0);
      futures.add(_audioPlayers[id]!.setVolume(per * _masterVolume));
    }
    await Future.wait(futures);
    notifyListeners();
  }

  void setTimerDuration(int minutes) {
    _timerDurationMinutes = minutes;
    notifyListeners();
  }

  void startTimer() {
    if (_timerDurationMinutes > 0 && !isTimerActive) {
      _remainingSeconds = _timerDurationMinutes * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();
        } else {
          stopAllSounds();
          stopTimer(); // Bu kendini ve notifyListeners'ı çağırır
        }
      });
      notifyListeners();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
    notifyListeners();
  }

  // --- GERİYE UYUMLULUK VE YARDIMCI METOTLAR ---
  // Eski `play` ve `stop` metotlarına ihtiyaç duyan yerler için geçici.
  // Bu metotlar sesi miksere ekler/çıkarır.
  void play(String soundId) {
     final sound = SoundItem.allSounds.firstWhere((s) => s.id == soundId);
     toggleMixerSound(sound);
  }

  void stop(String soundId) {
    final sound = SoundItem.allSounds.firstWhere((s) => s.id == soundId);
    if (isPlaying(sound.id)) {
      toggleMixerSound(sound);
    }
  }

  // Eski `playingSounds` listesine ihtiyaç duyan yerler için.
  List<String> get playingSounds => _mixerSoundIds.toList();

  Future<void> pauseExclusive() async {
    if (_exclusiveSound != null && _exclusivePlayerState == PlayerState.playing) {
      final player = _audioPlayers[_exclusiveSound!.id];
      if (player != null) {
        await player.pause();
        _exclusivePlayerState = PlayerState.paused;
        notifyListeners();
      }
    }
  }

  Future<void> resumeExclusive() async {
    if (_exclusiveSound != null && _exclusivePlayerState == PlayerState.paused) {
      final player = _audioPlayers[_exclusiveSound!.id];
      if (player != null) {
        await player.play();
        _exclusivePlayerState = PlayerState.playing;
        notifyListeners();
      }
    }
  }

  // 🎵 SES DİNLEME TIMER METODLARI
  
  /// 30 saniye sonra ses dinleme seansını kaydet
  void _startSoundListeningTimer() {
    _soundSessionRecorded = false;
    _cancelSoundListeningTimer();
    
    _soundListeningTimer = Timer(const Duration(seconds: 30), () { // AppConstants.minSoundListeningSeconds
      if (!_soundSessionRecorded && _exclusiveSound != null) {
        _recordSoundSession();
      }
    });
    
 if (kDebugMode) debugPrint('🎵 Ses dinleme timer başlatıldı (30 saniye)');
  }
  
  /// Timer'ı iptal et
  void _cancelSoundListeningTimer() {
    _soundListeningTimer?.cancel();
    _soundListeningTimer = null;
  }
  
  /// Ses dinleme seansını kaydet
  void _recordSoundSession() {
    if (_soundSessionRecorded || _lastSoundStartTime == null) return;
    
    _soundSessionRecorded = true;
    
    // Gerçek dinleme süresini hesapla
    final listeningDuration = DateTime.now().difference(_lastSoundStartTime!);
    final listeningMinutes = (listeningDuration.inSeconds / 60).ceil(); // En az 1 dakika
    
    // Toplam dinleme süresini güncelle
    _totalSoundListeningTime += listeningDuration;
    
    _userPrefsProvider?.recordSoundSession(listeningMinutes);
 if (kDebugMode) debugPrint('🎵 Ses dinleme seansı kaydedildi: $listeningMinutes dakika (${listeningDuration.inSeconds} saniye)');
    
    // 🎯 Ses dinleme süre kontrolü - 4 dakika sonrası interstitial reklam
    _checkSoundDurationInterstitial();
  }
  
  /// Ses dinleme süre kontrolü - 4 dakika sonrası interstitial reklam
  Future<void> _checkSoundDurationInterstitial() async {
    // 4 dakika = 240 saniye
    const Duration soundInterstitialThreshold = Duration(minutes: 4);
    
    // Rate limiting kontrolü (5 dakika)
    final now = DateTime.now();
    if (_lastSoundInterstitialTime != null) {
      final timeSinceLastAd = now.difference(_lastSoundInterstitialTime!);
      if (timeSinceLastAd < const Duration(minutes: 5)) {
 if (kDebugMode) debugPrint('⏰ Ses dinleme rate limiting: ${5 - timeSinceLastAd.inMinutes} dakika kaldı');
        return;
      }
    }
    
    // Toplam dinleme süresi kontrolü
    if (_totalSoundListeningTime >= soundInterstitialThreshold) {
 if (kDebugMode) debugPrint('🎯 Ses dinleme süre kontrolü: ${_totalSoundListeningTime.inMinutes} dakika dinlendi, interstitial reklam gösterilecek');
      
      _lastSoundInterstitialTime = now;
      _totalSoundListeningTime = Duration.zero; // Sayaç sıfırla
      
      // Interstitial reklam göster
      final adShown = await AdManager.instance.showInterstitial(placement: 'sound_duration_control');
      if (adShown) {
 if (kDebugMode) debugPrint('✅ Ses dinleme süre kontrolü interstitial reklamı gösterildi');
      }
    }
  }

  @override
  void dispose() {
    // 🛡️ CRITICAL: Ensure all resources are cleaned up
    _cancelSoundListeningTimer();
    
    // Stop and dispose all audio players
    for (final player in _audioPlayers.values) {
      try {
        player.stop();
        player.dispose();
      } catch (e) {
 if (kDebugMode) debugPrint('❌ Error disposing audio player: $e');
      }
    }
    _audioPlayers.clear();
    
    // Dispose meditation player
    try {
      _meditationPlayer.stop();
      _meditationPlayer.dispose();
    } catch (e) {
 if (kDebugMode) debugPrint('❌ Error disposing meditation player: $e');
    }
    
    // Cancel any active timers
    _timer?.cancel();
    _timer = null;
    
    super.dispose();
  }
} 
