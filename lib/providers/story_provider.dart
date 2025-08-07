import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/story_series.dart';

class StoryProvider extends ChangeNotifier {
  List<StorySeries> _allSeries = [];
  Map<String, int> _seriesProgress = {}; // seriesId -> son dinlenen bölüm
  Map<String, Set<String>> _unlockedEpisodes = {}; // seriesId -> unlocked episode IDs
  String? _currentlyPlayingEpisode;
  String? _currentlyPlayingSeries;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;
  
  // Getters
  List<StorySeries> get allSeries => _allSeries;
  Map<String, int> get seriesProgress => _seriesProgress;
  String? get currentlyPlayingEpisode => _currentlyPlayingEpisode;
  String? get currentlyPlayingSeries => _currentlyPlayingSeries;
  bool get isPlaying => _isPlaying;
  double get currentPosition => _currentPosition;
  double get totalDuration => _totalDuration;
  
  // Kategoriye göre seriler
  List<StorySeries> getSeriesByCategory(StoryCategory category) {
    return _allSeries.where((series) => series.category == category).toList();
  }
  
  // Popüler seriler (rating'e göre)
  List<StorySeries> get popularSeries {
    final sorted = List<StorySeries>.from(_allSeries);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }
  
  // Devam eden seriler
  List<StorySeries> get continueWatching {
    return _allSeries.where((series) {
      final progress = _seriesProgress[series.id] ?? 0;
      return progress > 0 && progress < series.totalEpisodes;
    }).toList();
  }
  
  // Yeni seriler
  List<StorySeries> get newSeries {
    return _allSeries.where((series) {
      final progress = _seriesProgress[series.id] ?? 0;
      return progress == 0;
    }).toList();
  }
  
  StoryProvider() {
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // Demo serileri ve ElevenLabs hikayeleri yükle
    _allSeries = [
      ...StorySeries.demoSeries,
      ...StorySeries.elevenlabsStories,
    ];
    
    // Kayıtlı verileri yükle
    await _loadProgress();
    
    // İlk bölümleri aç
    for (final series in _allSeries) {
      if (!_unlockedEpisodes.containsKey(series.id)) {
        _unlockedEpisodes[series.id] = {series.episodes.first.id};
      }
    }
    
    notifyListeners();
  }
  
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Seri ilerlemelerini yükle
      final progressJson = prefs.getString('story_progress');
      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        _seriesProgress = progressMap.map((key, value) => MapEntry(key, value as int));
      }
      
      // Açılmış bölümleri yükle
      final unlockedJson = prefs.getString('unlocked_episodes');
      if (unlockedJson != null) {
        final unlockedMap = json.decode(unlockedJson) as Map<String, dynamic>;
        _unlockedEpisodes = unlockedMap.map((key, value) => 
          MapEntry(key, Set<String>.from(value as List)));
      }
    } catch (e) {
      debugPrint('Hikaye verilerini yüklerken hata: $e');
    }
  }
  
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Seri ilerlemelerini kaydet
      await prefs.setString('story_progress', json.encode(_seriesProgress));
      
      // Açılmış bölümleri kaydet
      final unlockedMap = _unlockedEpisodes.map((key, value) => 
        MapEntry(key, value.toList()));
      await prefs.setString('unlocked_episodes', json.encode(unlockedMap));
    } catch (e) {
      debugPrint('Hikaye verilerini kaydederken hata: $e');
    }
  }
  
  // Bölüm kilidini aç
  Future<void> unlockEpisode(String seriesId, String episodeId) async {
    if (!_unlockedEpisodes.containsKey(seriesId)) {
      _unlockedEpisodes[seriesId] = <String>{};
    }
    
    _unlockedEpisodes[seriesId]!.add(episodeId);
    await _saveProgress();
    notifyListeners();
  }
  
  // Bölüm açık mı kontrol et
  bool isEpisodeUnlocked(String seriesId, String episodeId) {
    return _unlockedEpisodes[seriesId]?.contains(episodeId) ?? false;
  }
  
  // Bölüm tamamlandı olarak işaretle
  Future<void> markEpisodeCompleted(String seriesId, String episodeId) async {
    final series = _allSeries.firstWhere((s) => s.id == seriesId);
    final episode = series.episodes.firstWhere((e) => e.id == episodeId);
    
    // İlerlemeyi güncelle
    _seriesProgress[seriesId] = episode.episodeNumber;
    
    // Sonraki bölümü aç
    final nextEpisodeIndex = series.episodes.indexOf(episode) + 1;
    if (nextEpisodeIndex < series.episodes.length) {
      final nextEpisode = series.episodes[nextEpisodeIndex];
      await unlockEpisode(seriesId, nextEpisode.id);
    }
    
    await _saveProgress();
    notifyListeners();
  }
  
  // Bölüm oynatma kontrolü
  void playEpisode(String seriesId, String episodeId) {
    _currentlyPlayingSeries = seriesId;
    _currentlyPlayingEpisode = episodeId;
    _isPlaying = true;
    _currentPosition = 0.0;
    
    // Gerçek uygulamada burada ses dosyası çalınacak
    // Şimdilik demo amaçlı
    
    notifyListeners();
  }
  
  void pauseEpisode() {
    _isPlaying = false;
    notifyListeners();
  }
  
  void resumeEpisode() {
    _isPlaying = true;
    notifyListeners();
  }
  
  void stopEpisode() {
    _isPlaying = false;
    _currentlyPlayingEpisode = null;
    _currentlyPlayingSeries = null;
    _currentPosition = 0.0;
    _totalDuration = 0.0;
    notifyListeners();
  }
  
  void updatePosition(double position, double duration) {
    _currentPosition = position;
    _totalDuration = duration;
    notifyListeners();
  }
  
  // Seri istatistikleri
  int getSeriesProgress(String seriesId) {
    return _seriesProgress[seriesId] ?? 0;
  }
  
  double getSeriesProgressPercentage(String seriesId) {
    final series = _allSeries.firstWhere((s) => s.id == seriesId);
    final progress = _seriesProgress[seriesId] ?? 0;
    return progress / series.totalEpisodes;
  }
  
  // Sonraki bölümü al
  StoryEpisode? getNextEpisode(String seriesId) {
    final series = _allSeries.firstWhere((s) => s.id == seriesId);
    final progress = _seriesProgress[seriesId] ?? 0;
    
    if (progress < series.episodes.length) {
      return series.episodes[progress];
    }
    return null;
  }
  
  // Arama
  List<StorySeries> searchSeries(String query) {
    if (query.isEmpty) return _allSeries;
    
    final lowerQuery = query.toLowerCase();
    return _allSeries.where((series) {
      return series.title.toLowerCase().contains(lowerQuery) ||
             series.description.toLowerCase().contains(lowerQuery) ||
             series.author.toLowerCase().contains(lowerQuery) ||
             series.narrator.toLowerCase().contains(lowerQuery) ||
             series.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  // Favori sistem (gelecekte eklenebilir)
  final Set<String> _favoriteSeriesIds = <String>{};
  
  Set<String> get favoriteSeriesIds => _favoriteSeriesIds;
  
  void toggleFavorite(String seriesId) {
    if (_favoriteSeriesIds.contains(seriesId)) {
      _favoriteSeriesIds.remove(seriesId);
    } else {
      _favoriteSeriesIds.add(seriesId);
    }
    notifyListeners();
  }
  
  bool isFavorite(String seriesId) {
    return _favoriteSeriesIds.contains(seriesId);
  }
  
  List<StorySeries> get favoriteSeries {
    return _allSeries.where((series) => 
      _favoriteSeriesIds.contains(series.id)).toList();
  }
} 