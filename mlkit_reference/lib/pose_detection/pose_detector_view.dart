import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
// Gereksiz import kaldırıldı - Native coaching sistemi kullanılıyor
import '../services/pose/pose_detection_service.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({Key? key}) : super(key: key);

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  static const platform = MethodChannel('com.google.mlkit.vision.demo/pose_detector');
  
  bool _isDetecting = false;
  String _detectionStatus = 'Hazır';
  bool _hasPermission = false;
  List<Map<String, dynamic>> _exercises = [];
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadExercises();
  }
  
  Future<void> _checkPermissions() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    } else {
      _requestPermissions();
    }
  }
  
  Future<void> _requestPermissions() async {
    final status = await Permission.camera.request();
    
    setState(() {
      _hasPermission = status.isGranted;
      if (!_hasPermission) {
        _detectionStatus = 'Kamera izni verilmedi. Uygulamayı kullanmak için izin gerekli.';
      }
    });
  }
  
  Future<void> _loadExercises() async {
    try {
      final String response = await rootBundle.loadString('lib/data/exercises.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _exercises = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Egzersiz verilerini yükleme hatası: $e');
    }
  }
  
  Map<String, dynamic>? _getExerciseById(String id) {
    try {
      return _exercises.firstWhere((exercise) => exercise['id'] == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> _showExerciseSelectionDialog() async {
    // Sadece MLKit uyumlu egzersizleri göster
    final compatibleExercises = _exercises.where((exercise) => 
      exercise['compatibleWithMLKit'] == true
    ).toList();
    
    if (compatibleExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uyumlu egzersiz bulunamadı')),
      );
      return;
    }
    
    final selectedExercise = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Egzersiz Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: compatibleExercises.length,
              itemBuilder: (context, index) {
                final exercise = compatibleExercises[index];
                return ListTile(
                  title: Text(exercise['title'] ?? 'Egzersiz'),
                  subtitle: Text(exercise['description'] ?? ''),
                  onTap: () {
                    Navigator.of(context).pop(exercise);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
    
    if (selectedExercise != null) {
      await _startExerciseCoaching(selectedExercise);
    }
  }
  
  Future<void> _startExerciseCoaching(Map<String, dynamic> exerciseData) async {
    try {
      // JSON tabanlı coaching sistemini başlat
      await PoseDetectionService().startExerciseCoaching(
        exerciseName: exerciseData['title'] ?? 'Egzersiz',
        exerciseType: exerciseData['id'] ?? 'default',
        exerciseData: {
          'name': exerciseData['title'] ?? 'Egzersiz',
          'type': exerciseData['id'] ?? 'default',
          'description': exerciseData['description'] ?? 'Egzersiz açıklaması',
          'howTo': exerciseData['howTo'] ?? '',
          'duration': exerciseData['duration'] ?? '5 dk',
          'repetitions': exerciseData['repetitions'] ?? '10 tekrar',
          'analyzerType': exerciseData['analyzerType'] ?? 'default',
          'rules': exerciseData['rules'] ?? {},
          'feedback': exerciseData['feedback'] ?? [],
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Egzersiz başlatma hatası: $e')),
        );
      }
    }
  }
  
  // Native tarafı çağırmak için method
  Future<void> _startPoseDetection() async {
    if (!_hasPermission) {
      await _requestPermissions();
      if (!_hasPermission) return;
    }
    try {
      setState(() {
        _isDetecting = true;
        _detectionStatus = 'Algılama başlatılıyor...';
      });
      
      final result = await platform.invokeMethod('startPoseDetection');
      
      setState(() {
        _detectionStatus = 'Algılama başarılı: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _isDetecting = false;
        _detectionStatus = 'Algılama hatası: ${e.message}';
      });
    }
  }
  
  // Native algılamayı durdurmak için method
  Future<void> _stopPoseDetection() async {
    try {
      await platform.invokeMethod('stopPoseDetection');
      
      setState(() {
        _isDetecting = false;
        _detectionStatus = 'Algılama durduruldu';
      });
    } on PlatformException catch (e) {
      setState(() {
        _detectionStatus = 'Durdurma hatası: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fizik Tedavi Poz Algılama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Durum mesajı
            Center(
              child: Text(
                _detectionStatus,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            // Normal poz algılama modu
            _buildModeCard(
              title: 'Poz Algılama Modu',
              description: 'MLKit kullanarak vücut pozisyonlarını algılar ve ekranda gösterir.',
              icon: Icons.person,
              buttonText: !_hasPermission ? 'Kamera İzni İste' : (_isDetecting ? 'Algılamayı Durdur' : 'Başlat'),
              onTap: !_hasPermission ? _requestPermissions : (_isDetecting ? _stopPoseDetection : _startPoseDetection),
              color: Colors.blue,
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Egzersiz koçluk modu
            _buildModeCard(
              title: 'Egzersiz Koçluk Modu',
              description: 'Egzersizleri gerçek zamanlı koçluk ile yapmanıza rehberlik eder.',
              icon: Icons.sports_gymnastics,
              buttonText: 'Egzersiz Seç',
              onTap: _showExerciseSelectionDialog,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  
  // Mod seçim kartı widget'ı
  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
