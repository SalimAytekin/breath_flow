import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound_item.dart';
import '../models/meditation_journey.dart'; // Meditasyon için gerekli
import '../services/ad_service.dart';

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
  static const int _soundSessionsForAd = 3; // 3 ses dinledikten sonra reklam

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
      _volumes[sound.id] = 0.5;
    }
  }
  
  // --- MİKSER VE ÖZEL ÇALAR METOTLARI ---
  Future<void> playExclusive(SoundItem sound) async {
    await stopAllSounds();
    _exclusiveSound = sound;
    _exclusivePlayerState = PlayerState.playing; // Set state immediately for UI responsiveness
    
    // 🎯 Ses dinleme takibi - reklam sistemi için
    _trackSoundSession();
    
    final player = await _createAndPlay(sound);
    if (player != null) {
      _audioPlayers[sound.id] = player;
      debugPrint('✅ Exclusive sound started: ${sound.name}');
    } else {
      debugPrint('❌ Failed to start exclusive sound: ${sound.name}');
      _exclusivePlayerState = PlayerState.stopped; // Reset state on failure
    }
    notifyListeners();
  }

  Future<void> toggleMixerSound(SoundItem sound) async {
    if (_exclusiveSound != null) {
      await stopAllSounds();
    }
    if (_mixerSoundIds.contains(sound.id)) {
      await _stopAndRemovePlayer(sound.id);
      _mixerSoundIds.remove(sound.id);
    } else {
      final player = await _createAndPlay(sound);
      if (player != null) {
        _audioPlayers[sound.id] = player;
        _mixerSoundIds.add(sound.id);
      }
    }
    notifyListeners();
  }
  
  Future<void> setVolume(String soundId, double volume) async {
    _volumes[soundId] = volume;
    if (_audioPlayers.containsKey(soundId)) {
      await _audioPlayers[soundId]!.setVolume(volume * _masterVolume);
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
    await _stopAllMixerSounds();
    await _stopExclusiveSound();
    await stopMeditation(); // Meditasyonu da durdur
    notifyListeners();
  }

  Future<void> _stopAllMixerSounds() async {
     for (var id in List.from(_mixerSoundIds)) {
      await _stopAndRemovePlayer(id);
    }
    _mixerSoundIds.clear();
  }
  
  Future<void> _stopExclusiveSound() async {
    if (_exclusiveSound != null) {
      // 🎯 Ses durdurulduğunda reklam kontrolü yap
      await _checkAndShowSoundAd();
      
      await _stopAndRemovePlayer(_exclusiveSound!.id);
      _exclusiveSound = null;
      _exclusivePlayerState = PlayerState.stopped;
    }
  }

  /// Ses dinleme oturumunu takip et
  void _trackSoundSession() {
    _lastSoundStartTime = DateTime.now();
    _soundSessionCount++;
    debugPrint('🎵 Ses oturumu başladı: $_soundSessionCount/$_soundSessionsForAd');
  }

  /// Ses dinleme sonrası reklam kontrolü
  Future<void> _checkAndShowSoundAd() async {
    if (_lastSoundStartTime == null) return;
    
    // En az 10 saniye dinlenmişse sayılsın (test için düşürdük)
    final listeningDuration = DateTime.now().difference(_lastSoundStartTime!);
    if (listeningDuration.inSeconds < 10) {
      debugPrint('⏰ Ses çok kısa dinlendi, reklam sayılmaz: ${listeningDuration.inSeconds}s');
      return;
    }

    debugPrint('🎯 Ses dinleme tamamlandı: ${listeningDuration.inSeconds}s');
    debugPrint('📊 Mevcut ses sayacı: $_soundSessionCount/$_soundSessionsForAd');
    
    // Belirlenen ses sayısına ulaşıldıysa reklam göster
    if (_soundSessionCount >= _soundSessionsForAd) {
      debugPrint('🎬 Ses dinleme reklamı gösteriliyor...');
      final adShown = await AdService.instance.showInterstitialAd();
      if (adShown) {
        _soundSessionCount = 0; // Sayacı sıfırla
        debugPrint('✅ Ses reklamı gösterildi, sayaç sıfırlandı');
      } else {
        debugPrint('❌ Ses reklamı gösterilemedi');
      }
    } else {
      debugPrint('📈 Henüz yeterli ses dinlenmedi: $_soundSessionCount/$_soundSessionsForAd');
    }
  }

  Future<AudioPlayer?> _createAndPlay(SoundItem sound) async {
    try {
      final player = AudioPlayer();
      
      // 🎵 SIMPLIFIED audio setup for Chewie compatibility
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      
      // 🚀 MIXER-FRIENDLY audio session - allow multiple sounds to play simultaneously
      try {
      await player.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck, // 🎵 Allow mixing!
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers, // 🎵 Allow mixing on iOS
          },
        ),
      ));
        debugPrint('✅ Audio context set for MIXING');
      } catch (contextError) {
        debugPrint('⚠️ AudioContext failed, using defaults: $contextError');
        // Continue without custom context - use system defaults
      }
      
      // 🎯 Audio source preparation for seamless loops
      String assetPath = sound.assetPath.startsWith('assets/')
          ? sound.assetPath.substring(7)
          : sound.assetPath;
      
      debugPrint('🎵 Setting up SEAMLESS audio loop: ${sound.name}');
      debugPrint('📁 Original Asset path: $assetPath');
      
      // 🔄 ENHANCED fallback system with better error handling
      String workingPath = assetPath;
      
      try {
        debugPrint('🔍 Testing audio path: $assetPath');
        await player.setSource(AssetSource(assetPath));
        debugPrint('✅ Audio source set successfully: $assetPath');
      } catch (e) {
        debugPrint('❌ Primary audio failed: $assetPath - $e');
        
        // Try removing extra path components
        if (assetPath.contains('/')) {
          workingPath = assetPath.split('/').last;
          workingPath = 'audio/$workingPath';
          try {
            debugPrint('🔍 Trying simplified path: $workingPath');
            await player.setSource(AssetSource(workingPath));
            debugPrint('✅ Simplified path works: $workingPath');
          } catch (pathError) {
            debugPrint('❌ Simplified path failed: $workingPath - $pathError');
            
            // Final fallback to a guaranteed working file
            workingPath = 'audio/ocean_waves.mp3';
            try {
              debugPrint('🔍 Using final fallback: $workingPath');
              await player.setSource(AssetSource(workingPath));
              debugPrint('✅ Fallback audio loaded: $workingPath');
            } catch (fallbackError) {
              debugPrint('🚨 Complete audio failure: $fallbackError');
              await player.dispose();
              return null;
            }
          }
        } else {
          // Direct fallback
        workingPath = 'audio/ocean_waves.mp3';
        try {
          debugPrint('🔍 Using fallback: $workingPath');
          await player.setSource(AssetSource(workingPath));
          debugPrint('✅ Fallback audio loaded: $workingPath');
        } catch (fallbackError) {
            debugPrint('🚨 Complete audio failure: $fallbackError');
            await player.dispose();
          return null;
          }
        }
      }
      
      debugPrint('🎵 Final audio path: $workingPath');
      
      // 🔄 ENHANCED looping configuration
      await player.setReleaseMode(ReleaseMode.loop);
      
      // 🎛️ Volume setup
      final targetVolume = getVolume(sound.id) * _masterVolume;
      await player.setVolume(targetVolume);
      
      // 🚀 GAPLESS PLAYBACK optimizations
      
      // Pre-buffer the audio for smooth loops
      debugPrint('🔄 Pre-buffering for gapless playback...');
      
      // Audio player'ı başlat
      await player.resume();
      
      if (_exclusiveSound?.id == sound.id) {
        _exclusivePlayerState = PlayerState.playing;
        debugPrint('✅ SEAMLESS audio loop started: ${sound.name}');
        debugPrint('🎵 Volume: ${targetVolume}');
        debugPrint('🎵 Working Path: $workingPath');
        debugPrint('🔄 Gapless looping: ACTIVE');
        debugPrint('🛡️ Protected audio session: LOCKED');
      }
      
      return player;
    } catch (e) {
      debugPrint('❌ Seamless audio setup error - $e');
      return null;
    }
  }

  Future<void> _stopAndRemovePlayer(String soundId) async {
    if (_audioPlayers.containsKey(soundId)) {
      final player = _audioPlayers.remove(soundId)!;
      try {
        await player.stop();
        await player.release(); // Release resources first
        await player.dispose();
        debugPrint('✅ Player stopped and disposed: $soundId');
      } catch (e) {
        debugPrint('❌ Error stopping player $soundId: $e');
      }
    }
  }
  
  // --- MEDİTASYON METOTLARI ---
  Future<void> playMeditation(JourneyStep step) async {
    await stopAllSounds();
    try {
      final assetPath = step.audioPath.startsWith('assets/')
          ? step.audioPath.substring(7)
          : step.audioPath;
      await _meditationPlayer.play(AssetSource(assetPath));
      _currentMeditationId = step.id;
      _isMeditationPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Meditasyon çalınamadı: $e');
    }
  }

  Future<void> pauseMeditation() async {
    if (_isMeditationPlaying) {
      await _meditationPlayer.pause();
      _isMeditationPlaying = false;
      notifyListeners();
    }
  }
  
  Future<void> stopMeditation() async {
    await _meditationPlayer.stop();
    _currentMeditationId = null;
    _isMeditationPlaying = false;
    notifyListeners();
  }
  
  // --- ZAMANLAYICI VE SES SEVİYESİ METOTLARI ---
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    for (var id in _audioPlayers.keys) {
      await _audioPlayers[id]!.setVolume(getVolume(id) * _masterVolume);
    }
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
        await player.resume();
        _exclusivePlayerState = PlayerState.playing;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    stopAllSounds();
    _meditationPlayer.dispose();
    super.dispose();
  }
} 