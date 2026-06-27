import 'package:hive_flutter/hive_flutter.dart';
import 'package:cat_rescue_app/models/cat_model.dart';
import 'package:cat_rescue_app/models/medical_record_model.dart';
import 'package:cat_rescue_app/models/adoption_model.dart';
import 'package:cat_rescue_app/models/growth_photo_model.dart';

class DatabaseService {
  static const String catsBoxName = 'cats';
  static const String medicalRecordsBoxName = 'medical_records';
  static const String usersBoxName = 'users';
  static const String adoptionsBoxName = 'adoptions';

  late Box<CatModel> _catsBox;
  late Box<MedicalRecordModel> _medicalRecordsBox;
  late Box _usersBox;
  late Box<AdoptionModel> _adoptionsBox;

  // 单例模式
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // 初始化数据库
  Future<void> init() async {
    // 注册Hive适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CatModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MedicalRecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AdoptionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(GrowthPhotoModelAdapter());
    }

    // 打开Box
    _catsBox = await Hive.openBox<CatModel>(catsBoxName);
    _medicalRecordsBox = await Hive.openBox<MedicalRecordModel>(medicalRecordsBoxName);
    _usersBox = await Hive.openBox(usersBoxName);
    _adoptionsBox = await Hive.openBox(adoptionsBoxName);
  }

  // ==================== 猫咪管理 ====================
  
  // 获取所有猫咪
  List<CatModel> getAllCats() {
    return _catsBox.values.toList();
  }

  // 根据状态获取猫咪
  List<CatModel> getCatsByStatus(String status) {
    return _catsBox.values.where((cat) => cat.status == status).toList();
  }

  // 添加猫咪
  Future<void> addCat(CatModel cat) async {
    await _catsBox.put(cat.id, cat);
  }

  // 更新猫咪
  Future<void> updateCat(CatModel cat) async {
    await _catsBox.put(cat.id, cat);
  }

  // 删除猫咪
  Future<void> deleteCat(String id) async {
    await _catsBox.delete(id);
    // 同时删除相关的医疗记录
    final records = getMedicalRecordsByCatId(id);
    for (var record in records) {
      await deleteMedicalRecord(record.id);
    }
  }

  // 根据ID获取猫咪
  CatModel? getCatById(String id) {
    return _catsBox.get(id);
  }

  // ==================== 医疗记录管理 ====================
  
  // 获取所有医疗记录
  List<MedicalRecordModel> getAllMedicalRecords() {
    return _medicalRecordsBox.values.toList();
  }

  // 根据猫咪ID获取医疗记录
  List<MedicalRecordModel> getMedicalRecordsByCatId(String catId) {
    return _medicalRecordsBox.values
        .where((record) => record.catId == catId)
        .toList()
      ..sort((a, b) => b.recordDate.compareTo(a.recordDate));
  }

  // 添加医疗记录
  Future<void> addMedicalRecord(MedicalRecordModel record) async {
    await _medicalRecordsBox.put(record.id, record);
  }

  // 更新医疗记录
  Future<void> updateMedicalRecord(MedicalRecordModel record) async {
    await _medicalRecordsBox.put(record.id, record);
  }

  // 删除医疗记录
  Future<void> deleteMedicalRecord(String id) async {
    await _medicalRecordsBox.delete(id);
  }

  // 获取即将到期的医疗记录
  List<MedicalRecordModel> getUpcomingMedicalRecords({int days = 7}) {
    final now = DateTime.now();
    return _medicalRecordsBox.values.where((record) {
      if (record.nextDueDate == null) return false;
      final difference = record.nextDueDate!.difference(now).inDays;
      return difference >= 0 && difference <= days;
    }).toList();
  }

  // 获取已过期的医疗记录
  List<MedicalRecordModel> getOverdueMedicalRecords() {
    final now = DateTime.now();
    return _medicalRecordsBox.values.where((record) {
      if (record.nextDueDate == null) return false;
      return record.nextDueDate!.isBefore(now);
    }).toList();
  }

  // ==================== 统计数据 ====================
  
  // 获取各状态猫咪数量
  Map<String, int> getCatStatusCounts() {
    final counts = <String, int>{};
    for (var cat in _catsBox.values) {
      counts[cat.status] = (counts[cat.status] ?? 0) + 1;
    }
    return counts;
  }

  // 获取需要关注的医疗记录数量
  int getPendingMedicalCount() {
    return getUpcomingMedicalRecords().length + getOverdueMedicalRecords().length;
  }

  // ==================== 收养申请管理 ====================

  // 获取所有收养申请
  List<AdoptionModel> getAllAdoptions() {
    return _adoptionsBox.values.toList()
      ..sort((a, b) => b.applyDate.compareTo(a.applyDate));
  }

  // 根据状态获取收养申请
  List<AdoptionModel> getAdoptionsByStatus(String status) {
    return _adoptionsBox.values
        .where((a) => a.status == status)
        .toList()
      ..sort((a, b) => b.applyDate.compareTo(a.applyDate));
  }

  // 根据猫咪ID获取收养申请
  List<AdoptionModel> getAdoptionsByCatId(String catId) {
    return _adoptionsBox.values
        .where((a) => a.catId == catId)
        .toList()
      ..sort((a, b) => b.applyDate.compareTo(a.applyDate));
  }

  // 添加收养申请
  Future<void> addAdoption(AdoptionModel adoption) async {
    await _adoptionsBox.put(adoption.id, adoption);
  }

  // 更新收养申请
  Future<void> updateAdoption(AdoptionModel adoption) async {
    await _adoptionsBox.put(adoption.id, adoption);
  }

  // 删除收养申请
  Future<void> deleteAdoption(String id) async {
    await _adoptionsBox.delete(id);
  }

  // 根据ID获取收养申请
  AdoptionModel? getAdoptionById(String id) {
    return _adoptionsBox.get(id);
  }

  // ==================== 收养统计 ====================

  // 获取各状态收养申请数量
  Map<String, int> getAdoptionStatusCounts() {
    final counts = <String, int>{};
    for (var a in _adoptionsBox.values) {
      counts[a.status] = (counts[a.status] ?? 0) + 1;
    }
    return counts;
  }

  // 关闭数据库
  Future<void> close() async {
    await _catsBox.close();
    await _medicalRecordsBox.close();
    await _usersBox.close();
    await _adoptionsBox.close();
  }
}
