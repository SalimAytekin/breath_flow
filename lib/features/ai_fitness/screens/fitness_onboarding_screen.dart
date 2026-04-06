import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fitness_exercise.dart';
import '../providers/user_goal_provider.dart';

/// 2 adımlı kısa onboarding:
/// Adım 1 — Hedef seçimi
/// Adım 2 — Günlük süre seçimi
class FitnessOnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const FitnessOnboardingScreen({super.key, required this.onComplete});

  @override
  State<FitnessOnboardingScreen> createState() =>
      _FitnessOnboardingScreenState();
}

class _FitnessOnboardingScreenState extends State<FitnessOnboardingScreen> {
  int _step = 0;
  UserGoal? _selectedGoal;
  int? _selectedDuration;

  final _goals = [
    _GoalOption(
      goal: UserGoal.posture,
      icon: '🦴',
      title: 'Boyun veya bel ağrımı azaltmak',
      subtitle: 'Postür düzeltme ve terapi programları',
    ),
    _GoalOption(
      goal: UserGoal.strength,
      icon: '💪',
      title: 'Güçlenmek ve kas yapmak',
      subtitle: 'Strength ve kondisyon programları',
    ),
    _GoalOption(
      goal: UserGoal.mobility,
      icon: '🌿',
      title: 'Esnekliğimi artırmak',
      subtitle: 'Mobility, yoga ve akış programları',
    ),
    _GoalOption(
      goal: UserGoal.quick,
      icon: '⚡',
      title: 'Kısa ve etkili egzersiz yapmak',
      subtitle: '5–10 dakikalık yüksek yoğunluklu seriler',
    ),
  ];

  final _durations = [
    _DurationOption(minutes: 5, label: '5 dakika', sub: 'Express rutin'),
    _DurationOption(minutes: 10, label: '10 dakika', sub: 'Standart seans'),
    _DurationOption(minutes: 15, label: '15+ dakika', sub: 'Tam antrenman'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Adım göstergesi
              _StepIndicator(current: _step, total: 2),
              const SizedBox(height: 40),

              // İçerik — adıma göre değişir
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _step == 0 ? _buildGoalStep() : _buildDurationStep(),
                ),
              ),

              // Alt buton alanı
              _buildBottomArea(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalStep() {
    return Column(
      key: const ValueKey('goal'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sana uygun programı\nhazırlayalım.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Önceliğin ne?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final g = _goals[i];
              final selected = _selectedGoal == g.goal;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = g.goal),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(g.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              g.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.black)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationStep() {
    return Column(
      key: const ValueKey('duration'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Güne ne kadar\nzaman ayırabilirsin?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'İstediğin zaman değiştirebilirsin.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          children: _durations.map((d) {
            final selected = _selectedDuration == d.minutes;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDuration = d.minutes),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.08),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.sub,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomArea(BuildContext context) {
    final canProceed = _step == 0 ? _selectedGoal != null : _selectedDuration != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: canProceed ? 1.0 : 0.4,
            child: GestureDetector(
              onTap: canProceed ? () => _handleContinue(context) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _step == 0 ? 'Devam Et' : 'Başla →',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Skip
        GestureDetector(
          onTap: () => _skip(context),
          child: Center(
            child: Text(
              'Şimdilik geç →',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleContinue(BuildContext context) {
    if (_step == 0) {
      setState(() => _step = 1);
    } else {
      _saveAndComplete(context);
    }
  }

  void _skip(BuildContext context) {
    final provider = context.read<UserGoalProvider>();
    provider.setGoal(UserGoal.posture);
    provider.setDuration(10);
    provider.completeOnboarding();
    widget.onComplete();
  }

  void _saveAndComplete(BuildContext context) {
    final provider = context.read<UserGoalProvider>();
    if (_selectedGoal != null) provider.setGoal(_selectedGoal!);
    if (_selectedDuration != null) provider.setDuration(_selectedDuration!);
    provider.completeOnboarding();
    widget.onComplete();
  }
}

// ─── Yardımcı widget'lar ─────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _GoalOption {
  final UserGoal goal;
  final String icon;
  final String title;
  final String subtitle;
  const _GoalOption({
    required this.goal,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _DurationOption {
  final int minutes;
  final String label;
  final String sub;
  const _DurationOption({
    required this.minutes,
    required this.label,
    required this.sub,
  });
}
