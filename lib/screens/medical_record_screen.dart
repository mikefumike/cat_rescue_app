import 'package:cat_rescue_app/main.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'add_edit_medical_record_screen.dart';

class MedicalRecordScreen extends StatefulWidget {
  final String? catId; // 如果指定，则只显示该猫咪的医疗记录

  const MedicalRecordScreen({super.key, this.catId});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _databaseService = DatabaseService();
  List<MedicalRecordModel> _records = [];
  Map<DateTime, List<MedicalRecordModel>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    List<MedicalRecordModel> records;
    if (widget.catId != null) {
      records = _databaseService.getMedicalRecordsByCatId(widget.catId!);
    } else {
      records = _databaseService.getAllMedicalRecords();
    }

    // 按日期分组
    final events = <DateTime, List<MedicalRecordModel>>{};
    for (var record in records) {
      final date = DateTime(
        record.recordDate.year,
        record.recordDate.month,
        record.recordDate.day,
      );
      events.putIfAbsent(date, () => []).add(record);
      
      // 如果有下次预约日期，也添加到日历
      if (record.nextDueDate != null) {
        final nextDate = DateTime(
          record.nextDueDate!.year,
          record.nextDueDate!.month,
          record.nextDueDate!.day,
        );
        events.putIfAbsent(nextDate, () => []).add(record);
      }
    }

    setState(() {
      _records = records;
      _events = events;
      _selectedDay = _focusedDay;
    });
  }

  List<MedicalRecordModel> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catId != null ? '医疗记录' : '医疗日历'),
        actions: [
          IconButton(
            icon: Icon(widget.catId != null ? Icons.calendar_today : Icons.list),
            onPressed: () {
              // TODO: 切换视图
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildRecordList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditMedicalRecordScreen(
                catId: widget.catId,
              ),
            ),
          );
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildRecordList() {
    final selectedRecords = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : _records;

    if (selectedRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null ? '这一天没有医疗记录' : '暂无医疗记录',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    // 按日期分组显示
    final grouped = <String, List<MedicalRecordModel>>{};
    for (var record in selectedRecords) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.recordDate);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...entry.value.map((record) {
              final cat = _databaseService.getCatById(record.catId);
              return _MedicalRecordCard(
                record: record,
                catName: cat?.name ?? '未知猫咪',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditMedicalRecordScreen(
                        recordId: record.id,
                        catId: record.catId,
                      ),
                    ),
                  );
                  _loadRecords();
                },
                onDelete: () => _confirmDelete(record),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _confirmDelete(MedicalRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除「${record.title}」吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _databaseService.deleteMedicalRecord(record.id);
      _loadRecords();
      showSuccess('已删除');
    }
  }
}

class _MedicalRecordCard extends StatelessWidget {
  final MedicalRecordModel record;
  final String catName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MedicalRecordCard({
    required this.record,
    required this.catName,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = record.isOverdue;
    final isDueSoon = record.isDueSoon;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getMedicalTypeIcon(record.type),
        title: Row(
          children: [
            Expanded(child: Text(record.title)),
            if (isOverdue)
              const Icon(Icons.warning, color: Colors.red, size: 16)
            else if (isDueSoon)
              const Icon(Icons.event, color: Colors.orange, size: 16),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$catName • ${record.type}'),
            if (record.nextDueDate != null)
              Text(
                '下次: ${DateFormat('MM-dd').format(record.nextDueDate!)}',
                style: TextStyle(
                  color: isOverdue
                      ? Colors.red
                      : isDueSoon
                          ? Colors.orange
                          : null,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _getMedicalTypeIcon(String type) {
    switch (type) {
      case '疫苗':
        return const Icon(Icons.vaccines, color: Colors.blue);
      case '驱虫':
        return const Icon(Icons.bug_report, color: Colors.green);
      case '绝育':
        return const Icon(Icons.healing, color: Colors.orange);
      case '疾病治疗':
        return const Icon(Icons.medical_services, color: Colors.red);
      default:
        return const Icon(Icons.medical_information);
    }
  }
}

