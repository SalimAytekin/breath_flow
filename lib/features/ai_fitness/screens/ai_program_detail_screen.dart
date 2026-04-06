import 'package:flutter/material.dart';
import '../models/fitness_exercise.dart';
import 'ai_workout_summary_screen.dart';

/// Program Detay Ekranı
/// Hero + Meta + Neden İşe Yarar + Egzersiz Listesi + Sticky Start Button
class AIProgramDetailScreen extends StatelessWidget {
  final FitnessProgram program;
  const AIProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final color = program.categoryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HEADER ────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context, color)),

          // ── NEDEN İŞE YARAR? ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEDEN İŞE YARAR?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.38),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.07)),
                    ),
                    child: Text(
                      program.whyItWorks,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── EGZERSİZ LİSTESİ başlık ───────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Text(
                'BU PROGRAMDAKİ HAREKETLER',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // ── EGZERSİZ LİSTESİ ─────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ExerciseRow(
                exercise: program.exercises[i],
                index: i,
              ),
              childCount: program.exercises.length,
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
                height: 120 + MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),

      // Sticky start button
      bottomSheet: _buildStartButton(context, color),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 16, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.10),
            const Color(0xFF0F0F14),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Geri
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 17),
            ),
          ),

          const SizedBox(height: 22),

          // Emoji + Kategori rozeti + AI etiketi
          Row(
            children: [
              Text(program.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chip(program.categoryLabel, color),
                  if (program.exercises.any((e) => e.isAiEnabled)) ...[
                    const SizedBox(height: 5),
                    _chip('🤖 AI Destekli', const Color(0xFFEA80FC)),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Başlık
          Text(
            program.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),

          const SizedBox(height: 8),

          // Açıklama
          Text(
            program.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // Meta chip'ler
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.timer_outlined, program.totalDuration),
              if (program.weekCount > 0)
                _metaChip(Icons.calendar_today_outlined,
                    '${program.weekCount} hafta'),
              _metaChip(Icons.fitness_center_outlined,
                  program.difficultyLabel),
              _metaChip(Icons.repeat_rounded,
                  '${program.exerciseCount} hareket'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      );

  Widget _metaChip(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  // ─── STICKY START BUTTON ─────────────────────────────────────
  Widget _buildStartButton(BuildContext context, Color color) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 14, 24, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F14),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AIWorkoutSummaryScreen(program: program),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F0F14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Antrenmanı Başlat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EGZERSİZ SATIRI
// ─────────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  final FitnessExercise exercise;
  final int index;
  const _ExerciseRow({required this.exercise, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          // Sıra numarası
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Text(exercise.icon,
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  exercise.durationLabel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (exercise.isAiEnabled)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEA80FC).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '🤖 AI',
                style: TextStyle(
                  color: Color(0xFFEA80FC),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
