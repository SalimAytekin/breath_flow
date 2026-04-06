import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/fitness_content.dart';
import 'ai_program_detail_screen.dart';

/// MOCK AI Posture Scan Ekranı
/// Gerçek kamera yok — animasyonlu "tarama" ve mock skor sonucu gösterir.
class MockPostureScanScreen extends StatefulWidget {
  const MockPostureScanScreen({super.key});

  @override
  State<MockPostureScanScreen> createState() => _MockPostureScanScreenState();
}

enum _ScanState { initial, scanning, result }

class _MockPostureScanScreenState extends State<MockPostureScanScreen>
    with TickerProviderStateMixin {
  _ScanState _state = _ScanState.initial;

  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnim;

  final int _mockScore = 72;
  final _mockIssues = [
    _PostureIssue('Forward Head Posture', 'Baş öne düşmüş', Colors.orangeAccent),
    _PostureIssue('Rounded Shoulders', 'Yuvarlak omuzlar', Colors.orangeAccent),
  ];
  final _mockProgram = FitnessContent.posture21DayReset;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scoreAnim = Tween<double>(begin: 0, end: _mockScore / 100)
        .animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _pulseController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() => _state = _ScanState.scanning);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _state = _ScanState.result);
        _scoreController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: switch (_state) {
            _ScanState.initial => _buildInitialScreen(),
            _ScanState.scanning => _buildScanningScreen(),
            _ScanState.result => _buildResultScreen(),
          },
        ),
      ),
    );
  }

  // ─── EKRAN 1: BAŞLANGIÇ ─────────────────────────────────────────
  Widget _buildInitialScreen() {
    return Column(
      key: const ValueKey('initial'),
      children: [
        _buildTopBar(),
        const Spacer(),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, __) => Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C63FF)
                    .withOpacity(0.4 + _pulseController.value * 0.4),
                width: 2,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.1),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 70)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'AI Postur Analizi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Kamera açılıyor ve yapay zeka postür sorunlarınızı analiz ediyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoChips(),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: GestureDetector(
            onTap: _startScan,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B80FF)],
                ),
              ),
              child: const Center(
                child: Text(
                  'Taramayı Başlat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip('🎯 Baş Pozisyonu'),
        const SizedBox(width: 8),
        _chip('💪 Omuzlar'),
        const SizedBox(width: 8),
        _chip('🦴 Omurga'),
      ],
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      );

  // ─── EKRAN 2: TARAMA ────────────────────────────────────────────
  Widget _buildScanningScreen() {
    return Column(
      key: const ValueKey('scanning'),
      children: [
        _buildTopBar(),
        const Spacer(),
        Stack(
          alignment: Alignment.center,
          children: [
            // Mock kamera çerçevesi
            Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.5), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🧍', style: const TextStyle(fontSize: 100)),
                  ],
                ),
              ),
            ),
            // Tarama çizgisi
            AnimatedBuilder(
              animation: _scanLineController,
              builder: (_, __) {
                final y = lerpDouble(-140, 140, _scanLineController.value)!;
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Container(
                    width: 260,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF6C63FF),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Köşe işaretçileri
            ..._buildCorners(),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          'Analiz ediliyor...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Lütfen düz durun ve hareketsiz kalın',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const thickness = 3.0;
    const color = Color(0xFF6C63FF);
    const offset = Offset(130, 170);
    return [
      Positioned(
        top: -offset.dy, left: -offset.dx,
        child: _corner(size, thickness, color, topLeft: true),
      ),
      Positioned(
        top: -offset.dy, right: -offset.dx,
        child: _corner(size, thickness, color, topRight: true),
      ),
      Positioned(
        bottom: -offset.dy, left: -offset.dx,
        child: _corner(size, thickness, color, bottomLeft: true),
      ),
      Positioned(
        bottom: -offset.dy, right: -offset.dx,
        child: _corner(size, thickness, color, bottomRight: true),
      ),
    ];
  }

  Widget _corner(double size, double t, Color c,
      {bool topLeft = false,
      bool topRight = false,
      bool bottomLeft = false,
      bool bottomRight = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(c, t, topLeft, topRight, bottomLeft, bottomRight),
      ),
    );
  }

  // ─── EKRAN 3: SONUÇ ─────────────────────────────────────────────
  Widget _buildResultScreen() {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildTopBar(title: 'Analiz Tamamlandı'),
          const SizedBox(height: 24),

          // Skor dairesi
          _ScoreRing(animation: _scoreAnim, score: _mockScore),

          const SizedBox(height: 28),

          // Tespit edilen sorunlar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TESPİT EDİLEN SORUNLAR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ..._mockIssues.map((issue) => _IssueCard(issue: issue)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Önerilen program
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÖNERİLEN PROGRAM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AIProgramDetailScreen(program: _mockProgram)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.tealAccent.withOpacity(0.15),
                          Colors.black54,
                        ],
                      ),
                      border: Border.all(
                          color: Colors.tealAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(_mockProgram.icon,
                            style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mockProgram.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _mockProgram.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Başla',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTopBar({String title = 'AI Posture Scan'}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// YARDIMCI WİDGET'LAR
// ─────────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final Animation<double> animation;
  final int score;

  const _ScoreRing({required this.animation, required this.score});

  Color get _scoreColor {
    if (score >= 80) return Colors.greenAccent;
    if (score >= 60) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => SizedBox(
        width: 180,
        height: 180,
        child: CustomPaint(
          painter: _RingPainter(animation.value, _scoreColor),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(animation.value * 100).toInt()}',
                  style: TextStyle(
                    color: _scoreColor,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  '/ 100',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Posture Score',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    // Arka plan
    canvas.drawCircle(center, radius,
        Paint()
          ..color = Colors.white.withOpacity(0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10);

    // İlerleme yayı
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool tl, tr, bl, br;
  const _CornerPainter(this.color, this.thickness, this.tl, this.tr, this.bl, this.br);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 20.0;
    if (tl) {
      canvas.drawLine(Offset.zero, Offset(len, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, len), paint);
    }
    if (tr) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    }
    if (bl) {
      canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    }
    if (br) {
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _PostureIssue {
  final String title;
  final String subtitle;
  final Color color;
  const _PostureIssue(this.title, this.subtitle, this.color);
}

class _IssueCard extends StatelessWidget {
  final _PostureIssue issue;
  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: issue.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: issue.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: issue.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(issue.subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
