import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/main.dart';

class AddEditAdoptionScreen extends StatefulWidget {
  final String? adoptionId; // 有值=编辑模式
  final String? catId;       // 从猫咪详情页直接进入时指定猫咪

  const AddEditAdoptionScreen({super.key, this.adoptionId, this.catId});

  @override
  State<AddEditAdoptionScreen> createState() => _AddEditAdoptionScreenState();
}

class _AddEditAdoptionScreenState extends State<AddEditAdoptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _livingCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  String _selectedCatId = '';
  bool _hasPetExperience = false;
  bool _hasSealedWindows = false;
  bool _acceptsVisit = true;
  String _status = '待审核';
  String _reviewNotes = '';
  List<CatModel> _availableCats = [];
  bool get _isEdit => widget.adoptionId != null;

  @override
  void initState() {
    super.initState();
    _loadCats();
    if (widget.adoptionId != null) {
      _loadExistingData();
    } else if (widget.catId != null) {
      _selectedCatId = widget.catId!;
    }
  }

  void _loadCats() {
    setState(() {
      _availableCats = _db.getAllCats().where((c) => c.status == '健康待领养').toList();
    });
  }

  void _loadExistingData() {
    final a = _db.getAdoptionById(widget.adoptionId!);
    if (a == null) return;
    setState(() {
      _selectedCatId = a.catId;
      _nameCtrl.text = a.applicantName;
      _contactCtrl.text = a.contact;
      _livingCtrl.text = a.livingCondition;
      _experienceCtrl.text = a.experienceDescription ?? '';
      _hasPetExperience = a.hasPetExperience;
      _hasSealedWindows = a.hasSealedWindow;
      _acceptsVisit = a.acceptedVisit;
      _status = a.status;
      _reviewNotes = a.reviewNotes ?? '';
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _livingCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? '编辑领养申请' : '添加领养申请')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCatSelector(),
            const SizedBox(height: 24),
            _buildApplicantInfo(),
            const SizedBox(height: 24),
            _buildLivingCondition(),
            const SizedBox(height: 24),
            _buildChecklist(),
            if (_isEdit) ...[
              const SizedBox(height: 24),
              _buildStatusManagement(),
              const SizedBox(height: 24),
              _buildReviewNotes(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(_isEdit ? '保存修改' : '提交申请', style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildCatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择猫咪 *', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedCatId.isEmpty ? null : _selectedCatId,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '请选择猫咪'),
          items: _availableCats.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.breed})'))).toList(),
          onChanged: (v) => setState(() => _selectedCatId = v!),
          validator: RequiredValidator(errorText: '请选择猫咪'),
        ),
      ],
    );
  }

  Widget _buildApplicantInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('申请人信息', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: '申请人姓名 *', border: OutlineInputBorder()),
          validator: RequiredValidator(errorText: '请输入申请人姓名'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contactCtrl,
          decoration: const InputDecoration(labelText: '联系方式 *', border: OutlineInputBorder(), hintText: '手机号或微信'),
          validator: RequiredValidator(errorText: '请输入联系方式'),
        ),
      ],
    );
  }

  Widget _buildLivingCondition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('居住条件', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          controller: _livingCtrl,
          decoration: const InputDecoration(labelText: '居住情况 *', border: OutlineInputBorder(),
              hintText: '例如：自有住房/租房，合租/独居，是否有独立房间'),
          maxLines: 3,
          validator: RequiredValidator(errorText: '请描述居住条件'),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _hasPetExperience,
          onChanged: (v) => setState(() => _hasPetExperience = v!),
          title: const Text('是否有养宠经验'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_hasPetExperience) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _experienceCtrl,
            decoration: const InputDecoration(labelText: '养宠经验描述', border: OutlineInputBorder(),
                hintText: '曾养过什么宠物，养了多久'),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('重要确认项', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _hasSealedWindows,
          onChanged: (v) => setState(() => _hasSealedWindows = v!),
          title: const Text('窗户已封网/封窗 *'),
          subtitle: const Text('这是必备条件！', style: TextStyle(color: Colors.red)),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: _acceptsVisit,
          onChanged: (v) => setState(() => _acceptsVisit = v!),
          title: const Text('接受定期回访'),
          subtitle: const Text('领养后需要接受回访'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildStatusManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('审核状态', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: '待审核', child: Text('待审核')),
            DropdownMenuItem(value: '初审通过', child: Text('初审通过')),
            DropdownMenuItem(value: '需家访', child: Text('需家访')),
            DropdownMenuItem(value: '审核通过', child: Text('审核通过')),
            DropdownMenuItem(value: '已驳回', child: Text('已驳回')),
            DropdownMenuItem(value: '已领养', child: Text('已领养')),
          ],
          onChanged: (v) => setState(() => _status = v!),
        ),
      ],
    );
  }

  Widget _buildReviewNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('审核备注', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextFormField(
          controller: TextEditingController(text: _reviewNotes),
          decoration: const InputDecoration(labelText: '备注（可选）', border: OutlineInputBorder(),
              hintText: '填写审核意见、家访情况、驳回原因等'),
          maxLines: 4,
          onChanged: (v) => _reviewNotes = v,
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      showError('请完善必填信息');
      return;
    }
    if (!_hasSealedWindows) {
      showError('窗户必须封网！这是硬性条件！');
      return;
    }

    showLoading();
    try {
      final now = DateTime.now();
      final adoption = AdoptionModel(
        id: _isEdit ? widget.adoptionId! : 'adoption_${now.millisecondsSinceEpoch}',
        catId: _selectedCatId,
        applicantName: _nameCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        livingCondition: _livingCtrl.text.trim(),
        hasPetExperience: _hasPetExperience,
        experienceDescription: _hasPetExperience ? _experienceCtrl.text.trim() : null,
        hasSealedWindow: _hasSealedWindows,
        acceptedVisit: _acceptsVisit,
        applyDate: _isEdit ? (_db.getAdoptionById(widget.adoptionId!)?.applyDate ?? now) : now,
        status: _status,
        reviewNotes: _reviewNotes.isEmpty ? null : _reviewNotes,
        adoptionDate: _status == '已领养' ? now : null,
        photos: _isEdit ? (_db.getAdoptionById(widget.adoptionId!)?.photos ?? []) : [],
        visitRecords: _isEdit ? (_db.getAdoptionById(widget.adoptionId!)?.visitRecords ?? []) : [],
        createdAt: _isEdit ? (_db.getAdoptionById(widget.adoptionId!)?.createdAt ?? now) : now,
        updatedAt: now,
      );

      if (_isEdit) {
        await _db.updateAdoption(adoption);
      } else {
        await _db.addAdoption(adoption);
      }

      hideLoading();
      showSuccess(_isEdit ? '更新成功' : '申请已提交');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      hideLoading();
      showError('保存失败: $e');
    }
  }
}
