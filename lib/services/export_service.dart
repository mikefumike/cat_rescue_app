import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cat_rescue_app/services/database_service.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/models/growth_photo_model.dart';

/// Excel 数据导出服务
class ExportService {
  final DatabaseService _db = DatabaseService();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  // 橙色表头样式
  CellStyle get _headerStyle => CellStyle(
    bold: true,
    fontSize: 12,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.fromHexString('FFFF8C42'),
    horizontalAlign: HorizontalAlign.Center,
  );

  // 斑马纹-偶数行背景
  CellStyle _dataStyle(bool isEven) => CellStyle(
    fontSize: 11,
    backgroundColorHex: isEven
        ? ExcelColor.fromHexString('FFFFF8F4')
        : ExcelColor.white,
  );

  /// 导出全部数据
  Future<ExportResult> exportAllData() async {
    try {
      final cats = _db.getAllCats();
      final records = _db.getAllMedicalRecords();
      final adoptions = _db.getAllAdoptions();

      final excel = Excel.createExcel();
      _writeCatSheet(excel, cats);
      _writeMedicalSheet(excel, cats, records);
      _writeAdoptionSheet(excel, cats, adoptions);
      _writeStatsSheet(excel, cats, records, adoptions);

      final fileName = '光影爱宠_数据导出_${_dateFormat.format(DateTime.now())}.xlsx';
      final filePath = await _saveExcel(excel, fileName);

      return ExportResult(
        success: true,
        message: '成功导出 $fileName',
        filePath: filePath,
        catCount: cats.length,
        recordCount: records.length,
        adoptionCount: adoptions.length,
      );
    } catch (e) {
      return ExportResult(success: false, message: '导出失败: $e');
    }
  }

  /// 导出猫咪列表
  Future<ExportResult> exportCats() async {
    try {
      final cats = _db.getAllCats();
      final excel = Excel.createExcel();
      _writeCatSheet(excel, cats);
      final fileName = '光影爱宠_猫咪列表_${_dateFormat.format(DateTime.now())}.xlsx';
      final filePath = await _saveExcel(excel, fileName);
      return ExportResult(
        success: true,
        message: '成功导出 $fileName',
        filePath: filePath,
        catCount: cats.length,
      );
    } catch (e) {
      return ExportResult(success: false, message: '导出失败: $e');
    }
  }

  /// 导出医疗记录
  Future<ExportResult> exportMedicalRecords() async {
    try {
      final cats = _db.getAllCats();
      final records = _db.getAllMedicalRecords();
      final excel = Excel.createExcel();
      _writeMedicalSheet(excel, cats, records);
      final fileName = '光影爱宠_医疗记录_${_dateFormat.format(DateTime.now())}.xlsx';
      final filePath = await _saveExcel(excel, fileName);
      return ExportResult(
        success: true,
        message: '成功导出 $fileName',
        filePath: filePath,
        recordCount: records.length,
      );
    } catch (e) {
      return ExportResult(success: false, message: '导出失败: $e');
    }
  }

  /// 导出领养记录
  Future<ExportResult> exportAdoptions() async {
    try {
      final cats = _db.getAllCats();
      final adoptions = _db.getAllAdoptions();
      final excel = Excel.createExcel();
      _writeAdoptionSheet(excel, cats, adoptions);
      final fileName = '光影爱宠_领养记录_${_dateFormat.format(DateTime.now())}.xlsx';
      final filePath = await _saveExcel(excel, fileName);
      return ExportResult(
        success: true,
        message: '成功导出 $fileName',
        filePath: filePath,
        adoptionCount: adoptions.length,
      );
    } catch (e) {
      return ExportResult(success: false, message: '导出失败: $e');
    }
  }

