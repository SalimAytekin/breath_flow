import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../data/fitness_content.dart';
import '../models/fitness_exercise.dart';
import '../providers/user_goal_provider.dart';
import 'ai_program_detail_screen.dart';
import 'fitness_onboarding_screen.dart';
import 'mock_posture_scan_screen.dart';

/// Beden Modu — Ana Sayfa
/// Rol: Kullanıcıyı başlatmak. Listelemek değil.
/// İçerik: Greeting + Today's Workout + AI Posture Scan + Recommended (max 2)
class AIFitnessHomeView extends StatelessWidget {
  const AIFitnessHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserGoalProvider>(
      builder: (context, goalProvider, _) {
        // Onboarding henüz yapılmamışsa göster
        if (!goalProvider.onboardingDone) {
          return FitnessOnboardingScreen(
            onComplete: () {},
          );
        }

        final goal = goalProvider.goal;
        final hour = DateTime.now().hour;
        final todayProgram = FitnessContent.getRecommendedProgram(goal, hour);
        final recommended = FitnessContent.getRecommendedList(goal, limit: 2);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Üst boşluk (toggle çubuğu için)
            SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 72),
            ),

            // ── GREETING ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(hour),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bugün vücuduna yatırım yap.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── TODAY'S WORKOUT ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _TodaysWorkoutCard(program: todayProgram),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── AI POSTURE SCAN ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _PostureScanBanner(),
              ),
            ),

            // ── SANA ÖZEL ─────────────────────────────────
            if (recommended.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'SANA ÖZEL',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.38),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 148,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: recommended
                        .map((p) => _RecommendedCard(program: p))
                        .toList(),
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: SizedBox(
                  height: 120 + MediaQuery.of(context).padding.bottom),
            ),
          ],
        );
      },
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Günaydın ☀️';
    if (hour < 18) return 'İyi öğleden sonralar.';
    if (hour < 21) return 'İyi akşamlar 🌙';
    return 'Geç saatte de olsa 💪';
  }
}

// ─────────────────────────────────────────────────────────────────
// TODAY'S WORKOUT KARTI
// ─────────────────────────────────────────────────────────────────
class _TodaysWorkoutCard extends StatelessWidget {
  final FitnessProgram program;
  const _TodaysWorkoutCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final color = program.categoryColor;

    return GestureDetector(
      onTap: () => _goToDetail(context),
      child: Container(
        height: 186,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.20), const Color(0xFF0F0F14)],
          ),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "BUGÜNÜN ANTRENMANI",
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    program.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    program.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.50),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _goToDetail(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.black, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Başla',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(program.icon, style: const TextStyle(fontSize: 72)),
          ],
        ),
      ),
    );
  }

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AIProgramDetailScreen(program: program)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AI POSTURE SCAN BANNER
// ─────────────────────────────────────────────────────────────────
class _PostureScanBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MockPostureScanScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF13132A),
          border: Border.all(
              color: const Color(0xFF6C63FF).withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.12),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.35)),
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AI Posture Scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('YENİ',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Postür puanını öğren →',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// RECOMMENDED CARD (küçük, yatay scroll)
// ─────────────────────────────────────────────────────────────────
class _RecommendedCard extends StatelessWidget {
  final FitnessProgram program;
  const _RecommendedCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final color = program.categoryColor;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AIProgramDetailScreen(program: program)),
      ),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(program.icon,
                    style: const TextStyle(fontSize: 24)),
                if (program.isNew)
                  _badge('YENİ', Colors.greenAccent)
                else if (program.isPremium)
                  _badge('PRO', Colors.amber),
              ],
            ),
            const Spacer(),
            Text(
              program.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              program.totalDuration,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800)),
      );
}
