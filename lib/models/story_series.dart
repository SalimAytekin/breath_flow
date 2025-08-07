import 'package:flutter/material.dart';

enum StoryCategory {
  mythology,
  sciFi,
  mystery,
  fantasy,
  nature,
  history,
  philosophy,
}

enum StoryDifficulty {
  beginner,
  intermediate,
  advanced,
}

class StoryEpisode {
  final String id;
  final String title;
  final String description;
  final int episodeNumber;
  final int durationMinutes;
  final String audioPath;
  final String? transcript;
  final bool isUnlocked;
  final bool isPremium;
  final DateTime? releaseDate;

  const StoryEpisode({
    required this.id,
    required this.title,
    required this.description,
    required this.episodeNumber,
    required this.durationMinutes,
    required this.audioPath,
    this.transcript,
    this.isUnlocked = false,
    this.isPremium = false,
    this.releaseDate,
  });

  factory StoryEpisode.fromJson(Map<String, dynamic> json) {
    return StoryEpisode(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      episodeNumber: json['episodeNumber'],
      durationMinutes: json['durationMinutes'],
      audioPath: json['audioPath'],
      transcript: json['transcript'],
      isUnlocked: json['isUnlocked'] ?? false,
      isPremium: json['isPremium'] ?? false,
      releaseDate: json['releaseDate'] != null 
        ? DateTime.parse(json['releaseDate'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'episodeNumber': episodeNumber,
      'durationMinutes': durationMinutes,
      'audioPath': audioPath,
      'transcript': transcript,
      'isUnlocked': isUnlocked,
      'isPremium': isPremium,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }
}

class StorySeries {
  final String id;
  final String title;
  final String description;
  final String author;
  final String narrator;
  final StoryCategory category;
  final StoryDifficulty difficulty;
  final List<StoryEpisode> episodes;
  final String coverImagePath;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isPremium;
  final bool isCompleted;
  final double rating;
  final int totalListeners;
  final String? previewAudioPath;
  final List<String> tags;

  const StorySeries({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.narrator,
    required this.category,
    required this.difficulty,
    required this.episodes,
    required this.coverImagePath,
    required this.primaryColor,
    required this.secondaryColor,
    this.isPremium = false,
    this.isCompleted = false,
    this.rating = 0.0,
    this.totalListeners = 0,
    this.previewAudioPath,
    this.tags = const [],
  });

  int get totalEpisodes => episodes.length;
  int get totalDuration => episodes.fold(0, (sum, episode) => sum + episode.durationMinutes);
  int get unlockedEpisodes => episodes.where((e) => e.isUnlocked).length;
  
  StoryEpisode? get nextEpisode {
    final unlockedEpisodes = episodes.where((e) => e.isUnlocked).toList();
    if (unlockedEpisodes.isEmpty) return episodes.first;
    
    final lastUnlocked = unlockedEpisodes.last;
    final nextIndex = episodes.indexOf(lastUnlocked) + 1;
    
    return nextIndex < episodes.length ? episodes[nextIndex] : null;
  }

  factory StorySeries.fromJson(Map<String, dynamic> json) {
    return StorySeries(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      narrator: json['narrator'],
      category: StoryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => StoryCategory.fantasy,
      ),
      difficulty: StoryDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => StoryDifficulty.beginner,
      ),
      episodes: (json['episodes'] as List)
          .map((e) => StoryEpisode.fromJson(e))
          .toList(),
      coverImagePath: json['coverImagePath'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      isPremium: json['isPremium'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalListeners: json['totalListeners'] ?? 0,
      previewAudioPath: json['previewAudioPath'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'narrator': narrator,
      'category': category.name,
      'difficulty': difficulty.name,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'coverImagePath': coverImagePath,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'isPremium': isPremium,
      'isCompleted': isCompleted,
      'rating': rating,
      'totalListeners': totalListeners,
      'previewAudioPath': previewAudioPath,
      'tags': tags,
    };
  }

  // Demo içerik - Türk mitolojisi temalı
  static final List<StorySeries> demoSeries = [
    StorySeries(
      id: 'turkish_mythology',
      title: 'Anadolu\'nun Kayıp Efsaneleri',
      description: 'Türk mitolojisinden unutulmuş hikayeler. Her gece yeni bir efsane, yeni bir macera.',
      author: 'Ahmet Ümit',
      narrator: 'Müjde Ar',
      category: StoryCategory.mythology,
      difficulty: StoryDifficulty.beginner,
      coverImagePath: 'assets/images/series/turkish_mythology.jpg',
      primaryColor: const Color(0xFF8B4513),
      secondaryColor: const Color(0xFFDAA520),
      isPremium: false,
      rating: 4.8,
      totalListeners: 15420,
      tags: ['Türk Mitolojisi', 'Efsane', 'Kültür'],
      episodes: [
        StoryEpisode(
          id: 'tm_01',
          title: 'Ergenekon\'dan Çıkış',
          description: 'Türklerin Ergenekon\'dan çıkış efsanesi ve yeni topraklar bulma serüveni.',
          episodeNumber: 1,
          durationMinutes: 25,
          audioPath: 'assets/audio/stories/turkish_mythology/episode_01.mp3',
          isUnlocked: true,
        ),
        StoryEpisode(
          id: 'tm_02',
          title: 'Bozkurt\'un İzinde',
          description: 'Kutsal kurdun rehberliğinde yapılan yolculuk ve karşılaşılan zorluklarla.',
          episodeNumber: 2,
          durationMinutes: 28,
          audioPath: 'assets/audio/stories/turkish_mythology/episode_02.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'tm_03',
          title: 'Gök Tanrı\'nın Armağanı',
          description: 'Tengri\'nin Türk halkına verdiği kutsal armağan ve bunun sonuçları.',
          episodeNumber: 3,
          durationMinutes: 30,
          audioPath: 'assets/audio/stories/turkish_mythology/episode_03.mp3',
          isUnlocked: false,
        ),
      ],
    ),
    
    StorySeries(
      id: 'space_explorer',
      title: 'Kaşif Zara\'nın Galaksi Günlükleri',
      description: 'Uzak gelecekte, galaksiler arası keşif yapan Zara\'nın büyüleyici maceraları.',
      author: 'Barış Müstecaplıoğlu',
      narrator: 'Halit Ergenç',
      category: StoryCategory.sciFi,
      difficulty: StoryDifficulty.intermediate,
      coverImagePath: 'assets/images/series/space_explorer.jpg',
      primaryColor: const Color(0xFF4A148C),
      secondaryColor: const Color(0xFF7B1FA2),
      isPremium: true,
      rating: 4.9,
      totalListeners: 8750,
      tags: ['Bilim-Kurgu', 'Uzay', 'Keşif'],
      episodes: [
        StoryEpisode(
          id: 'se_01',
          title: 'Kepler-442b\'ye İlk Adım',
          description: 'Zara\'nın yaşanabilir gezegen arayışında bulduğu gizemli dünya.',
          episodeNumber: 1,
          durationMinutes: 32,
          audioPath: 'assets/audio/stories/space_explorer/episode_01.mp3',
          isUnlocked: true,
          isPremium: true,
        ),
        StoryEpisode(
          id: 'se_02',
          title: 'Kristal Ormanların Sırrı',
          description: 'Gezegenin kristal ormanlarında keşfedilen antik teknoloji.',
          episodeNumber: 2,
          durationMinutes: 35,
          audioPath: 'assets/audio/stories/space_explorer/episode_02.mp3',
          isUnlocked: false,
          isPremium: true,
        ),
      ],
    ),
    
    StorySeries(
      id: 'istanbul_mysteries',
      title: 'İstanbul\'un Gizli Tarihi',
      description: 'Şehrin derinliklerinde saklı kalan sırlar ve gizemli olaylar.',
      author: 'Elif Şafak',
      narrator: 'Erdal Beşikçioğlu',
      category: StoryCategory.mystery,
      difficulty: StoryDifficulty.advanced,
      coverImagePath: 'assets/images/series/istanbul_mysteries.jpg',
      primaryColor: const Color(0xFF1565C0),
      secondaryColor: const Color(0xFF42A5F5),
      isPremium: false,
      rating: 4.7,
      totalListeners: 12300,
      tags: ['Tarih', 'Gizem', 'İstanbul'],
      episodes: [
        StoryEpisode(
          id: 'im_01',
          title: 'Yerebatan\'ın Yankıları',
          description: 'Yerebatan Sarnıcı\'nda keşfedilen antik yazıtların gizemi.',
          episodeNumber: 1,
          durationMinutes: 27,
          audioPath: 'assets/audio/stories/istanbul_mysteries/episode_01.mp3',
          isUnlocked: true,
        ),
        StoryEpisode(
          id: 'im_02',
          title: 'Galata\'nın Kayıp Hazinesi',
          description: 'Galata Kulesi\'nin gizli odalarında saklanan hazine arayışı.',
          episodeNumber: 2,
          durationMinutes: 29,
          audioPath: 'assets/audio/stories/istanbul_mysteries/episode_02.mp3',
          isUnlocked: false,
        ),
      ],
    ),
  ];

  // ElevenLabs için optimize edilmiş Türkçe uyku hikayeleri
  static final List<StorySeries> elevenlabsStories = [
    StorySeries(
      id: 'sleep_stories_1_5',
      title: 'Huzur Dolu Anlar - 1. Koleksiyon',
      description: 'Doğanın sakinliği, uzayın büyüsü ve mistik maceraların yer aldığı ilk hikaye koleksiyonu.',
      author: 'BreatheFlow Studios',
      narrator: 'ElevenLabs AI',
      category: StoryCategory.nature,
      difficulty: StoryDifficulty.beginner,
      coverImagePath: 'assets/images/sounds/forest.jpg',
      primaryColor: const Color(0xFF2E7D32),
      secondaryColor: const Color(0xFF66BB6A),
      isPremium: false,
      rating: 4.9,
      totalListeners: 25640,
      tags: ['Doğa', 'Rahatlama', 'Uyku', 'Huzur'],
      episodes: [
        StoryEpisode(
          id: 'gizli_orman_golu',
          title: 'Gizli Orman Gölü',
          description: 'Zara, eski ormanın derinliklerinde keşfettiği büyülü gölde huzuru buluyor.',
          episodeNumber: 1,
          durationMinutes: 20,
          audioPath: 'assets/audio/stories/sleep_1_5/gizli_orman_golu.mp3',
          isUnlocked: true,
        ),
        StoryEpisode(
          id: 'yildizlar_arasinda_dinlenme',
          title: 'Yıldızlar Arasında Dinlenme',
          description: 'Kaptan Maya, uzay gemisinde yıldızların büyüsüne kapılıyor.',
          episodeNumber: 2,
          durationMinutes: 25,
          audioPath: 'assets/audio/stories/sleep_1_5/yildizlar_arasinda_dinlenme.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'gokkusagi_koprusu',
          title: 'Gökkuşağı Köprüsü',
          description: 'Küçük kuş Zıp, gökkuşağının üzerinde renklerin hikayelerini dinliyor.',
          episodeNumber: 3,
          durationMinutes: 18,
          audioPath: 'assets/audio/stories/sleep_1_5/gokkusagi_koprusu.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'kristal_magaranin_isiklari',
          title: 'Kristal Mağaranın Işıkları',
          description: 'Luna, dağların derinliklerinde kristal mağarasının sırlarını keşfediyor.',
          episodeNumber: 4,
          durationMinutes: 22,
          audioPath: 'assets/audio/stories/sleep_1_5/kristal_magaranin_isiklari.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'ay_isigindaki_gizli_yazit',
          title: 'Ay Işığındaki Gizli Yazıt',
          description: 'Dr. Elif, eski bir kütüphanede ay ışığında beliren gizli yazıtları çözüyor.',
          episodeNumber: 5,
          durationMinutes: 28,
          audioPath: 'assets/audio/stories/sleep_1_5/ay_isigindaki_gizli_yazit.mp3',
          isUnlocked: false,
        ),
      ],
    ),
    
    StorySeries(
      id: 'sleep_stories_6_10',
      title: 'Büyülü Keşifler - 2. Koleksiyon',
      description: 'Dağların sessizliği, büyülü ağaçlar ve gizli adaların yer aldığı ikinci hikaye koleksiyonu.',
      author: 'BreatheFlow Studios',
      narrator: 'ElevenLabs AI',
      category: StoryCategory.fantasy,
      difficulty: StoryDifficulty.beginner,
      coverImagePath: 'assets/images/sounds/campfire.jpg',
      primaryColor: const Color(0xFF5D4037),
      secondaryColor: const Color(0xFFBCAAA4),
      isPremium: false,
      rating: 4.8,
      totalListeners: 18730,
      tags: ['Fantastik', 'Macera', 'Uyku', 'Keşif'],
      episodes: [
        StoryEpisode(
          id: 'daglarin_sessizligi',
          title: 'Dağların Sessizliği',
          description: 'Mert, dağların yükseklerinde donmuş gölün kenarında huzuru buluyor.',
          episodeNumber: 1,
          durationMinutes: 24,
          audioPath: 'assets/audio/stories/sleep_6_10/daglarin_sessizligi.mp3',
          isUnlocked: true,
        ),
        StoryEpisode(
          id: 'buyulu_agacin_hikayesi',
          title: 'Büyülü Ağacın Hikayesi',
          description: 'Küçük peri Ayla, ormanın büyülü ağacında gizli sırları keşfediyor.',
          episodeNumber: 2,
          durationMinutes: 26,
          audioPath: 'assets/audio/stories/sleep_6_10/buyulu_agacin_hikayesi.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'gizli_ada_kesfi',
          title: 'Gizli Ada Keşfi',
          description: 'Denizci Kaptan Deniz, güzel bir adada huzurlu anlar yaşıyor.',
          episodeNumber: 3,
          durationMinutes: 30,
          audioPath: 'assets/audio/stories/sleep_6_10/gizli_ada_kesfi.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'yildiz_haritasinin_sirri',
          title: 'Yıldız Haritasının Sırrı',
          description: 'Astronom Profesör Yıldız, uzayda büyülü bir yıldız haritası keşfediyor.',
          episodeNumber: 4,
          durationMinutes: 32,
          audioPath: 'assets/audio/stories/sleep_6_10/yildiz_haritasinin_sirri.mp3',
          isUnlocked: false,
        ),
        StoryEpisode(
          id: 'eski_koyun_masallari',
          title: 'Eski Köyün Masalları',
          description: 'Tarihçi Dr. Anadolu, eski bir köyde çeşmenin suyunda saklı masalları keşfediyor.',
          episodeNumber: 5,
          durationMinutes: 28,
          audioPath: 'assets/audio/stories/sleep_6_10/eski_koyun_masallari.mp3',
          isUnlocked: false,
        ),
      ],
    ),
    
    StorySeries(
      id: 'sleep_stories_11_15',
      title: 'Mistik Dünyalar - 3. Koleksiyon',
      description: 'Bulutlardaki şehirler, deniz kabuklarının şarkıları ve zaman yolculuklarının yer aldığı üçüncü koleksiyon.',
      author: 'BreatheFlow Studios',
      narrator: 'ElevenLabs AI',
      category: StoryCategory.sciFi,
      difficulty: StoryDifficulty.intermediate,
      coverImagePath: 'assets/images/sounds/ocean.jpg',
      primaryColor: const Color(0xFF1565C0),
      secondaryColor: const Color(0xFF64B5F6),
      isPremium: true,
      rating: 4.9,
      totalListeners: 12450,
      tags: ['Bilim-Kurgu', 'Gizem', 'Premium', 'Mistik'],
      episodes: [
        StoryEpisode(
          id: 'bulutlarin_uzerindeki_sehir',
          title: 'Bulutların Üzerindeki Şehir',
          description: 'Küçük bulut perisi Bulut, gökyüzündeki kristal şehri keşfediyor.',
          episodeNumber: 1,
          durationMinutes: 25,
          audioPath: 'assets/audio/stories/sleep_11_15/bulutlarin_uzerindeki_sehir.mp3',
          isUnlocked: true,
          isPremium: true,
        ),
        StoryEpisode(
          id: 'deniz_kabuklarinin_sarkisi',
          title: 'Deniz Kabuklarının Şarkısı',
          description: 'Deniz kızı Deniz, okyanusun derinliklerinde müzik kutusu buluyor.',
          episodeNumber: 2,
          durationMinutes: 22,
          audioPath: 'assets/audio/stories/sleep_11_15/deniz_kabuklarinin_sarkisi.mp3',
          isUnlocked: false,
          isPremium: true,
        ),
        StoryEpisode(
          id: 'zaman_kapisinin_ardi',
          title: 'Zaman Kapısının Ardı',
          description: 'Dr. Zaman, laboratuvarında geleceğin dünyasına açılan kapıyı keşfediyor.',
          episodeNumber: 3,
          durationMinutes: 28,
          audioPath: 'assets/audio/stories/sleep_11_15/zaman_kapisinin_ardi.mp3',
          isUnlocked: false,
          isPremium: true,
        ),
        StoryEpisode(
          id: 'gizli_bahcenin_cicekleri',
          title: 'Gizli Bahçenin Çiçekleri',
          description: 'Küçük bahçıvan Çiçek, gizli bahçedeki nadir çiçekleri keşfediyor.',
          episodeNumber: 4,
          durationMinutes: 20,
          audioPath: 'assets/audio/stories/sleep_11_15/gizli_bahcenin_cicekleri.mp3',
          isUnlocked: false,
          isPremium: true,
        ),
        StoryEpisode(
          id: 'ayin_gizli_yuzu',
          title: 'Ay\'ın Gizli Yüzü',
          description: 'Ay kaşifi Luna, ay yüzeyinde kristal mağarada gizli sırları keşfediyor.',
          episodeNumber: 5,
          durationMinutes: 30,
          audioPath: 'assets/audio/stories/sleep_11_15/ayin_gizli_yuzu.mp3',
          isUnlocked: false,
          isPremium: true,
        ),
      ],
    ),
  ];
} 