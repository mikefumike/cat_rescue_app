import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/services/auth_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'package:cat_rescue_app/screens/cat_list_screen.dart';
import 'package:cat_rescue_app/screens/medical_calendar_screen.dart';
import 'package:cat_rescue_app/screens/adoption_screen.dart';
import 'package:cat_rescue_app/screens/login_screen.dart';
import 'package:cat_rescue_app/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardTab(),
      const CatListScreen(),
      const MedicalCalendarScreen(),
      const AdoptionScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: '猫咪',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '医疗',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '领养',
          ),
        ],
      ),
    );
  }
}

/// 仪表盘Tab
class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final databaseService = DatabaseService();
    final cats = databaseService.getAllCats();
    final upcomingRecords = databaseService.getUpcomingMedicalRecords();
    final overdueRecords = databaseService.getOverdueMedicalRecords();
    final statusCounts = databaseService.getCatStatusCounts();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐱', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            const Text('光影爱宠'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ConsumerWidget无法直接setState，留空即可
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 欢迎卡片
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF8C42).withValues(alpha: 0.1),
                      const Color(0xFFFF8C42).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🏠',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '欢迎来到光影爱宠',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFF8C42),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '当前共有 ${cats.length} 只毛孩子',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 统计卡片
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '待救助',
                    count: statusCounts['待救助'] ?? 0,
                    icon: Icons.healing,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '待领养',
                    count: statusCounts['健康待领养'] ?? 0,
                    icon: Icons.favorite,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: '已送养',
                    count: statusCounts['已送养'] ?? 0,
                    icon: Icons.home,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: '医疗提醒',
                    count: upcomingRecords.length + overdueRecords.length,
                    icon: Icons.notifications,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 医疗提醒
            if (upcomingRecords.isNotEmpty || overdueRecords.isNotEmpty) ...[
              Row(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text('医疗提醒', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              if (overdueRecords.isNotEmpty) ...[
                Text(
                  '已过期 (${overdueRecords.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ...overdueRecords.map((record) => _MedicalAlertCard(record: record, isOverdue: true)),
                const SizedBox(height: 12),
              ],
              if (upcomingRecords.isNotEmpty) ...[
                Text(
                  '即将到期 (${upcomingRecords.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange),
                ),
                const SizedBox(height: 8),
                ...upcomingRecords.map((record) => _MedicalAlertCard(record: record, isOverdue: false)),
              ],
              const SizedBox(height: 28),
            ],

            // 最近添加的猫咪
            Row(
              children: [
                const Text('🐾', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('最近添加的猫咪', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            if (cats.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Text('🐱', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        '还没有猫咪，点击右下角按钮添加',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...cats.take(5).map((cat) => _CatSummaryCard(cat: cat)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-cat');
        },
        backgroundColor: const Color(0xFFFF8C42),
        icon: const Icon(Icons.add),
        label: const Text('添加猫咪'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MedicalAlertCard extends StatelessWidget {
  final MedicalRecordModel record;
  final bool isOverdue;

  const _MedicalAlertCard({required this.record, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final cat = DatabaseService().getCatById(record.catId);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isOverdue ? Icons.warning : Icons.event,
          color: isOverdue ? Colors.red : Colors.orange,
        ),
        title: Text(record.title),
        subtitle: Text('${cat?.name ?? "未知猫咪"} - ${record.type}'),
        trailing: Text(
          isOverdue ? '已过期' : '${record.nextDueDate?.difference(DateTime.now()).inDays}天后',
          style: TextStyle(
            color: isOverdue ? Colors.red : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // TODO: 查看详情
        },
      ),
    );
  }
}

class _CatSummaryCard extends StatelessWidget {
  final CatModel cat;

  const _CatSummaryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: cat.photos.isNotEmpty
              ? null
              : const Icon(Icons.pets, color: Colors.orange),
        ),
        title: Text(cat.name),
        subtitle: Text('${cat.age} • ${cat.gender} • ${cat.status}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(context, '/cat-detail', arguments: cat.id);
        },
      ),
    );
  }
}
