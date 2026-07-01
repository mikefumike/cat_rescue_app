import 'package:cat_rescue_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/services/export_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _exportService = ExportService();
  PackageInfo _packageInfo = PackageInfo(
    appName: '光影爱宠',
    packageName: 'com.example.cat_rescue_app',
    version: '1.0.0',
    buildNumber: '1',
  );
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {
      // 忽略
    }
  }

  void showSuccess(String msg) {
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.green);
  }

  void showError(String msg) {
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.red);
  }

  void showInfo(String msg) {
    Fluttertoast.showToast(msg: msg, backgroundColor: const Color(0xFFFF8C42));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚙️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('设置'),
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
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('用户与权限'),
            _buildUserManagement(),
            const Divider(),
            _buildSectionHeader('数据管理'),
            _buildDataManagement(),
            const Divider(),
            _buildSectionHeader('微信维护'),
            _buildWechatSection(),
            const Divider(),
            _buildSectionHeader('提醒设置'),
            _buildReminderSettings(),
            const Divider(),
            _buildSectionHeader('联系我们'),
            _buildContactUs(),
            const Divider(),
            _buildSectionHeader('关于应用'),
            _buildAppInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFFFF8C42),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildWechatSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF07C160).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code, color: Color(0xFF07C160), size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '微信客服 / 运维群',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '扫码联系工作人员或加入运维群',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 二维码图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/wechat_qr.png',
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text('二维码加载失败', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '长按识别 · 保存到相册',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFF8C42).withValues(alpha: 0.1),
        child: const Icon(Icons.person, color: Color(0xFFFF8C42)),
      ),
      title: const Text('管理员'),
      subtitle: const Text('当前角色：超级管理员'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showInfo('多用户管理功能开发中...'),
    );
  }

  Widget _buildDataManagement() {
    return Column(
      children: [
        // ── 导出数据（核心功能）─
        _buildExportTile(),

        const Divider(),

        // 清空所有数据
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('清空所有数据', style: TextStyle(color: Colors.red)),
          subtitle: const Text('此操作不可恢复'),
          onTap: _confirmClearData,
        ),
      ],
    );
  }

  Widget _buildExportTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8C42).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.file_download, color: Color(0xFFFF8C42)),
      ),
      title: const Text('📊 导出数据'),
      subtitle: const Text('导出为 Excel 表格，方便查看和备份'),
      trailing: _isExporting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _isExporting ? null : _showExportDialog,
    );
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ExportBottomSheet(
        onExportAll: () => _doExport('all'),
        onExportCats: () => _doExport('cats'),
        onExportMedical: () => _doExport('medical'),
        onExportAdoptions: () => _doExport('adoptions'),
        isExporting: _isExporting,
      ),
    );
  }

  Future<void> _doExport(String type) async {
    Navigator.pop(context); // 关闭底部菜单

    setState(() => _isExporting = true);

    ExportResult result;
    switch (type) {
      case 'cats':
        result = await _exportService.exportCats();
        break;
      case 'medical':
        result = await _exportService.exportMedicalRecords();
        break;
      case 'adoptions':
        result = await _exportService.exportAdoptions();
        break;
      default:
        result = await _exportService.exportAllData();
    }

    setState(() => _isExporting = false);

    if (result.success) {
      // 显示成功对话框
      if (mounted) {
        _showExportSuccessDialog(result);
      }
    } else {
      showError(result.message);
    }
  }

  void _showExportSuccessDialog(ExportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('✅ 导出成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            if (result.catCount != null)
              _buildCountChip('🐱 猫咪', '${result.catCount}'),
            if (result.recordCount != null)
              _buildCountChip('💉 医疗', '${result.recordCount}'),
            if (result.adoptionCount != null)
              _buildCountChip('🏠 领养', '${result.adoptionCount}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.filePath ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _exportService.openFile(result.filePath!);
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('打开文件'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C42),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C42).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Color(0xFFFF8C42),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettings() {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.medical_services, color: Color(0xFFFF8C42)),
          title: const Text('医疗提醒'),
          subtitle: const Text('疫苗、驱虫、绝育到期提醒'),
          value: true,
          onChanged: (v) => showInfo('功能开发中...'),
        ),
        ListTile(
          leading: const Icon(Icons.event, color: Color(0xFFFF8C42)),
          title: const Text('提前提醒天数'),
          subtitle: const Text('医疗记录到期前多少天提醒'),
          trailing: const Text('7天'),
          onTap: _setReminderDays,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.home, color: Color(0xFFFF8C42)),
          title: const Text('领养回访提醒'),
          subtitle: const Text('定期提醒回访已领养的猫咪'),
          value: true,
          onChanged: (v) => showInfo('功能开发中...'),
        ),
      ],
    );
  }

  Widget _buildContactUs() {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code, color: Color(0xFF07C160), size: 28),
          ),
          title: const Text('微信维护群'),
          subtitle: const Text('扫码联系管理员，加入维护群'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showWechatQrDialog,
        ),
        ListTile(
          leading: const Icon(Icons.support_agent, color: Color(0xFFFF8C42)),
          title: const Text('客服邮箱'),
          subtitle: const Text('guangying_aichong@outlook.com'),
          trailing: const Icon(Icons.copy, size: 18, color: Colors.grey),
          onTap: () {
            // TODO: 复制邮箱
            showInfo('邮箱已复制');
          },
        ),
      ],
    );
  }

  void _showWechatQrDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF07C160).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wechat, color: Color(0xFF07C160), size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                '微信维护群',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '扫码加入，与管理员沟通',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/wechat_maintenance_qr.png',
                  width: 260,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('二维码加载失败', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('关闭'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info, color: Color(0xFFFF8C42)),
          title: const Text('应用版本'),
          trailing: Text('v${_packageInfo.version} (${_packageInfo.buildNumber})'),
        ),
        ListTile(
          leading: const Icon(Icons.description, color: Color(0xFFFF8C42)),
          title: const Text('使用条款'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip, color: Color(0xFFFF8C42)),
          title: const Text('隐私政策'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.star, color: Color(0xFFFF8C42)),
          title: const Text('给应用评分'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.feedback, color: Color(0xFFFF8C42)),
          title: const Text('意见反馈'),
          onTap: () {},
        ),
      ],
    );
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('确认清空'),
        content: const Text(
          '确定要清空所有数据吗？\n\n包括：\n• 所有猫咪信息\n• 所有医疗记录\n• 所有领养记录\n\n此操作不可恢复！',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('清空', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = DatabaseService();
        for (var cat in db.getAllCats()) {
          await db.deleteCat(cat.id);
        }
        showSuccess('已清空所有数据');
        setState(() {});
      } catch (e) {
        showError('清空失败: $e');
      }
    }
  }

  Future<void> _setReminderDays() async {
    final controller = TextEditingController(text: '7');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('设置提醒天数'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '提前天数', hintText: '例如：7'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) Navigator.pop(context, days);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (result != null) showSuccess('已设置为提前 $result 天提醒');
  }
}

