import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/main.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  final _db = DatabaseService();
  List<AdoptionModel> _applications = [];
  String _selectedStatus = '全部';

  final _statusFilters = [
    '全部',
    '待审核',
    '初审通过',
    '需家访',
    '审核通过',
    '已驳回',
    '已领养',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    setState(() {
      _applications = _selectedStatus == '全部'
          ? _db.getAllAdoptions()
          : _db.getAdoptionsByStatus(_selectedStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('领养管理'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadApplications),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = _statusFilters[index];
                return FilterChip(
                  label: Text(s),
                  selected: s == _selectedStatus,
                  onSelected: (sel) {
                    setState(() => _selectedStatus = s);
                    _loadApplications();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _applications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _applications.length,
                    itemBuilder: (_, i) => _AdoptionCard(
                      app: _applications[i],
                      onRefresh: _loadApplications,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-adoption')
            .then((_) => _loadApplications()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _selectedStatus == '全部' ? '暂无领养申请' : '暂无"$_selectedStatus"的申请',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('点击右下角按钮添加申请', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _AdoptionCard extends StatelessWidget {
  final AdoptionModel app;
  final VoidCallback onRefresh;

  const _AdoptionCard({required this.app, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final cat = DatabaseService().getCatById(app.catId);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/adoption-detail', arguments: app.id)
            .then((_) => onRefresh()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: cat?.photos.isNotEmpty == true
                    ? (cat!.photos.first.startsWith('http')
                        ? NetworkImage(cat.photos.first) as ImageProvider
                        : FileImage(File(cat.photos.first)))
                    : null,
                child: cat?.photos.isEmpty != false ? const Icon(Icons.pets, size: 30) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(app.applicantName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                        ),
                        _StatusBadge(app.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('猫咪：${cat?.name ?? "未知"}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(app.contact, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(width: 16),
                        Icon(Icons.event, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(DateFormat('MM-dd').format(app.applyDate),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    if (app.reviewNotes != null) ...[
                      const SizedBox(height: 4),
                      Text('备注：${app.reviewNotes}',
                          style: const TextStyle(color: Colors.orange, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      '待审核' => Colors.orange,
      '初审通过' => Colors.blue,
      '需家访' => Colors.purple,
      '审核通过' => Colors.green,
      '已驳回' => Colors.red,
      '已领养' => Colors.teal,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
