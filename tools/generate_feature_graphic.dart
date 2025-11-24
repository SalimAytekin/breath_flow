import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🎨 Özellik grafiği oluşturuluyor...');
  
  await generateFeatureGraphic();
  
  print('✅ Özellik grafiği başarıyla oluşturuldu!');
  exit(0);
}

Future<void> generateFeatureGraphic() async {
  const width = 1024.0;
  const height = 500.0;
  
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
  
  // Gradient arka plan
  final gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A2E), // Koyu mavi
      Color(0xFF0F0F1E), // Daha koyu
      Color(0xFF16213E), // Orta ton
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  final paint = Paint()
    ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));
  
  canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  
  // Dekoratif daireler (nefes teması)
  _drawBreathCircles(canvas, width, height);
  
  // Ana başlık
  _drawText(
    canvas,
    'Breath Flow',
    width / 2,
    height / 2 - 60,
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  // Alt başlık
  _drawText(
    canvas,
    'Nefes Al, Rahatla, Huzur Bul',
    width / 2,
    height / 2 + 30,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: Colors.white.withOpacity(0.9),
  );
  
  // Özellikler
  _drawFeatures(canvas, width, height);
  
  // Resmi kaydet
  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  final file = File('play_store_assets/feature_graphic.png');
  await file.create(recursive: true);
  await file.writeAsBytes(buffer);
  
  print('📁 Dosya kaydedildi: ${file.path}');
}

void _drawBreathCircles(Canvas canvas, double width, double height) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  
  // Sol üst köşe - Mavi tonlar
  for (int i = 0; i < 3; i++) {
    paint.color = Color(0xFF4A90E2).withOpacity(0.2 - i * 0.05);
    canvas.drawCircle(
      Offset(100, 100),
      80.0 + i * 40,
      paint,
    );
  }
  
  // Sağ alt köşe - Mor tonlar
  for (int i = 0; i < 3; i++) {
    paint.color = Color(0xFF9B59B6).withOpacity(0.2 - i * 0.05);
    canvas.drawCircle(
      Offset(width - 100, height - 100),
      60.0 + i * 30,
      paint,
    );
  }
  
  // Orta sağ - Turkuaz tonlar
  for (int i = 0; i < 2; i++) {
    paint.color = Color(0xFF1ABC9C).withOpacity(0.15 - i * 0.05);
    canvas.drawCircle(
      Offset(width - 150, height / 2),
      50.0 + i * 25,
      paint,
    );
  }
}

void _drawText(
  Canvas canvas,
  String text,
  double x,
  double y, {
  double fontSize = 24,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.white,
  TextAlign textAlign = TextAlign.center,
}) {
  final textSpan = TextSpan(
    text: text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'Roboto',
      letterSpacing: 1.2,
    ),
  );
  
  final textPainter = TextPainter(
    text: textSpan,
    textAlign: textAlign,
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(x - textPainter.width / 2, y - textPainter.height / 2),
  );
}

void _drawFeatures(Canvas canvas, double width, double height) {
  final features = [
    '🧘 Nefes Egzersizleri',
    '🎵 Rahatlatıcı Sesler',
    '😴 Uyku Takibi',
  ];
  
  final startX = 100.0;
  final startY = height - 80.0;
  final spacing = 280.0;
  
  for (int i = 0; i < features.length; i++) {
    _drawText(
      canvas,
      features[i],
      startX + i * spacing,
      startY,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.8),
    );
  }
}
