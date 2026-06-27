import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'cat_detail_screen.dart';
import 'add_edit_cat_screen.dart';

class CatListScreen extends ConsumerStatefulWidget {
  const CatListScreen({super.key});

  @override
  ConsumerState<CatListScreen> createState() => _CatListScreenState();
}

class _CatListScreenState extends ConsumerState<CatListScreen> {
  String _selectedStatus = '全部';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _statusFilters = [
    '全部',
    '待救助',
    '隔离中',
    '健康待领养',
    '已送养',
    '回喵星',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CatModel> _filterCats(List<CatModel> cats) {
    return cats.where((cat) {
      // 状态筛选
      if (_selectedStatus != '全部' && cat.status != _selectedStatus) {
        return false;
      }
      
      // 搜索筛选
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return cat.name.toLowerCase().contains(query) ||
            cat.breed.toLowerCase().contains(query) ||
            cat.personalityTags.any((tag) => tag.toLowerCase().contains(query));
      }
      
      return true;
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final allCats = databaseService.getAllCats();
    final filteredCats = _filterCats(allCats);

    return Scaffold(
      appBar: AppBar(
        title: const Text('猫咪列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索猫咪名字、品种、性格...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // 状态筛选标签
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = status == _selectedStatus;
                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 猫咪列表
          Expanded(
            child: filteredCats.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredCats.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCats[index];
                      return _CatCard(cat: cat);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditCatScreen(),
            ),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无猫咪',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加第一只猫咪吧！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '筛选条件',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // TODO: 添加更多筛选条件（年龄、性别、品种等）
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('按更新时间排序'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现排序
                },
              ),
              ListTile(
                leading: const Icon(Icons.male),
                title: const Text('只看男生'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现性别筛选
                },
              ),
              ListTile(
                leading: const Icon(Icons.female),
                title: const Text('只看女生'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 实现性别筛选
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatCard extends StatelessWidget {
  final CatModel cat;

  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final medicalRecords = databaseService.getMedicalRecordsByCatId(cat.id);
    final hasUpcomingMedical = medicalRecords.any((record) => record.isDueSoon);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatDetailScreen(catId: cat.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 猫咪照片
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: cat.photos.isNotEmpty
                        ? NetworkImage(cat.photos.first)
                        : null,
                    child: cat.photos.isEmpty
                        ? const Icon(Icons.pets, size: 40)
                        : null,
                  ),
                  if (hasUpcomingMedical)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // 猫咪信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(cat.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cat.age} • ${cat.gender} • ${cat.breed}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cat.weight}kg',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.event_note,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${medicalRecords.length}条记录',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (cat.personalityTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: cat.personalityTags.take(3).map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case '待救助':
        color = Colors.orange;
        break;
      case '隔离中':
        color = Colors.blue;
        break;
      case '健康待领养':
        color = Colors.green;
        break;
      case '已送养':
        color = Colors.purple;
        break;
      case '回喵星':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