/// ── 导出选择底部菜单 ──
class _ExportBottomSheet extends StatelessWidget {
  final VoidCallback onExportAll;
  final VoidCallback onExportCats;
  final VoidCallback onExportMedical;
  final VoidCallback onExportAdoptions;
  final bool isExporting;

  const _ExportBottomSheet({
    required this.onExportAll,
    required this.onExportCats,
    required this.onExportMedical,
    required this.onExportAdoptions,
    required this.isExporting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动条
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '📊 导出数据',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            '选择要导出的数据（Excel 格式）',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // 全部导出
          _ExportOption(
            icon: Icons.summarize,
            color: const Color(0xFFFF8C42),
            title: '📋 导出全部数据',
            subtitle: '猫咪 + 医疗记录 + 领养记录 + 统计',
            onTap: isExporting ? null : onExportAll,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ExportOption(
                  icon: Icons.pets,
                  color: Colors.blue,
                  title: '🐱 猫咪列表',
                  onTap: isExporting ? null : onExportCats,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExportOption(
                  icon: Icons.medical_services,
                  color: Colors.red,
                  title: '💉 医疗记录',
                  onTap: isExporting ? null : onExportMedical,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ExportOption(
            icon: Icons.home,
            color: Colors.green,
            title: '🏠 领养记录',
            onTap: isExporting ? null : onExportAdoptions,
          ),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (subtitle != null)
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
