import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/sound_item.dart';
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

  // --- CROSSFADE LOOP SİSTEMİ ---
  static const int _crossfadeStepMs = 40; // fade adım aralığı (ms)
  final Map<String, AudioPlayer> _crossfadePlayers = {}; // B player'lar
  final Map<String, Timer> _crossfadeTimers = {}; // Pozisyon izleme timer'ları
  final Map<String, bool> _crossfadeInProgress = {}; // Crossfade aktif mi

  // Ses türüne göre crossfade süresi (saniye)
  // Dinamik sesler (gök gürültüsü, ateş) daha uzun crossfade ister
  static const Map<String, double> _crossfadeDurations = {
    'thunder': 7.0,      // Çok dinamik — gök gürültüsü patlamaları
    'campfire': 6.0,     // Dinamik — çıtırtılar değişken
    'night_crickets': 7.0, // Çok dinamik — böcek ritimleri belirgin
    'bus_ride': 6.0,     // Dinamik — motor sesi değişken
    'binaural_focus': 5.0, // Sabit ton ama geçiş belli
    'rain_on_tent': 4.0, // Orta — damla sesleri
    'forest': 4.0,       // Orta — kuş sesleri
    'cafe': 4.0,         // Orta — konuşma sesleri
    'library': 4.0,      // Orta
    'ocean': 4.0,        // Orta — dalga ritimleri
  };
  static const double _defaultCrossfadeDuration = 3.5;

  // Per-sound volume normalizasyon katsayıları
  // 1.0 = değişiklik yok, <1.0 = kıs, >1.0 = aç
  static const Map<String, double> _volumeNormalization = {
    'heavy_rain': 0.55,    // Çok yüksek geliyor — kıs
    'thunder': 0.70,       // Yüksek — biraz kıs
    'rain_on_tent': 0.85,  // Hafif yüksek
    'light_rain': 1.0,     // Normal
    'campfire': 1.0,       // Normal
    'ocean': 1.0,          // Normal
    'forest': 1.0,         // Normal
    'binaural_focus': 0.90, // Hafif yüksek
  };

  /// Ses için crossfade süresini döndür
  double _getCrossfadeDuration(String soundId) {
    return _crossfadeDurations[soundId] ?? _defaultCrossfadeDuration;
  }

  /// Ses için normalize edilmiş volume döndür
  double _getNormalizedVolume(String soundId, double rawVolume) {
    final normFactor = _volumeNormalization[soundId] ?? 1.0;
    return (rawVolume * normFactor).clamp(0.0, 1.0);
  }

  // --- REKLAM TAKİP SİSTEMİ ---
  DateTime? _lastSoundStartTime;
  int _soundSessionCount = 0;
  DateTime? _lastSoundInterstitialTime;
  Duration _totalSoundListeningTime = Duration.zero;
  bool _shouldShowExitInterstitial = false; // Çıkışta interstitial gösterilmeli mi?
  
  // 🎵 SES DİNLEME TAKİBİ
  Timer? _soundListeningTimer;
  UserPreferencesProvider? _userPrefsProvider;
  bool _soundSessionRecorded = false;

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

  // Zamanlayıcı ve ses seviyesi getter'ları
  double get masterVolume => _masterVolume;
  int get timerDuration => _timerDurationMinutes;
  int get remainingSeconds => _remainingSeconds;
  int get remainingTime => _remainingSeconds > 0 ? (_remainingSeconds / 60).ceil() : 0;
  
  // Ad logic getter
  int get sessionCount => _soundSessionCount;

  AudioProvider() {
    for (var sound in SoundItem.allSounds) {
      _volumes[sound.id] = 0.5; // AppConstants.defaultVolume
    }
    _initializeAudioSession();
  }

  /// 🎧 Audio session başlat — background audio + ekran kapalıyken çalma
  Future<void> _initializeAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
      if (kDebugMode) debugPrint('✅ AudioProvider: Audio session configured (background audio active)');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ AudioProvider: Audio session error: $e');
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
    // Stop other sounds if exclusive
    if (_exclusiveSound != null) {
      await stopAllSounds();
    }
    
    // Increment session count for ad logic
    _soundSessionCount++;
    notifyListeners();
    
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
      final normalized = _getNormalizedVolume(soundId, clamped * _masterVolume);
      await _audioPlayers[soundId]!.setVolume(normalized);
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
  }

  Future<AudioPlayer?> _createAndPlay(SoundItem sound) async {
    try {
      final player = AudioPlayer();
      
      // 🎯 Audio source preparation
      String assetPath = sound.assetPath.startsWith('assets/')
          ? sound.assetPath.substring(7)
          : sound.assetPath;
      
      // 🔄 Fallback system
      String workingPath = assetPath;
      
      try {
        await player.setAsset('assets/$assetPath');
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Audio failed: $assetPath - $e');
        
        if (assetPath.contains('/')) {
          workingPath = 'audio/${assetPath.split('/').last}';
          try {
            await player.setAsset('assets/$workingPath');
          } catch (pathError) {
            workingPath = 'audio/ocean_waves.mp3';
            try {
              await player.setAsset('assets/$workingPath');
            } catch (fallbackError) {
              if (kDebugMode) debugPrint('🚨 Complete audio failure: $fallbackError');
              await player.dispose();
              return null;
            }
          }
        } else {
          workingPath = 'audio/ocean_waves.mp3';
          try {
            await player.setAsset('assets/$workingPath');
          } catch (fallbackError) {
            if (kDebugMode) debugPrint('🚨 Complete audio failure: $fallbackError');
            await player.dispose();
            return null;
          }
        }
      }
      
      // 🔄 Loop kapalı — crossfade sistemi yönetecek
      await player.setLoopMode(LoopMode.off);
      
      // 🎛️ Volume setup (normalizasyon dahil)
      final targetVolume = _getNormalizedVolume(
        sound.id, getVolume(sound.id) * _masterVolume,
      );
      await player.setVolume(targetVolume);
      
      // Audio player'ı başlat (NON-BLOCKING)
      player.play().catchError((e) {
        if (kDebugMode) debugPrint('⚠️ player.play() hatası: $e');
      });
      
      if (_exclusiveSound?.id == sound.id) {
        _exclusivePlayerState = PlayerState.playing;
      }
      
      // 🔄 Crossfade pozisyon izleme başlat
      _startCrossfadeMonitor(sound);
      
      // Analytics (non-blocking)
      AnalyticsService.instance.logSoundPlayed(
        soundId: sound.id,
        durationSeconds: 0,
      ).catchError((e) {});
      
      return player;
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('❌ Audio setup error: ${sound.id} - $e');
      
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

  // --- CROSSFADE LOOP METOTLARI ---

  /// Ses pozisyonunu izle, bitmesine _crossfadeDuration kala crossfade başlat
  void _startCrossfadeMonitor(SoundItem sound) {
    _crossfadeTimers[sound.id]?.cancel();
    _crossfadeInProgress[sound.id] = false;

    _crossfadeTimers[sound.id] = Timer.periodic(
      const Duration(milliseconds: 250),
      (timer) {
        final player = _audioPlayers[sound.id];
        if (player == null) {
          timer.cancel();
          return;
        }

        final position = player.position;
        final duration = player.duration;
        if (duration == null || duration.inMilliseconds == 0) return;

        final remaining = (duration - position).inMilliseconds / 1000.0;
        final fadeDuration = _getCrossfadeDuration(sound.id);

        // Crossfade başlat
        if (remaining <= fadeDuration &&
            remaining > 0 &&
            _crossfadeInProgress[sound.id] != true) {
          _crossfadeInProgress[sound.id] = true;
          _performCrossfade(sound);
        }
      },
    );
  }

  /// İki player arasında crossfade geçişi yap
  Future<void> _performCrossfade(SoundItem sound) async {
    final playerA = _audioPlayers[sound.id];
    if (playerA == null) return;

    try {
      // Player B oluştur ve hazırla
      final playerB = AudioPlayer();
      String assetPath = sound.assetPath.startsWith('assets/')
          ? sound.assetPath.substring(7)
          : sound.assetPath;

      try {
        await playerB.setAsset('assets/$assetPath');
      } catch (e) {
        // Fallback
        try {
          await playerB.setAsset('assets/audio/${assetPath.split('/').last}');
        } catch (_) {
          await playerB.dispose();
          // Fallback: loop moduna geri dön
          await playerA.setLoopMode(LoopMode.one);
          _crossfadeInProgress[sound.id] = false;
          return;
        }
      }

      await playerB.setLoopMode(LoopMode.off);
      await playerB.setVolume(0.0); // Sessiz başla
      playerB.play().catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Crossfade playerB play error: $e');
      });

      // Eski B player varsa temizle
      final oldB = _crossfadePlayers[sound.id];
      if (oldB != null) {
        try {
          await oldB.stop();
          await oldB.dispose();
        } catch (_) {}
      }
      _crossfadePlayers[sound.id] = playerB;

      // Fade geçişi: A fade-out, B fade-in
      final targetVolume = _getNormalizedVolume(
        sound.id, getVolume(sound.id) * _masterVolume,
      );
      final fadeDuration = _getCrossfadeDuration(sound.id);
      final int steps = (fadeDuration * 1000 / _crossfadeStepMs).round();

      for (int i = 1; i <= steps; i++) {
        await Future.delayed(Duration(milliseconds: _crossfadeStepMs));
        final progress = i / steps; // 0.0 → 1.0

        // Logaritmik fade curve — daha yumuşak geçiş
        // fade-out: yavaş başla, hızlı bitir (ses doğal azalır)
        // fade-in: hızlı başla, yavaş bitir (yeni ses doğal yükselir)
        final fadeOut = pow(1.0 - progress, 1.8).toDouble();
        final fadeIn = pow(progress, 0.6).toDouble();

        try {
          await playerA.setVolume(targetVolume * fadeOut);
          await playerB.setVolume(targetVolume * fadeIn);
        } catch (_) {
          break;
        }
      }

      // Geçiş tamamlandı: A'yı kaldır, B'yi ana player yap
      try {
        await playerA.stop();
        await playerA.dispose();
      } catch (_) {}

      _audioPlayers[sound.id] = playerB;
      _crossfadePlayers.remove(sound.id);
      _crossfadeInProgress[sound.id] = false;

      // Yeni player için crossfade monitor başlat
      _startCrossfadeMonitor(sound);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Crossfade error: ${sound.id} - $e');
      _crossfadeInProgress[sound.id] = false;
      // Fallback: loop moduna geri dön
      try {
        await playerA.setLoopMode(LoopMode.one);
      } catch (_) {}
    }
  }

  /// Crossfade kaynaklarını temizle
  Future<void> _cleanupCrossfade(String soundId) async {
    _crossfadeTimers[soundId]?.cancel();
    _crossfadeTimers.remove(soundId);
    _crossfadeInProgress.remove(soundId);

    final crossfadePlayer = _crossfadePlayers.remove(soundId);
    if (crossfadePlayer != null) {
      try {
        await crossfadePlayer.stop();
        await crossfadePlayer.dispose();
      } catch (_) {}
    }
  }

  Future<void> _stopAndRemovePlayer(String soundId) async {
    // Crossfade kaynaklarını temizle
    await _cleanupCrossfade(soundId);
    
    if (_audioPlayers.containsKey(soundId)) {
      final player = _audioPlayers.remove(soundId)!;
      try {
        await player.stop();
        await player.dispose();
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Stop player error: $soundId');
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
    
  }
  
  
  // --- ZAMANLAYICI VE SES SEVİYESİ METOTLARI ---
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    // Batch apply to reduce glitches
    final futures = <Future<void>>[];
    for (var id in _audioPlayers.keys) {
      final per = getVolume(id).clamp(0.02, 1.0);
      final normalized = _getNormalizedVolume(id, per * _masterVolume);
      futures.add(_audioPlayers[id]!.setVolume(normalized));
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
    if (_exclusiveSound == null) return;
    final player = _audioPlayers[_exclusiveSound!.id];
    if (player != null) {
      await player.pause();
      _exclusivePlayerState = PlayerState.paused;
      notifyListeners();
    }
  }

  Future<void> resumeExclusive() async {
    if (_exclusiveSound == null) return;
    final player = _audioPlayers[_exclusiveSound!.id];
    if (player != null) {
      await player.play();
      _exclusivePlayerState = PlayerState.playing;
      notifyListeners();
    }
  }

  /// Tüm aktif sesleri duraklatır (mixer + exclusive + crossfade)
  Future<void> pauseAll() async {
    for (final id in _mixerSoundIds) {
      final player = _audioPlayers[id];
      if (player != null) {
        await player.pause();
      }
      // Crossfade player varsa onu da duraklat
      final crossfadePlayer = _crossfadePlayers[id];
      if (crossfadePlayer != null) {
        await crossfadePlayer.pause();
      }
    }
    if (_exclusiveSound != null) {
      // Crossfade player varsa onu da duraklat
      final crossfadePlayer = _crossfadePlayers[_exclusiveSound!.id];
      if (crossfadePlayer != null) {
        await crossfadePlayer.pause();
      }
      await pauseExclusive();
    }
    notifyListeners();
  }

  /// Tüm duraklatılmış sesleri devam ettirir (mixer + exclusive + crossfade)
  Future<void> resumeAll() async {
    for (final id in _mixerSoundIds) {
      final player = _audioPlayers[id];
      if (player != null) {
        await player.play();
      }
      // Crossfade player varsa onu da devam ettir
      final crossfadePlayer = _crossfadePlayers[id];
      if (crossfadePlayer != null) {
        await crossfadePlayer.play();
      }
    }
    if (_exclusiveSound != null) {
      // Crossfade player varsa onu da devam ettir
      final crossfadePlayer = _crossfadePlayers[_exclusiveSound!.id];
      if (crossfadePlayer != null) {
        await crossfadePlayer.play();
      }
      await resumeExclusive();
    }
    notifyListeners();
  }

  // 🎵 SES DİNLEME TIMER METODLARI
  
  /// 30 saniye sonra ses dinleme seansını kaydet
  void _startSoundListeningTimer() {
    // İstatistik ve Reflam takibi için kaydet
    _recordSoundSession();
    
    // Timer ve flag'leri temizle
    _soundSessionRecorded = false;
    _cancelSoundListeningTimer();
    
    _soundListeningTimer = Timer(const Duration(seconds: 30), () { // AppConstants.minSoundListeningSeconds
      if (!_soundSessionRecorded && _exclusiveSound != null) {
        // En az 30 saniye dinlendiyse istatistiklere kaydet
        // Ama reklam sayacı için her türlü _recordSoundSession çağrılmalı (stopAllSounds içinde)
        // Buradaki sadece istatistik için erken kayıt.
        _recordSoundSession();
      }
    });
    
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
    
    // 🎯 Ses dinleme süre kontrolü
    _checkSoundDurationInterstitial();
    
    // 📊 Session sayısını artır (Süreye bakmaksızın)
    _soundSessionCount++;
    if (kDebugMode) debugPrint('📊 Audio Session Count: $_soundSessionCount');
  }
  
  /// Ses dinleme süre kontrolü - 2 dakika sonrası çıkışta interstitial reklam flag'i
  /// NOT: Ses ortasında reklam göstermez, sadece flag set eder.
  /// Kullanıcı sesten çıkınca _exitScreen'de kontrol edilir.
  // Ad Thresholds
  static const Duration soundInterstitialThreshold = Duration(minutes: 1);
  static const int sessionCountThreshold = 3;

    
  void _checkSoundDurationInterstitial() {
    
    // Rate limiting kontrolü (5 dakika)
    final now = DateTime.now();
    if (_lastSoundInterstitialTime != null) {
      final timeSinceLastAd = now.difference(_lastSoundInterstitialTime!);
      if (timeSinceLastAd < const Duration(minutes: 5)) {
        return;
      }
    }
    
    // Toplam dinleme süresi kontrolü - flag set et, reklam gösterme
    if (_totalSoundListeningTime >= soundInterstitialThreshold) {
      _shouldShowExitInterstitial = true;
    }
  }
  
  /// Çıkışta interstitial gösterilmeli mi? (ImmersiveSoundPlayerScreen tarafından kullanılır)
  bool get shouldShowExitInterstitial => _shouldShowExitInterstitial;
  
  /// Çıkış interstitial flag'ini sıfırla ve rate limit zamanını güncelle
  void consumeExitInterstitial() {
    _shouldShowExitInterstitial = false;
    _lastSoundInterstitialTime = DateTime.now();
    _totalSoundListeningTime = Duration.zero;
  }

  @override
  void dispose() {
    // 🛡️ CRITICAL: Ensure all resources are cleaned up
    _cancelSoundListeningTimer();
    
    // Crossfade timer'larını temizle
    for (final timer in _crossfadeTimers.values) {
      timer.cancel();
    }
    _crossfadeTimers.clear();
    _crossfadeInProgress.clear();
    
    // Crossfade player'larını temizle
    for (final player in _crossfadePlayers.values) {
      try {
        player.stop();
        player.dispose();
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Error disposing crossfade player: $e');
      }
    }
    _crossfadePlayers.clear();
    
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
    
    // Cancel any active timers
    _timer?.cancel();
    _timer = null;
    
    super.dispose();
  }
} 
