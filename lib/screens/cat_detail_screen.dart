import 'package:cat_rescue_app/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/services/export_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'package:cat_rescue_app/models/growth_photo_model.dart';
import 'add_edit_cat_screen.dart';
import 'medical_record_screen.dart';

class CatDetailScreen extends StatefulWidget {
  final String catId;

  const CatDetailScreen({super.key, required this.catId});

  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  late CatModel _cat;
  List<MedicalRecordModel> _medicalRecords = [];
  final _databaseService = DatabaseService();
  final _imagePicker = ImagePicker();
  String _imagesDir = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initImagesDir();
    _loadCatData();
  }

  Future<void> _initImagesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/cat_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    _imagesDir = imagesDir.path;
  }

  void _loadCatData() {
    final cat = _databaseService.getCatById(widget.catId);
    if (cat != null) {
      setState(() {
        _cat = cat;
        _medicalRecords = _databaseService.getMedicalRecordsByCatId(cat.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 24),
                  _buildPersonalityTags(),
                  const SizedBox(height: 24),
                  _buildStatusManagement(),
                  const SizedBox(height: 24),
                  _buildMedicalRecords(),
                  const SizedBox(height: 24),
                  _buildGrowthPhotos(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCatScreen(catId: widget.catId),
            ),
          );
          _loadCatData();
        },
        icon: const Icon(Icons.edit),
        label: const Text('编辑'),
      ),
    );
  }

  // ==================== 成长照片时间线 ====================

  Widget _buildGrowthPhotos() {
    final photos = _cat.growthPhotos;
    final sortedPhotos = List<GrowthPhotoModel>.from(photos)
      ..sort((a, b) => b.dateTaken.compareTo(a.dateTaken));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🐾 成长记录 (${sortedPhotos.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sortedPhotos.isNotEmpty)
                  IconButton(
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload_outlined, size: 20),
                    tooltip: '全部导出',
                    onPressed: _isExporting ? null : _exportAllGrowthRecords,
                  ),
                TextButton.icon(
                  onPressed: _showAddGrowthPhotoDialog,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('记录成长'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sortedPhotos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '还没有成长记录',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击「记录成长」拍照/录像记录猫咪的变化',
                      style: TextStyle(
                          color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...sortedPhotos.asMap().entries.map((entry) {
            final index = entry.key;
            final gp = entry.value;
            final isLast = index == sortedPhotos.length - 1;
            return _buildGrowthPhotoTimelineItem(gp, isLast);
          }),
      ],
    );
  }

  Widget _buildGrowthPhotoTimelineItem(GrowthPhotoModel gp, bool isLast) {
    final dateStr = DateFormat('MM月dd日').format(gp.dateTaken);
    final timeStr = DateFormat('HH:mm').format(gp.dateTaken);
    final dir = _imagesDir;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(timeStr,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 4),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _viewGrowthPhotoFullScreen(gp),
              onLongPress: () => _deleteGrowthPhoto(gp),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: _buildGrowthPhotoImage(dir, gp),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 媒体类型标签
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: gp.isVideo
                                        ? Colors.purple.withValues(alpha: 0.1)
                                        : Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gp.mediaEmoji + ' ' + gp.mediaLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: gp.isVideo
                                          ? Colors.purple
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.share_outlined,
                                    size: 14, color: Colors.grey[400]),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (gp.note != null && gp.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.notes,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        gp.note!,
                                        style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (gp.weight != null)
                              Row(
                                children: [
                                  const Icon(Icons.monitor_weight,
                                      size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${gp.weight!.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(Icons.delete_outline,
                                  size: 14, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthPhotoImage(String dir, GrowthPhotoModel gp) {
    final file = File('$dir/${gp.photoFileName}');
    if (!file.existsSync()) {
      return _buildImagePlaceholder();
    }

    if (gp.isVideo) {
      return _buildVideoThumbnail(file);
    }

    return Image.file(
      file,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
    );
  }

  Widget _buildVideoThumbnail(File file) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(
          file,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: Colors.grey[900],
            child: const Center(
              child: Text('🎬', style: TextStyle(fontSize: 48)),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.black26,
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, size: 32, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
    );
  }

  /// 弹出添加成长记录对话框（支持照片+视频）
  Future<void> _showAddGrowthPhotoDialog() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('记录成长瞬间',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('拍照'),
              subtitle: const Text('拍摄一张新照片'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('从相册选照片'),
              subtitle: const Text('选择已有照片'),
              onTap: () => Navigator.pop(context, 'photo'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.purple),
              title: const Text('拍摄视频'),
              subtitle: const Text('录制一段新视频'),
              onTap: () => Navigator.pop(context, 'record_video'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.purple),
              title: const Text('从相册选视频'),
              subtitle: const Text('选择已有视频'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    XFile? media;

    switch (source) {
      case 'camera':
        media = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        break;
      case 'photo':
        media = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        break;
      case 'record_video':
        media = await _imagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(seconds: 60),
        );
        break;
      case 'video':
        media = await _imagePicker.pickVideo(
          source: ImageSource.gallery,
        );
        break;
    }

    if (media == null || !mounted) return;

    final isVideo = source == 'record_video' || source == 'video';
    await _showGrowthPhotoForm(media, isVideo: isVideo);
  }

  Future<void> _showGrowthPhotoForm(XFile media, {bool isVideo = false}) async {
    final dateController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final noteController = TextEditingController();
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isVideo ? Icons.videocam : Icons.photo_camera,
                color: Colors.orange),
            const SizedBox(width: 8),
            Text(isVideo ? '记录成长视频' : '记录成长瞬间'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                        ? _VideoPreviewWidget(filePath: media.path)
                        : Image.file(
                            File(media.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: '拍摄日期',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: _cat.rescueDate,
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                        locale: const Locale('zh', 'CN'),
                      );
                      if (date != null) {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    },
                    validator: (v) =>
                        v == null || v.isEmpty ? '请选择日期' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: '备注（可选）',
                      hintText: '如：体重又增加了、打完疫苗啦...',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: '体重（可选）',
                      hintText: '如：2.5',
                      prefixIcon: Icon(Icons.monitor_weight),
                      suffixText: 'kg',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, {
                  'dateStr': dateController.text,
                  'note': noteController.text,
                  'weightStr': weightController.text,
                });
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    // 保存媒体文件到本地
    final dateStr = result['dateStr'] as String;
    final note = result['note'] as String;
    final weightStr = result['weightStr'] as String;

    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/cat_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    _imagesDir = imagesDir.path;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = media.name.split('.').last.toLowerCase();
    final prefix = isVideo ? 'growth_video' : 'growth';
    final fileName = '${prefix}_$timestamp.$ext';
    final destFile = File('${imagesDir.path}/$fileName');
    await File(media.path).copy(destFile.path);

    // 创建成长记录
    final gp = GrowthPhotoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      photoFileName: fileName,
      dateTaken: DateFormat('yyyy-MM-dd').parse(dateStr),
      note: note.isEmpty ? null : note,
      weight: weightStr.isEmpty ? null : double.tryParse(weightStr),
      createdAt: DateTime.now(),
      isVideo: isVideo,
    );

    final updatedPhotos = List<GrowthPhotoModel>.from(_cat.growthPhotos)
      ..add(gp);
    _cat = _cat.copyWith(
      growthPhotos: updatedPhotos,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateCat(_cat);
    _loadCatData();

    if (mounted) {
      showSuccess('🎉 成长记录已保存');
    }
  }

  /// 导出单条成长记录
  Future<void> _exportSingleGrowth(GrowthPhotoModel gp) async {
    try {
      final file = File('$_imagesDir/${gp.photoFileName}');
      if (!await file.exists()) {
        if (mounted) showError('文件不存在，无法导出');
        return;
      }

      final dateStr = DateFormat('yyyyMMdd').format(gp.dateTaken);
      final exportFileName =
          '${gp.photoFileName.split('.').first}_$dateStr.${gp.photoFileName.split('.').last}';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: gp.isVideo ? 'video/mp4' : 'image/jpeg')],
        text: '📸 ${_cat.name} 的成长记录 - ${gp.note ?? "无备注"}',
      );
    } catch (e) {
      if (mounted) showError('导出失败: $e');
    }
  }

  /// 导出全部成长记录
  Future<void> _exportAllGrowthRecords() async {
    setState(() => _isExporting = true);
    try {
      final photos = _cat.growthPhotos;
      if (photos.isEmpty) {
        if (mounted) showInfo('暂无成长记录可导出');
        return;
      }

      final exportService = ExportService();
      final result = await exportService.exportGrowthRecords(_cat);

      if (result.success && result.filePath != null) {
        if (mounted) {
          showSuccess('✅ ${result.message}');
          await exportService.openFile(result.filePath!);
        }
      } else {
        if (mounted) showError(result.message);
      }
    } catch (e) {
      if (mounted) showError('导出失败: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// 查看成长记录全屏
  void _viewGrowthPhotoFullScreen(GrowthPhotoModel gp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _GrowthPhotoViewer(
          gp: gp,
          imagesDir: _imagesDir,
          catName: _cat.name,
          onExport: () => _exportSingleGrowth(gp),
        ),
      ),
    );
  }

  /// 删除成长记录
  Future<void> _deleteGrowthPhoto(GrowthPhotoModel gp) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除成长记录'),
        content: Text('确定要删除这条${gp.mediaLabel}记录吗？'),
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
      ),
    );

    if (confirmed != true) return;

    // 删除本地文件
    try {
      final file = File('$_imagesDir/${gp.photoFileName}');
      if (await file.exists()) await file.delete();
    } catch (_) {}

    // 更新模型
    final updatedPhotos = List<GrowthPhotoModel>.from(_cat.growthPhotos)
      ..removeWhere((p) => p.id == gp.id);
    _cat = _cat.copyWith(
      growthPhotos: updatedPhotos,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateCat(_cat);
    _loadCatData();

    if (mounted) {
      showSuccess('成长记录已删除');
    }
  }

  // ==================== 原有功能 ====================

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _cat.photos.isNotEmpty
            ? Image.network(
                _cat.photos.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.pets, size: 100),
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _confirmDelete,
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _cat.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(_cat.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.cake,
                    title: '年龄',
                    value: _cat.age,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.pets,
                    title: '性别',
                    value: _cat.gender,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.monitor_weight,
                    title: '体重',
                    value: '${_cat.weight}kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.category,
                    title: '品种',
                    value: _cat.breed,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.event,
                    title: '救助日期',
                    value: DateFormat('yyyy-MM-dd').format(_cat.rescueDate),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性格标签',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (_cat.personalityTags.isEmpty)
          const Text('暂无性格标签')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cat.personalityTags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 26),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildStatusManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '状态管理',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('待救助'),
                  value: '待救助',
                  groupValue: _cat.status,
                  onChanged: (value) => _updateStatus(value!),
                ),
                RadioListTile<String>(
                  title: const Text('隔离中'),
                  value: '隔离中',
                  groupValue: _cat.status,
                  onChanged: (value) => _updateStatus(value!),
                ),
                RadioListTile<String>(
                  title: const Text('健康待领养'),
                  value: '健康待领养',
                  groupValue: _cat.status,
                  onChanged: (value) => _updateStatus(value!),
                ),
                RadioListTile<String>(
                  title: const Text('已送养'),
                  value: '已送养',
                  groupValue: _cat.status,
                  onChanged: (value) => _updateStatus(value!),
                ),
                RadioListTile<String>(
                  title: const Text('回喵星'),
                  value: '回喵星',
                  groupValue: _cat.status,
                  onChanged: (value) => _updateStatus(value!),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '医疗记录 (${_medicalRecords.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicalRecordScreen(catId: _cat.id),
                  ),
                ).then((_) => _loadCatData());
              },
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_medicalRecords.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('暂无医疗记录')),
            ),
          )
        else
          ..._medicalRecords.take(3).map((record) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _getMedicalTypeIcon(record.type),
                title: Text(record.title),
                subtitle: Text(
                  '${record.type} • ${DateFormat('yyyy-MM-dd').format(record.recordDate)}',
                ),
                trailing: record.isOverdue
                    ? const Icon(Icons.warning, color: Colors.red)
                    : record.isDueSoon
                        ? const Icon(Icons.event, color: Colors.orange)
                        : null,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '更多描述',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _cat.description ?? '暂无描述',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Icon _getMedicalTypeIcon(String type) {
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

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _cat = _cat.copyWith(status: newStatus, updatedAt: DateTime.now());
    });
    await _databaseService.updateCat(_cat);
    showSuccess('状态已更新为: $newStatus');
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除「${_cat.name}」吗？此操作不可恢复。'),
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
      await _databaseService.deleteCat(_cat.id);
      if (mounted) {
        Navigator.pop(context);
        showSuccess('已删除');
      }
    }
  }
}

