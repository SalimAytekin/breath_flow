import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/sound_item.dart';

/// 🎵 Seamless Audio Provider - Gapless Loop Sistemi
/// Just Audio paketi ile optimize edilmiş, kesintisiz döngü desteği
class SeamlessAudioProvider with ChangeNotifier {
  // Audio players - Her ses için ayrı player
  final Map<String, AudioPlayer> _players = {};
  
  // Volume settings
  final Map<String, double> _volumes = {};
  double _masterVolume = 1.0;
  
  // Playback states
  final Map<String, bool> _isPlaying = {};
  final Map<String, Duration> _positions = {};
  final Map<String, Duration> _durations = {};
  
  // Disposing flag
  bool _isDisposing = false;
  
  // Getters
  double get masterVolume => _masterVolume;
  
  SeamlessAudioProvider() {
    _initializeAudioSession();
    
    // Initialize volumes
    for (var sound in SoundItem.allSounds) {
      _volumes[sound.id] = 0.7; // Default volume
      _isPlaying[sound.id] = false;
      _positions[sound.id] = Duration.zero;
      _durations[sound.id] = Duration.zero;
    }
  }
  
  /// 🎧 Audio session başlat
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
      
      if (kDebugMode) debugPrint('✅ Audio session configured');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Audio session error: $e');
    }
  }
  
  /// 🎵 Seamless loop ile ses çal
  Future<void> playSeamlessLoop(SoundItem sound) async {
    if (kDebugMode) debugPrint('🎵 === SEAMLESS AUDIO START ===');
    if (kDebugMode) debugPrint('🎵 Sound: ${sound.name}');
    if (kDebugMode) debugPrint('🎵 Asset: ${sound.assetPath}');
    
    try {
      // Diğer sesleri durdur
      await stopAllSounds();
      
      // Player oluştur veya mevcut olanı kullan
      AudioPlayer player;
      if (_players.containsKey(sound.id)) {
        player = _players[sound.id]!;
        await player.stop();
      } else {
        player = AudioPlayer();
        _players[sound.id] = player;
      }
      
      // Asset path hazırla
      String assetPath = sound.assetPath.startsWith('assets/')
          ? sound.assetPath.substring(7)
          : sound.assetPath;
      
      // Audio source set et
      await player.setAsset('assets/$assetPath');
      
      // 🔄 GAPLESS LOOP MODE - Kesintisiz döngü
      await player.setLoopMode(LoopMode.one);
      
      // Volume ayarla
      final targetVolume = _volumes[sound.id]! * _masterVolume;
      await player.setVolume(targetVolume);
      
      // Position ve duration listener'lar
      player.positionStream.listen((position) {
        if (!_isDisposing) {
          _positions[sound.id] = position;
          notifyListeners();
        }
      });
      
      player.durationStream.listen((duration) {
        if (duration != null && !_isDisposing) {
          _durations[sound.id] = duration;
          if (kDebugMode) debugPrint('🎵 Duration: ${duration.inSeconds}s');
        }
      });
      
      player.playerStateStream.listen((state) {
        if (!_isDisposing) {
          _isPlaying[sound.id] = state.playing;
          notifyListeners();
        }
      });
      
      // Ses çalmaya başla
      await player.play();
      
      _isPlaying[sound.id] = true;
      
      if (kDebugMode) debugPrint('✅ Seamless loop başlatıldı: ${sound.name}');
      if (kDebugMode) debugPrint('🔄 Loop mode: ACTIVE (Gapless)');
      if (kDebugMode) debugPrint('🔊 Volume: $targetVolume');
      
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Seamless audio error: $e');
      _isPlaying[sound.id] = false;
      notifyListeners();
    }
  }
  
  /// ⏸️ Pause (fade ile)
  Future<void> pause(String soundId, {bool withFade = true}) async {
    final player = _players[soundId];
    if (player == null) return;
    
    if (withFade) {
      // Smooth fade out
      await _fadeOut(player, duration: const Duration(milliseconds: 300));
    }
    
    await player.pause();
    _isPlaying[soundId] = false;
    
    if (kDebugMode) debugPrint('⏸️ Audio paused: $soundId');
    notifyListeners();
  }
  
  /// ▶️ Resume (fade ile)
  Future<void> resume(String soundId, {bool withFade = true}) async {
    final player = _players[soundId];
    if (player == null) return;
    
    if (withFade) {
      // Smooth fade in
      await _fadeIn(player, targetVolume: _volumes[soundId]! * _masterVolume, duration: const Duration(milliseconds: 300));
    }
    
    await player.play();
    _isPlaying[soundId] = true;
    
    if (kDebugMode) debugPrint('▶️ Audio resumed: $soundId');
    notifyListeners();
  }
  
  /// 🛑 Tek bir sesi durdur
  Future<void> stop(String soundId, {bool withFade = true}) async {
    final player = _players[soundId];
    if (player == null) return;
    
    if (withFade) {
      await _fadeOut(player, duration: const Duration(milliseconds: 500));
    }
    
    await player.stop();
    _isPlaying[soundId] = false;
    
    if (kDebugMode) debugPrint('🛑 Audio stopped: $soundId');
    notifyListeners();
  }
  
  /// 🛑 Tüm sesleri durdur
  Future<void> stopAllSounds({bool withFade = false}) async {
    if (kDebugMode) debugPrint('🛑 === STOPPING ALL SOUNDS ===');
    
    for (final entry in _players.entries) {
      try {
        if (withFade) {
          await _fadeOut(entry.value, duration: const Duration(milliseconds: 300));
        }
        await entry.value.stop();
        _isPlaying[entry.key] = false;
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Stop error for ${entry.key}: $e');
      }
    }
    
    if (!_isDisposing) {
      notifyListeners();
    }
  }
  
  /// 📉 Fade out effect
  Future<void> _fadeOut(AudioPlayer player, {required Duration duration}) async {
    try {
      final currentVolume = await player.volume;
      const steps = 20;
      final stepDuration = duration.inMilliseconds ~/ steps;
      
      for (int i = steps; i >= 0; i--) {
        if (_isDisposing) break;
        final volume = (currentVolume * i / steps).clamp(0.0, 1.0);
        await player.setVolume(volume);
        await Future.delayed(Duration(milliseconds: stepDuration));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Fade out error: $e');
    }
  }
  
  /// 📈 Fade in effect
  Future<void> _fadeIn(AudioPlayer player, {required double targetVolume, required Duration duration}) async {
    try {
      const steps = 20;
      final stepDuration = duration.inMilliseconds ~/ steps;
      
      await player.setVolume(0.0);
      
      for (int i = 0; i <= steps; i++) {
        if (_isDisposing) break;
        final volume = (targetVolume * i / steps).clamp(0.0, 1.0);
        await player.setVolume(volume);
        await Future.delayed(Duration(milliseconds: stepDuration));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Fade in error: $e');
    }
  }
  
  /// 🔊 Ses seviyesini ayarla
  Future<void> setVolume(String soundId, double volume) async {
    _volumes[soundId] = volume.clamp(0.0, 1.0);
    
    final player = _players[soundId];
    if (player != null) {
      final targetVolume = _volumes[soundId]! * _masterVolume;
      await player.setVolume(targetVolume);
      if (kDebugMode) debugPrint('🔊 Volume set: $soundId - $targetVolume');
    }
    
    notifyListeners();
  }
  
  /// 🔊 Master volume ayarla
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    
    // Tüm çalan seslere uygula
    for (final entry in _players.entries) {
      if (_isPlaying[entry.key] == true) {
        final targetVolume = _volumes[entry.key]! * _masterVolume;
        await entry.value.setVolume(targetVolume);
      }
    }
    
    if (kDebugMode) debugPrint('🔊 Master volume: $_masterVolume');
    notifyListeners();
  }
  
  /// ❓ Ses çalıyor mu?
  bool isPlaying(String soundId) {
    return _isPlaying[soundId] ?? false;
  }
  
  /// ❓ Ses duraklatılmış mı?
  bool isPaused(String soundId) {
    final player = _players[soundId];
    if (player == null) return false;
    return !player.playing && player.processingState != ProcessingState.idle;
  }
  
  /// 📊 Mevcut pozisyon
  Duration getPosition(String soundId) {
    return _positions[soundId] ?? Duration.zero;
  }
  
  /// 📊 Ses uzunluğu
  Duration getDuration(String soundId) {
    return _durations[soundId] ?? Duration.zero;
  }
  
  /// 🔊 Volume al
  double getVolume(String soundId) {
    return _volumes[soundId] ?? 0.7;
  }
  
  @override
  void dispose() {
    if (kDebugMode) debugPrint('🧹 SeamlessAudioProvider dispose başlatıldı');
    _isDisposing = true;
    
    // Tüm player'ları dispose et
    for (final entry in _players.entries) {
      try {
        entry.value.dispose();
        if (kDebugMode) debugPrint('✅ Player disposed: ${entry.key}');
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Player dispose error: ${entry.key} - $e');
      }
    }
    _players.clear();
    
    super.dispose();
    if (kDebugMode) debugPrint('✅ SeamlessAudioProvider dispose tamamlandı');
  }
}
