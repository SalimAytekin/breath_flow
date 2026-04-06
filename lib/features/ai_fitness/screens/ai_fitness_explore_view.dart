import 'package:flutter/material.dart';
import '../models/fitness_exercise.dart';
import '../data/fitness_content.dart';
import 'ai_program_detail_screen.dart';

/// Beden Modu — Keşfet Ekranı
/// Rol: İçerik keşfi. Kullanıcı önce kategori seçer, sonra program görür.
/// Akış: 2×2 Kategori Grid → Kategori Detay → Program Detay
class AIFitnessExploreView extends StatefulWidget {
  const AIFitnessExploreView({super.key});

  @override
  State<AIFitnessExploreView> createState() => _AIFitnessExploreViewState();
}

class _AIFitnessExploreViewState extends State<AIFitnessExploreView> {
  FitnessCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: _selectedCategory == null
          ? _CategoryGridView(
              key: const ValueKey('grid'),
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            )
          : _CategoryDetailView(
              key: ValueKey(_selectedCategory),
              category: _selectedCategory!,
              onBack: () => setState(() => _selectedCategory = null),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// 2×2 KATEGORİ GRID
// ─────────────────────────────────────────────────────────────────
class _CategoryGridView extends StatelessWidget {
  final ValueChanged<FitnessCategory> onSelect;
  const _CategoryGridView({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 64),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ne çalışmak\nistiyorsun?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Bir kategori seç.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            physics: const NeverScrollableScrollPhysics(),
            children: _categoryItems.map((item) {
              final count = FitnessContent
                  .getProgramsByCategory(item.category)
                  .length;
              return _CategoryCard(
                item: item,
                programCount: count,
                onTap: () => onSelect(item.category),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 100 + MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final int programCount;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.item,
    required this.programCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: item.color.withOpacity(0.22)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 36)),
            const Spacer(),
            Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$programCount program',
              style: TextStyle(
                color: item.color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// KATEGORİ DETAY
// (1 Featured Program + max 3 liste öğesi)
// ─────────────────────────────────────────────────────────────────
class _CategoryDetailView extends StatelessWidget {
  final FitnessCategory category;
  final VoidCallback onBack;
  const _CategoryDetailView({
    super.key,
    required this.category,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Kuralı uygula: max 4 program (getProgramsByCategory featured öne alır)
    final programs = FitnessContent.getProgramsByCategory(category);
    final featured = programs.isNotEmpty ? programs.first : null;
    // Featured hariç max 3
    final rest = programs.skip(featured != null ? 1 : 0).take(3).toList();
    final item = _categoryItems.firstWhere((i) => i.category == category);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
              height: MediaQuery.of(context).padding.top + 56),
        ),

        // ── Başlık + Geri ───────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${item.icon}  ${item.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── FEATURED PROGRAM ─────────────────────────
        if (featured != null) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _FeaturedProgramCard(program: featured, accent: item.color),
            ),
          ),
        ],

        // ── DİĞER PROGRAMLAR ─────────────────────────
        if (rest.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'DİĞER PROGRAMLAR',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: _ProgramListRow(program: rest[i]),
              ),
              childCount: rest.length,
            ),
          ),
        ],

        SliverToBoxAdapter(
          child: SizedBox(
              height: 100 + MediaQuery.of(context).padding.bottom),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// FEATURED PROGRAM KARTI (büyük)
// ─────────────────────────────────────────────────────────────────
class _FeaturedProgramCard extends StatelessWidget {
  final FitnessProgram program;
  final Color accent;
  const _FeaturedProgramCard({required this.program, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AIProgramDetailScreen(program: program)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withOpacity(0.20), const Color(0xFF0F0F14)],
          ),
          border: Border.all(color: accent.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ÖNE ÇIKAN',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(program.icon,
                    style: const TextStyle(fontSize: 36)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              program.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              program.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _metaChip(Icons.timer_outlined, program.totalDuration),
                const SizedBox(width: 8),
                if (program.weekCount > 0)
                  _metaChip(Icons.calendar_today_outlined,
                      '${program.weekCount} hafta'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Detayı Gör',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white54),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
// PROGRAM LİSTE SATIRI
// ─────────────────────────────────────────────────────────────────
class _ProgramListRow extends StatelessWidget {
  final FitnessProgram program;
  const _ProgramListRow({required this.program});

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(program.icon,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    program.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (program.isNew)
              _tag('YENİ', Colors.greenAccent)
            else if (program.isPremium)
              _tag('PRO', Colors.amber),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.20), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800)),
      );
}

// ─────────────────────────────────────────────────────────────────
// KATEGORİ META VERİLERİ
// ─────────────────────────────────────────────────────────────────
class _CategoryItem {
  final FitnessCategory category;
  final String icon;
  final String name;
  final Color color;
  const _CategoryItem(this.category, this.icon, this.name, this.color);
}

const _categoryItems = [
  _CategoryItem(FitnessCategory.posture,  '🧘', 'Posture & Therapy',  Color(0xFF64FFDA)),
  _CategoryItem(FitnessCategory.strength, '💪', 'Strength',           Color(0xFFFF8A00)),
  _CategoryItem(FitnessCategory.mobility, '🌿', 'Mobility & Yoga',    Color(0xFFEA80FC)),
  _CategoryItem(FitnessCategory.quick,    '⚡', 'Quick Workouts',     Color(0xFF448AFF)),
];
