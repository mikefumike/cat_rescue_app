// lib/services/api_service.dart - API 服务类 (替换 DatabaseService)
// 用于连接云端后端，替代本地 Hive 数据库

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/cat_model.dart';
import '../models/medical_record_model.dart';
import '../models/adoption_model.dart';
import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  UserRole _currentRole = UserRole.guest;

  // 获取当前 token
  String? get token => _token;

  // 获取当前用户角色
  UserRole get currentRole => _currentRole;

  // 设置 token
  void setToken(String? token) {
    _token = token;
  }

  // 设置用户角色
  void setRole(UserRole role) {
    _currentRole = role;
  }

  // 通用请求头
  Map<String, String> _headers({bool needToken = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (needToken && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['error'] ?? '请求失败: ${response.statusCode}');
    }
  }

  // ==================== 认证相关 ====================

  // 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.LOGIN),
      headers: _headers(needToken: false),
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      _token = result['data']['token'];
      final roleStr = result['data']['user']['role'];
      _currentRole = roleStr == 'admin' ? UserRole.admin : UserRole.guest;
    }
    return result;
  }

  // 注册 (管理员)
  Future<Map<String, dynamic>> register(String username, String password, String role, String adminUsername, String adminPassword) async {
    final response = await http.post(
      Uri.parse(ApiConfig.REGISTER),
      headers: _headers(needToken: false),
      body: jsonEncode({
        'username': username,
        'password': password,
        'role': role,
        'adminUsername': adminUsername,
        'adminPassword': adminPassword,
      }),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    return _handleResponse(response);
  }

  // 验证 token
  Future<Map<String, dynamic>> verifyToken() async {
    final response = await http.get(
      Uri.parse(ApiConfig.VERIFY),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    return _handleResponse(response);
  }

  // 初始化管理员
  Future<Map<String, dynamic>> initAdmin() async {
    final response = await http.post(
      Uri.parse(ApiConfig.INIT_ADMIN),
      headers: _headers(needToken: false),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    return _handleResponse(response);
  }

  // ==================== 猫咪管理 ====================

  // 获取所有猫咪
  Future<List<CatModel>> getAllCats({String? status, String? search}) async {
    String url = ApiConfig.CATS;
    if (status != null || search != null) {
      final query = <String, String>{};
      if (status != null) query['status'] = status;
      if (search != null) query['search'] = search;
      url += '?${Uri(queryParameters: query).query}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => CatModel.fromJson(json)).toList();
    }
    return [];
  }

  // 获取单个猫咪
  Future<CatModel?> getCatById(String catId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.CAT_DETAIL}/$catId'),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return CatModel.fromJson(result['data']);
    }
    return null;
  }

  // 添加猫咪
  Future<CatModel> addCat(CatModel cat) async {
    final response = await http.post(
      Uri.parse(ApiConfig.CATS),
      headers: _headers(),
      body: jsonEncode(cat.toJson()),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return CatModel.fromJson(result['data']);
    }
    throw Exception('添加猫咪失败');
  }

  // 更新猫咪
  Future<CatModel> updateCat(String catId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.CAT_DETAIL}/$catId'),
      headers: _headers(),
      body: jsonEncode(updates),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return CatModel.fromJson(result['data']);
    }
    throw Exception('更新猫咪失败');
  }

  // 删除猫咪
  Future<void> deleteCat(String catId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.CAT_DETAIL}/$catId'),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    _handleResponse(response);
  }

  // ==================== 医疗记录 ====================

  // 获取某猫咪的所有医疗记录
  Future<List<MedicalRecordModel>> getMedicalRecordsByCat(String catId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.MEDICAL_BY_CAT}/$catId'),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => MedicalRecordModel.fromJson(json)).toList();
    }
    return [];
  }

  // 添加医疗记录
  Future<MedicalRecordModel> addMedicalRecord(MedicalRecordModel record) async {
    final response = await http.post(
      Uri.parse(ApiConfig.MEDICAL),
      headers: _headers(),
      body: jsonEncode(record.toJson()),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return MedicalRecordModel.fromJson(result['data']);
    }
    throw Exception('添加医疗记录失败');
  }

  // 更新医疗记录
  Future<MedicalRecordModel> updateMedicalRecord(String recordId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.MEDICAL}/$recordId'),
      headers: _headers(),
      body: jsonEncode(updates),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return MedicalRecordModel.fromJson(result['data']);
    }
    throw Exception('更新医疗记录失败');
  }

  // 删除医疗记录
  Future<void> deleteMedicalRecord(String recordId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.MEDICAL}/$recordId'),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    _handleResponse(response);
  }

  // ==================== 收养申请 ====================

  // 获取所有收养申请
  Future<List<AdoptionModel>> getAllAdoptions({String? status}) async {
    String url = ApiConfig.ADOPTIONS;
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => AdoptionModel.fromJson(json)).toList();
    }
    return [];
  }

  // 提交收养申请
  Future<AdoptionModel> addAdoption(AdoptionModel adoption) async {
    final response = await http.post(
      Uri.parse(ApiConfig.ADOPTIONS),
      headers: _headers(),
      body: jsonEncode(adoption.toJson()),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return AdoptionModel.fromJson(result['data']);
    }
    throw Exception('提交收养申请失败');
  }

  // 更新收养申请状态
  Future<AdoptionModel> updateAdoptionStatus(String adoptionId, String status, {String? note, String? adoptionDate}) async {
    final body = <String, dynamic>{'status': status};
    if (note != null) body['note'] = note;
    if (adoptionDate != null) body['adoptionDate'] = adoptionDate;

    final response = await http.put(
      Uri.parse('${ApiConfig.ADOPTION_STATUS}/$adoptionId/status'),
      headers: _headers(),
      body: jsonEncode(body),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    final result = _handleResponse(response);
    if (result['success']) {
      return AdoptionModel.fromJson(result['data']);
    }
    throw Exception('更新收养申请状态失败');
  }

  // 删除收养申请
  Future<void> deleteAdoption(String adoptionId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.ADOPTION_DETAIL}/$adoptionId'),
      headers: _headers(),
    ).timeout(Duration(milliseconds: ApiConfig.TIMEOUT));

    _handleResponse(response);
  }
}