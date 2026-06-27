import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/main.dart';

class AdoptionDetailScreen extends StatefulWidget {
  final String adoptionId;

  const AdoptionDetailScreen({super.key, required this.adoptionId});

  @override
  State<AdoptionDetailScreen> createState() => _AdoptionDetailScreenState();
}

class _AdoptionDetailScreenState extends State<AdoptionDetailScreen> {
  final _db = DatabaseService();
  AdoptionModel? _adoption;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final a = _db.getAdoptionById(widget.adoptionId);
    if (a != null) setState(() { _adoption = a; _isLoaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _adoption == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final a = _adoption!;

    return Scaffold(
      appBar: AppBar(title: const Text('领养详情')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ApplicantCard(adoption: a),
          const SizedBox(height: 16),
          _CatCard(catId: a.catId),
          const SizedBox(height: 16),
          _StatusCard(adoption: a, onUpdate: _loadData),
          const SizedBox(height: 16),
          if (a.photos.isNotEmpty) ...[
            _PhotoGallery(photos: a.photos),
            const SizedBox(height: 16),
          ],
          if (a.visitRecords.isNotEmpty) ...[
            _VisitRecords(records: a.visitRecords),
            const SizedBox(height: 16),
          ],
          _ReviewNotes(notes: a.reviewNotes),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final AdoptionModel adoption;

  const _ApplicantCard({required this.adoption});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('申请人信息', style: Theme.of(context).textTheme.titleLarge),
                _StatusBadge(adoption.status),
              ],
            ),
            const SizedBox(height: 16),
            Text(adoption.applicantName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(adoption.contact),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text('居住条件', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(adoption.livingCondition),
            const SizedBox(height: 12),
            Row(
              children: [
                _CheckChip('有养宠经验', adoption.hasPetExperience),
                const SizedBox(width: 8),
                _CheckChip('窗户已封', adoption.hasSealedWindow),
                const SizedBox(width: 8),
                _CheckChip('接受回访', adoption.acceptedVisit),
              ],
            ),
            if (adoption.hasPetExperience && adoption.experienceDescription != null) ...[
              const SizedBox(height: 12),
              Text('养宠经验', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(adoption.experienceDescription!),
            ],
            const SizedBox(height: 12),
            Text('申请日期：${DateFormat('yyyy-MM-dd').format(adoption.applyDate)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CatCard extends StatelessWidget {
  final String catId;

  const _CatCard({required this.catId});

  @override
  Widget build(BuildContext context) {
    final cat = DatabaseService().getCatById(catId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('申请领养的猫咪', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (cat != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: cat.photos.isNotEmpty
                        ? (cat.photos.first.startsWith('http')
                            ? NetworkImage(cat.photos.first) as ImageProvider
                            : FileImage(File(cat.photos.first)))
                        : null,
                    child: cat.photos.isEmpty ? const Icon(Icons.pets, size: 30) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${cat.age} • ${cat.gender} • ${cat.breed}'),
                        const SizedBox(height: 4),
                        _StatusBadge(cat.status),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Text('猫咪信息已删除'),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AdoptionModel adoption;
  final VoidCallback onUpdate;

  const _StatusCard({required this.adoption, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('审核进度', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () => _showUpdateDialog(context),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('更新状态'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatusTimeline(currentStatus: adoption.status),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    String newStatus = adoption.status;
    final noteCtrl = TextEditingController(text: adoption.reviewNotes ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('更新审核状态'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: newStatus,
                decoration: const InputDecoration(labelText: '新状态', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '待审核', child: Text('待审核')),
                  DropdownMenuItem(value: '初审通过', child: Text('初审通过')),
                  DropdownMenuItem(value: '需家访', child: Text('需家访')),
                  DropdownMenuItem(value: '审核通过', child: Text('审核通过')),
                  DropdownMenuItem(value: '已驳回', child: Text('已驳回')),
                  DropdownMenuItem(value: '已领养', child: Text('已领养')),
                ],
                onChanged: (v) => setState(() => newStatus = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: '备注（可选）', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final updated = adoption.copyWith(
                status: newStatus,
                reviewNotes: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                adoptionDate: newStatus == '已领养' ? DateTime.now() : null,
                updatedAt: DateTime.now(),
              );
              await DatabaseService().updateAdoption(updated);
              Navigator.pop(ctx);
              onUpdate();
              showSuccess('状态已更新');
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String currentStatus;

  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = ['待审核', '初审通过', '需家访', '审核通过', '已领养'];
    final idx = steps.indexOf(currentStatus);

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        final done = i <= idx;
        final current = i == idx;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? Colors.green : Colors.grey, size: 20),
            if (i < steps.length - 1)
              Container(width: 2, height: 30, color: i < idx ? Colors.green : Colors.grey[300]),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(s, style: TextStyle(
                  fontWeight: current ? FontWeight.bold : FontWeight.normal,
                  color: current ? Theme.of(context).primaryColor : null,
                )),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  final List<String> photos;

  const _PhotoGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('领养后照片 (${photos.length})', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = photos[i];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: p.startsWith('http') ? NetworkImage(p) as ImageProvider : FileImage(File(p)),
                  width: 120, height: 120, fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VisitRecords extends StatelessWidget {
  final List<String> records;

  const _VisitRecords({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('回访记录 (${records.length})', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...records.map((r) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(leading: const Icon(Icons.event_note), title: Text(r)),
        )),
      ],
    );
  }
}

class _ReviewNotes extends StatelessWidget {
  final String? notes;

  const _ReviewNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('审核备注', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(notes ?? '暂无审核备注'))),
      ],
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

class _CheckChip extends StatelessWidget {
  final String label;
  final bool value;

  const _CheckChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(value ? Icons.check_circle : Icons.cancel, size: 16, color: value ? Colors.green : Colors.red),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
