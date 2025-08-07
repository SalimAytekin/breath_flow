import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/mood_insights_widget.dart';
import '../widgets/add_journal_entry_dialog.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  JournalEntryType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Günlüğüm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              _filterType != null ? FeatherIcons.filter : FeatherIcons.filter,
              color: _filterType != null ? AppColors.primary : null,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(FeatherIcons.moreVertical),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                  break;
                case 'insights':
                  _showInsightsDialog();
                  break;
                case 'clear':
                  _showClearDataDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'insights',
                child: Row(
                  children: [
                    Icon(FeatherIcons.trendingUp, size: 18),
                    SizedBox(width: 12),
                    Text('İçgörüler'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(FeatherIcons.download, size: 18),
                    SizedBox(width: 12),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(FeatherIcons.trash2, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Tümünü Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              icon: Icon(FeatherIcons.clock),
              text: 'Zaman Tüneli',
            ),
            Tab(
              icon: Icon(FeatherIcons.calendar),
              text: 'Takvim',
            ),
            Tab(
              icon: Icon(FeatherIcons.barChart2),
              text: 'Analiz',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(FeatherIcons.plus),
        label: const Text('Yeni Kayıt'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(),
          _buildCalendarTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        List<JournalEntry> entries = journalProvider.entries;
        
        // Filtre uygula
        if (_filterType != null) {
          entries = entries.where((e) => e.type == _filterType).toList();
        }

        if (entries.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Provider zaten verileri yüklü tutuyor
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isFirstOfDay = index == 0 || 
                  !_isSameDay(entry.timestamp, entries[index - 1].timestamp);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstOfDay) ...[
                    if (index > 0) const SizedBox(height: 24),
                    _buildDateHeader(entry.timestamp),
                    const SizedBox(height: 12),
                  ],
                  JournalEntryCard(
                    entry: entry,
                    onTap: () => _showEntryDetail(entry),
                    onEdit: () => _editEntry(entry),
                    onDelete: () => _deleteEntry(entry),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCalendarWidget(journalProvider),
              const SizedBox(height: 24),
              _buildSelectedDateEntries(journalProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              MoodInsightsWidget(journalProvider: journalProvider),
              const SizedBox(height: 24),
              _buildWeeklyMoodChart(journalProvider),
              const SizedBox(height: 24),
              _buildActivityInsights(journalProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FeatherIcons.bookOpen,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz günlük kaydın yok',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk kaydını oluşturmak için + butonuna dokunun',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddEntryDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(FeatherIcons.plus),
            label: const Text('İlk Kaydını Oluştur'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    
    String headerText;
    if (entryDay == today) {
      headerText = 'Bugün';
    } else if (entryDay == today.subtract(const Duration(days: 1))) {
      headerText = 'Dün';
    } else if (entryDay.isAfter(today.subtract(const Duration(days: 7)))) {
      headerText = DateFormat('EEEE', 'tr_TR').format(date);
    } else {
      headerText = DateFormat('d MMMM yyyy', 'tr_TR').format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        headerText,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCalendarWidget(JournalProvider journalProvider) {
    // Basit takvim widget'ı - gelişmiş versiyonu için table_calendar paketi kullanılabilir
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Seçilen tarih: ${DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: const Text('Tarih Seç'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateEntries(JournalProvider journalProvider) {
    final entries = journalProvider.getEntriesForDate(_selectedDate);
    
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              FeatherIcons.calendar,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu tarihte kayıt yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${entries.length} kayıt bulundu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JournalEntryCard(
            entry: entry,
            onTap: () => _showEntryDetail(entry),
            onEdit: () => _editEntry(entry),
            onDelete: () => _deleteEntry(entry),
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildWeeklyMoodChart(JournalProvider journalProvider) {
    final weeklyTrend = journalProvider.weeklyMoodTrend;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haftalık Ruh Hali Trendi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = weeklyTrend.isNotEmpty && index < weeklyTrend.length
                    ? weeklyTrend[index]
                    : 3.0;
                final height = (value / 5.0) * 80;
                final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayNames[index],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityInsights(JournalProvider journalProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktivite İçgörüleri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightRow('En Verimli Gün', journalProvider.mostProductiveDay),
          const SizedBox(height: 8),
          _buildInsightRow('Favori Aktivite', journalProvider.favoriteActivity),
          const SizedBox(height: 8),
          _buildInsightRow('En Uzun Seri', '${journalProvider.longestStreak} gün'),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              leading: Radio<JournalEntryType?>(
                value: null,
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...JournalEntryType.values.map((type) => ListTile(
              title: Text(type.name),
              leading: Icon(type.icon),
              trailing: Radio<JournalEntryType?>(
                value: type,
                groupValue: _filterType,
                onChanged: (value) {
                  setState(() {
                    _filterType = value;
                  });
                  Navigator.pop(context);
                },
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddJournalEntryDialog(),
    );
  }

  void _showEntryDetail(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.mood.emoji),
            const SizedBox(width: 8),
            Expanded(child: Text(entry.title ?? entry.type.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(entry.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (entry.content != null) ...[
              const SizedBox(height: 12),
              Text(entry.content!),
            ],
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                children: entry.tags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _editEntry(JournalEntry entry) {
    // TODO: Edit dialog'u implement edilecek
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Düzenleme özelliği yakında eklenecek')),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu kaydı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().deleteEntry(entry.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kayıt silindi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    final journalProvider = context.read<JournalProvider>();
    final jsonData = journalProvider.exportToJson();
    
    // TODO: Gerçek export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export özelliği yakında eklenecek')),
    );
  }

  void _showInsightsDialog() {
    final journalProvider = context.read<JournalProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kişisel İçgörüler'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: journalProvider.insights.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      FeatherIcons.info,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(journalProvider.insights[index]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text(
          'Bu işlem tüm günlük kayıtlarınızı kalıcı olarak silecektir. '
          'Bu işlem geri alınamaz. Devam etmek istediğinize emin misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm veriler silindi')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 