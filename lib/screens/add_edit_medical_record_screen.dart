import 'package:cat_rescue_app/main.dart';
import 'package:flutter/material.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';

class AddEditMedicalRecordScreen extends StatefulWidget {
  final String? recordId; // 编辑模式时传入
  final String? catId; // 从猫咪详情页进入时传入

  const AddEditMedicalRecordScreen({
    super.key,
    this.recordId,
    this.catId,
  });

  @override
  State<AddEditMedicalRecordScreen> createState() =>
      _AddEditMedicalRecordScreenState();
}

class _AddEditMedicalRecordScreenState extends State<AddEditMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  final _imagePicker = ImagePicker();

  // 表单控制器
  final _titleController = TextEditingController();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  // 表单数据
  String _selectedCatId = '';
  String _type = '疫苗';
  DateTime _recordDate = DateTime.now();
  DateTime? _nextDueDate;
  List<String> _photos = [];

  // 猫咪列表
  List<CatModel> _cats = [];

  bool get _isEditMode => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    _loadCats();
    if (_isEditMode) {
      _loadRecordData();
    } else if (widget.catId != null) {
      _selectedCatId = widget.catId!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _medicationController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadCats() {
    setState(() {
      _cats = _databaseService.getAllCats();
      if (_selectedCatId.isEmpty && _cats.isNotEmpty) {
        _selectedCatId = _cats.first.id;
      }
    });
  }

  void _loadRecordData() {
    final record = _databaseService.getAllMedicalRecords().firstWhere(
          (r) => r.id == widget.recordId,
          orElse: () => MedicalRecordModel(
            id: '',
            catId: '',
            type: '',
            title: '',
            recordDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

    if (record.id.isNotEmpty) {
      _titleController.text = record.title;
      _medicationController.text = record.medication ?? '';
      _dosageController.text = record.dosage ?? '';
      _notesController.text = record.notes ?? '';
      _selectedCatId = record.catId;
      _type = record.type;
      _recordDate = record.recordDate;
      _nextDueDate = record.nextDueDate;
      _photos = List.from(record.photos);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑医疗记录' : '添加医疗记录'),
        actions: [
          TextButton(
            onPressed: _saveRecord,
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCatSelector(),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 100), // 底部间距
          ],
        ),
      ),
    );
  }

  Widget _buildCatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择猫咪 *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedCatId.isNotEmpty ? _selectedCatId : null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '请选择猫咪',
          ),
          items: _cats.map((cat) {
            return DropdownMenuItem(
              value: cat.id,
              child: Text('${cat.name} (${cat.breed})'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCatId = value!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请选择猫咪';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final types = ['疫苗', '驱虫', '绝育', '疾病治疗'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '记录类型 *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = _type == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _type = type;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基本信息',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '标题 *',
            border: OutlineInputBorder(),
            hintText: '例如：妙三多第一针、体内驱虫',
          ),
          validator: RequiredValidator(errorText: '请输入标题'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: '药品/疫苗名称',
                  border: OutlineInputBorder(),
                  hintText: '例如：妙三多、海乐妙',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: '剂量',
                  border: OutlineInputBorder(),
                  hintText: '例如：1ml、半片',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '日期设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickRecordDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '记录日期 *',
              border: OutlineInputBorder(),
            ),
            child: Text(
              DateFormat('yyyy-MM-dd').format(_recordDate),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickNextDueDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '下次预约日期（可选）',
              border: const OutlineInputBorder(),
              suffixIcon: _nextDueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _nextDueDate = null;
                        });
                      },
                    )
                  : null,
            ),
            child: Text(
              _nextDueDate == null
                  ? '请选择（可选）'
                  : DateFormat('yyyy-MM-dd').format(_nextDueDate!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '相关照片',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return _buildAddPhotoButton();
              }
              return _buildPhotoThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickMedicalPhoto,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
      ),
    );
  }

  Widget _buildPhotoThumbnail(int index) {
    final photo = _photos[index];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            photo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _photos.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备注',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: '记录详细情况、注意事项等...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          maxLength: 1000,
        ),
      ],
    );
  }

  Future<void> _pickRecordDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _recordDate = date;
      });
    }
  }

  Future<void> _pickNextDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _nextDueDate = date;
      });
    }
  }

  Future<void> _pickMedicalPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      // TODO: 上传图片到服务器
      final imageUrl = 'https://example.com/medical/${image.name}'; // 替换为实际上传逻辑
      
      setState(() {
        _photos.add(imageUrl);
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      showError('请完善必填信息');
      return;
    }

    if (_selectedCatId.isEmpty) {
      showError('请选择猫咪');
      return;
    }

    showLoading();
    try {
      final now = DateTime.now();
      final record = MedicalRecordModel(
        id: _isEditMode ? widget.recordId! : now.millisecondsSinceEpoch.toString(),
        catId: _selectedCatId,
        type: _type,
        title: _titleController.text.trim(),
        recordDate: _recordDate,
        nextDueDate: _nextDueDate,
        medication: _medicationController.text.trim().isEmpty
            ? null
            : _medicationController.text.trim(),
        dosage: _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photos: _photos,
        createdAt: _isEditMode
            ? _databaseService
                .getAllMedicalRecords()
                .firstWhere((r) => r.id == widget.recordId)
                .createdAt
            : now,
      );

      if (_isEditMode) {
        await _databaseService.updateMedicalRecord(record);
      } else {
        await _databaseService.addMedicalRecord(record);
      }

      showSuccess(_isEditMode ? '更新成功' : '添加成功');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      showError('保存失败: $e');
    }
  }
}