// ==================== 视频预览组件 ====================

class _VideoPreviewWidget extends StatefulWidget {
  final String filePath;
  const _VideoPreviewWidget({required this.filePath});

  @override
  State<_VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<_VideoPreviewWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.filePath));
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        _controller!.setVolume(0);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: Text('🎬 视频预览失败', style: TextStyle(fontSize: 24))),
      );
    }
    if (!_initialized) {
      return Container(
        height: 150,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          VideoProgressIndicator(_controller!, allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.orange,
                bufferedColor: Colors.white38,
              )),
        ],
      ),
    );
  }
}

// ==================== 全屏浏览成长记录 ====================

class _GrowthPhotoViewer extends StatefulWidget {
  final GrowthPhotoModel gp;
  final String imagesDir;
  final String catName;
  final VoidCallback? onExport;

  const _GrowthPhotoViewer({
    required this.gp,
    required this.imagesDir,
    required this.catName,
    this.onExport,
  });

  @override
  State<_GrowthPhotoViewer> createState() => _GrowthPhotoViewerState();
}

class _GrowthPhotoViewerState extends State<_GrowthPhotoViewer> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
  }

  void _initVideoIfNeeded() {
    if (widget.gp.isVideo) {
      _initVideoPlayer();
    }
  }

  Future<void> _initVideoPlayer() async {
    try {
      final file = File('${widget.imagesDir}/${widget.gp.photoFileName}');
      if (!await file.exists()) return;

      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
      if (mounted) {
        setState(() => _videoInitialized = true);
      }
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = File('${widget.imagesDir}/${widget.gp.photoFileName}');
    final dateStr = DateFormat('yyyy年MM月dd日 HH:mm').format(widget.gp.dateTaken);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.gp.mediaEmoji} $dateStr',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: '导出',
            onPressed: widget.onExport,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: widget.gp.isVideo && _videoInitialized
                  ? _buildVideoPlayer()
                  : widget.gp.isVideo
                      ? _buildVideoLoading()
                      : _buildPhotoViewer(file),
            ),
          ),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            if (!_isPlaying && _videoController!.value.position == Duration.zero)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow,
                    size: 40, color: Colors.black87),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.orange,
                  bufferedColor: Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.orange),
        const SizedBox(height: 16),
        Text('🎬 ${widget.gp.photoFileName}',
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: widget.onExport,
          icon: const Icon(Icons.file_download, color: Colors.orange),
          label: const Text('导出视频文件', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  Widget _buildPhotoViewer(File file) {
    return InteractiveViewer(
      maxScale: 4,
      child: file.existsSync()
          ? Image.file(file, fit: BoxFit.contain)
          : const Icon(Icons.broken_image, size: 64, color: Colors.white54),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black87,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.gp.isVideo
                    ? Colors.purple.withValues(alpha: 0.3)
                    : Colors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.gp.mediaEmoji + ' ' + widget.gp.mediaLabel,
                style: TextStyle(
                  color: widget.gp.isVideo ? Colors.purple[200] : Colors.blue[200],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.gp.weight != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monitor_weight,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.gp.weight!.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            if (widget.gp.note != null && widget.gp.note!.isNotEmpty)
              const Spacer(),
            if (widget.gp.note != null && widget.gp.note!.isNotEmpty)
              Flexible(
                child: Text(
                  widget.gp.note!,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
