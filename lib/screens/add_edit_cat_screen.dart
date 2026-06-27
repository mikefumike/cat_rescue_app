import 'package:cat_rescue_app/main.dart';
import 'package:flutter/material.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';

class AddEditCatScreen extends StatefulWidget {
  final String? catId; // 如果是编辑模式，传入猫咪ID

  const AddEditCatScreen({super.key, this.catId});

  @override
  State<AddEditCatScreen> createState() => _AddEditCatScreenState();
}

class _AddEditCatScreenState extends State<AddEditCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  final _imagePicker = ImagePicker();

  // 表单控制器
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 表单数据
  DateTime? _birthDate;
  String _gender = '未知';
  String _status = '待救助';
  DateTime _rescueDate = DateTime.now();
  List<String> _personalityTags = [];
  List<String> _photos = [];

  bool get _isEditMode => widget.catId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadCatData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCatData() {
    final cat = _databaseService.getCatById(widget.catId!);
    if (cat != null) {
      _nameController.text = cat.name;
      _breedController.text = cat.breed;
      _weightController.text = cat.weight.toString();
      _descriptionController.text = cat.description ?? '';
      _birthDate = cat.birthDate;
      _gender = cat.gender;
      _status = cat.status;
      _rescueDate = cat.rescueDate;
      _personalityTags = List.from(cat.personalityTags);
      _photos = List.from(cat.photos);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑猫咪' : '添加猫咪'),
        actions: [
          TextButton(
            onPressed: _saveCat,
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
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildPersonalityTagsSection(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
            const SizedBox(height: 100), // 底部间距
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '照片',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1, // +1 是添加按钮
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
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
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
            width: 120,
            height: 120,
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
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '猫咪名字 *',
            border: OutlineInputBorder(),
          ),
          validator: RequiredValidator(errorText: '请输入猫咪名字'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: '品种 *',
                  border: OutlineInputBorder(),
                ),
                validator: RequiredValidator(errorText: '请输入品种'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: '体重 (kg) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: MultiValidator([
                  RequiredValidator(errorText: '请输入体重'),
                  NumberValidator(errorText: '请输入有效数字'),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: '性别',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '未知', child: Text('未知')),
                  DropdownMenuItem(value: '男生', child: Text('男生♂')),
                  DropdownMenuItem(value: '女生', child: Text('女生♀')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _pickBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '出生日期',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _birthDate == null
                        ? '请选择'
                        : DateFormat('yyyy-MM-dd').format(_birthDate!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickRescueDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '救助日期 *',
              border: OutlineInputBorder(),
            ),
            child: Text(
              DateFormat('yyyy-MM-dd').format(_rescueDate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性格标签',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._personalityTags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _personalityTags.remove(tag);
                  });
                },
              );
            }),
            ActionChip(
              label: const Text('+ 添加标签'),
              onPressed: _addPersonalityTag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '状态',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '待救助', child: Text('待救助')),
            DropdownMenuItem(value: '隔离中', child: Text('隔离中')),
            DropdownMenuItem(value: '健康待领养', child: Text('健康待领养')),
            DropdownMenuItem(value: '已送养', child: Text('已送养')),
            DropdownMenuItem(value: '回喵星', child: Text('回喵星')),
          ],
          onChanged: (value) {
            setState(() {
              _status = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '更多描述',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: '描述猫咪的性格、习惯、特殊需求等...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          maxLength: 500,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // TODO: 上传图片到服务器
      // 这里先假设图片已上传，获得URL
      final imageUrl = 'https://example.com/photos/${image.name}'; // 替换为实际上传逻辑
      
      setState(() {
        _photos.add(imageUrl);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  Future<void> _pickRescueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _rescueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _rescueDate = date;
      });
    }
  }

  Future<void> _addPersonalityTag() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加性格标签'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '例如：粘人、高冷、活泼',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('添加'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _personalityTags.add(result);
      });
    }
  }

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate()) {
      showError('请完善必填信息');
      return;
    }

    showLoading();
    try {
      final now = DateTime.now();
      final cat = CatModel(
        id: _isEditMode ? widget.catId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        birthDate: _birthDate,
        gender: _gender,
        breed: _breedController.text.trim(),
        weight: double.parse(_weightController.text),
        personalityTags: _personalityTags,
        photos: _photos,
        status: _status,
        rescueDate: _rescueDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        medicalRecords: _isEditMode
            ? _databaseService.getCatById(widget.catId!)!.medicalRecords
            : [],
        createdAt: _isEditMode
            ? _databaseService.getCatById(widget.catId!)!.createdAt
            : now,
        updatedAt: now,
      );

      if (_isEditMode) {
        await _databaseService.updateCat(cat);
      } else {
        await _databaseService.addCat(cat);
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

class NumberValidator extends TextFieldValidator {
  NumberValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }
}