  /// 导出成长记录
  Future<ExportResult> exportGrowthRecords(
    CatModel cat, {
    List<GrowthPhotoModel>? selectedRecords,
  }) async {
    try {
      final records = selectedRecords ?? cat.growthPhotos;
      if (records.isEmpty) {
        return ExportResult(success: false, message: '暂无成长记录可导出');
      }

      final sorted = List<GrowthPhotoModel>.from(records)
        ..sort((a, b) => a.dateTaken.compareTo(b.dateTaken));

      final excel = Excel.createExcel();
      final sheet = excel['成长记录'];

      // 标题行
      final headers = ['日期', '时间', '类型', '备注', '体重(kg)', '文件名'];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = _headerStyle;
      }

      // 数据行
      for (var row = 0; row < sorted.length; row++) {
        final r = sorted[row];
        final isEven = row % 2 == 0;
        final data = [
          _dateFormat.format(r.dateTaken),
          DateFormat('HH:mm').format(r.dateTaken),
          r.isVideo ? '视频' : '照片',
          r.note ?? '',
          r.weight?.toStringAsFixed(1) ?? '',
          r.photoFileName,
        ];
        for (var col = 0; col < data.length; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
          cell.value = TextCellValue(data[col]);
          cell.cellStyle = _dataStyle(isEven);
        }
      }

      _setColumnWidths(sheet, {0: 14, 1: 10, 2: 8, 3: 25, 4: 10, 5: 25});

      // 添加统计行
      final photoCount = sorted.where((r) => !r.isVideo).length;
      final videoCount = sorted.where((r) => r.isVideo).length;
      final statRow = sorted.length + 2;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: statRow))
        ..value = TextCellValue('📊 统计')
        ..cellStyle = CellStyle(bold: true);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: statRow))
        ..value = TextCellValue('共 ${sorted.length} 条（照片 $photoCount，视频 $videoCount）')
        ..cellStyle = CellStyle(italic: true);

      final fileName = '${cat.name}成长记录_${_dateFormat.format(DateTime.now())}.xlsx';
      final filePath = await _saveExcel(excel, fileName);

      return ExportResult(
        success: true,
        message: '成功导出 ${cat.name} 的 $fileName',
        filePath: filePath,
        recordCount: sorted.length,
      );
    } catch (e) {
      return ExportResult(success: false, message: '导出失败: $e');
    }
  }

  // ─── 猫咪工作表 ───
  void _writeCatSheet(Excel excel, List<CatModel> cats) {
    final sheet = excel['猫咪列表'];

    final headers = ['编号', '名字', '性别', '年龄', '品种', '体重(kg)', '状态', '救助日期', '性格标签', '描述/备注'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }

    for (var row = 0; row < cats.length; row++) {
      final cat = cats[row];
      final isEven = row % 2 == 0;
      final data = [
        cat.id,
        cat.name,
        cat.gender,
        cat.age,
        cat.breed,
        '${cat.weight}',
        cat.status,
        _dateFormat.format(cat.rescueDate),
        cat.personalityTags.join('、'),
        cat.description ?? '',
      ];
      for (var col = 0; col < data.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        cell.value = TextCellValue(data[col]);
        cell.cellStyle = _dataStyle(isEven);
      }
    }

    // 设置列宽
    _setColumnWidths(sheet, {0: 10, 1: 10, 2: 6, 3: 8, 4: 14, 5: 10, 6: 14, 7: 14, 8: 20, 9: 25});
  }

  // ─── 医疗记录工作表 ───
  void _writeMedicalSheet(Excel excel, List<CatModel> cats, List<MedicalRecordModel> records) {
    final sheet = excel['医疗记录'];

    final headers = ['猫咪名字', '记录类型', '标题', '记录日期', '下次到期', '用药', '剂量', '备注'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }

    for (var row = 0; row < records.length; row++) {
      final record = records[row];
      final cat = cats.where((c) => c.id == record.catId).firstOrNull;
      final isEven = row % 2 == 0;
      final data = [
        cat?.name ?? '未知猫咪',
        record.type,
        record.title,
        _dateTimeFormat.format(record.recordDate),
        record.nextDueDate != null ? _dateFormat.format(record.nextDueDate!) : '',
        record.medication ?? '',
        record.dosage ?? '',
        record.notes ?? '',
      ];
      for (var col = 0; col < data.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        cell.value = TextCellValue(data[col]);
        cell.cellStyle = _dataStyle(isEven);
      }
    }

    _setColumnWidths(sheet, {0: 12, 1: 10, 2: 20, 3: 18, 4: 14, 5: 15, 6: 12, 7: 20});
  }

  // ─── 领养记录工作表 ───
  void _writeAdoptionSheet(Excel excel, List<CatModel> cats, List<AdoptionModel> adoptions) {
    final sheet = excel['领养记录'];

    final headers = ['猫咪名字', '申请人', '联系方式', '申请日期', '审批状态', '送养日期', '居住条件', '有养宠经验', '封窗情况', '审核备注'];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }

    for (var row = 0; row < adoptions.length; row++) {
      final ad = adoptions[row];
      final cat = cats.where((c) => c.id == ad.catId).firstOrNull;
      final isEven = row % 2 == 0;
      final data = [
        cat?.name ?? '未知猫咪',
        ad.applicantName,
        ad.contact,
        _dateFormat.format(ad.applyDate),
        _statusText(ad.status),
        ad.adoptionDate != null ? _dateFormat.format(ad.adoptionDate!) : '',
        ad.livingCondition,
        ad.hasPetExperience ? '是' : '否',
        ad.hasSealedWindow ? '已封窗' : '未封窗',
        ad.reviewNotes ?? '',
      ];
      for (var col = 0; col < data.length; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        cell.value = TextCellValue(data[col]);
        cell.cellStyle = _dataStyle(isEven);
      }
    }

    _setColumnWidths(sheet, {0: 12, 1: 12, 2: 15, 3: 14, 4: 12, 5: 14, 6: 20, 7: 12, 8: 12, 9: 20});
  }

  // ─── 统计工作表 ───
  void _writeStatsSheet(Excel excel, List<CatModel> cats, List<MedicalRecordModel> records, List<AdoptionModel> adoptions) {
    final sheet = excel['数据统计'];
    final statusCounts = _db.getCatStatusCounts();
    final vaccineCount = records.where((r) => r.type == '疫苗').length;
    final dewormCount = records.where((r) => r.type == '驱虫').length;

    int row = 0;
    void addTitle(String t) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        ..value = TextCellValue(t)
        ..cellStyle = CellStyle(bold: true, fontSize: 13, backgroundColorHex: ExcelColor.fromHexString('FFFFF3E0'));
      row++;
    }
    void addRow(String l, String v) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(l);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(v);
      row++;
    }

    addTitle('光影爱宠 数据统计总览');
    addRow('导出时间', _dateTimeFormat.format(DateTime.now()));
    row++;
    addTitle('猫咪统计');
    addRow('猫咪总数', '${cats.length}');
    for (var e in statusCounts.entries) addRow(e.key, '${e.value}');
    row++;
    addTitle('医疗统计');
    addRow('医疗记录总数', '${records.length}');
    addRow('疫苗记录', '$vaccineCount');
    addRow('驱虫记录', '$dewormCount');
    row++;
    addTitle('领养统计');
    addRow('领养申请总数', '${adoptions.length}');
    addRow('已通过', '${adoptions.where((a) => a.status == 'approved').length}');
    addRow('待审批', '${adoptions.where((a) => a.status == 'pending').length}');
    addRow('已拒绝', '${adoptions.where((a) => a.status == 'rejected').length}');
  }

  String _statusText(String s) {
    return {'pending': '待审批', 'approved': '已通过', 'rejected': '已拒绝'}[s] ?? s;
  }

  void _setColumnWidths(Sheet sheet, Map<int, double> widths) {
    for (var entry in widths.entries) {
      sheet.setColumnWidth(entry.key, entry.value);
    }
  }

  Future<String> _saveExcel(Excel excel, String fileName) async {
    Directory? dir;
    if (Platform.isAndroid) {
      try {
        dir = await getExternalStorageDirectory();
        if (dir != null) {
          final downloadDir = Directory('${dir.path}/Download');
          if (!downloadDir.existsSync()) downloadDir.createSync(recursive: true);
          dir = downloadDir;
        }
      } catch (_) {}
    }
    dir ??= await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }

  /// 分享文件（用系统分享菜单，可选 Excel/WPS 打开）
  Future<void> openFile(String path) async {
    await Share.shareXFiles([XFile(path)], text: '光影爱宠数据导出 - 可用 Excel 或 WPS 打开');
  }
}

class ExportResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? catCount;
  final int? recordCount;
  final int? adoptionCount;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.catCount,
    this.recordCount,
    this.adoptionCount,
  });
}
