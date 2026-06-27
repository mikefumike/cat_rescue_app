import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'add_edit_medical_record_screen.dart';

class MedicalCalendarScreen extends ConsumerStatefulWidget {
  const MedicalCalendarScreen({super.key});

  @override
  ConsumerState<MedicalCalendarScreen> createState() =>
      _MedicalCalendarScreenState();
}

class _MedicalCalendarScreenState
    extends ConsumerState<MedicalCalendarScreen> {
  final _databaseService = DatabaseService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MedicalRecordModel>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMedicalRecords();
  }

  void _loadMedicalRecords() {
    final records = _databaseService.getAllMedicalRecords();
    _events = {};
    for (var record in records) {
      final date = DateTime(
        record.recordDate.year,
        record.recordDate.month,
        record.recordDate.day,
      );
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]!.add(record);
    }
    setState(() {});
  }

  List<MedicalRecordModel> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📅', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('医疗日历'),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  locale: 'zh_CN',  // 设置为中文
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 1,
                    markerSize: 8,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
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
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditMedicalRecordScreen(),
            ),
          );
          _loadMedicalRecords();
        },
        backgroundColor: const Color(0xFFFF8C42),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay ?? DateTime.now());
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏥', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('当天无医疗记录'),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              _getIconForType(event.type),
              color: _getColorForType(event.type),
            ),
            title: Text(event.title),
            subtitle: Text(
              '${event.type} · ${DateFormat('HH:mm').format(event.recordDate)}',
            ),
            trailing: event.isOverdue
                ? const Icon(Icons.warning, color: Colors.red)
                : event.isDueSoon
                    ? const Icon(Icons.notification_important,
                        color: Colors.orange)
                    : null,
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case '疫苗':
        return Icons.vaccines;
      case '驱虫':
        return Icons.bug_report;
      case '绝育':
        return Icons.cut;
      case '疾病治疗':
        return Icons.medical_services;
      default:
        return Icons.event;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case '疫苗':
        return Colors.blue;
      case '驱虫':
        return Colors.green;
      case '绝育':
        return Colors.purple;
      case '疾病治疗':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
