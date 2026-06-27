import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';

/// Web 平台媒体存储服务
/// 使用 Hive 本地数据库存储媒体文件（Web 不支持文件系统操作）
class MediaStorageService {
  static const String _imageBoxName = 'cat_images';
  static const String _videoBoxName = 'cat_videos';
  static const String _tempBoxName = 'temp_media';

  static final MediaStorageService _instance = MediaStorageService._internal();
  factory MediaStorageService() => _instance;
  MediaStorageService._internal();

  Box<Uint8List>? _imageBox;
  Box<Uint8List>? _videoBox;
  Box<Uint8List>? _tempBox;

  /// 初始化 Hive 存储
  Future<void> init() async {
    await Hive.initFlutter();
    
    _imageBox = await Hive.openBox<Uint8List>(_imageBoxName);
    _videoBox = await Hive.openBox<Uint8List>(_videoBoxName);
    _tempBox = await Hive.openBox<Uint8List>(_tempBoxName);
  }

  // ==================== 图片操作 ====================

  /// 保存图片字节数据
  /// 返回生成的文件名（Hive key）
  Future<String?> saveImageBytes(Uint8List bytes, {String? ext}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = ext ?? 'jpg';
      final fileName = 'img_${timestamp}.$extension';
      
      await _imageBox!.put(fileName, bytes);
      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// 获取图片字节数据
  Future<Uint8List?> getImageBytes(String fileName) async {
    if (_imageBox == null) return null;
    return _imageBox!.get(fileName);
  }

  /// 获取所有图片文件名
  List<String> getAllImageNames() {
    if (_imageBox == null) return [];
    return _imageBox!.keys.cast<String>().toList();
  }

  // ==================== 视频操作 ====================

  /// 保存视频字节数据
  Future<String?> saveVideoBytes(Uint8List bytes, {String? ext}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = ext ?? 'mp4';
      final fileName = 'vid_${timestamp}.$extension';
      
      await _videoBox!.put(fileName, bytes);
      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// 获取视频字节数据
  Future<Uint8List?> getVideoBytes(String fileName) async {
    if (_videoBox == null) return null;
    return _videoBox!.get(fileName);
  }

  /// 获取所有视频文件名
  List<String> getAllVideoNames() {
    if (_videoBox == null) return [];
    return _videoBox!.keys.cast<String>().toList();
  }

  // ==================== 临时文件操作 ====================

  /// 保存临时文件
  Future<String?> saveTempBytes(Uint8List bytes, String key) async {
    try {
      await _tempBox!.put(key, bytes);
      return key;
    } catch (e) {
      return null;
    }
  }

  /// 获取临时文件
  Future<Uint8List?> getTempBytes(String key) async {
    if (_tempBox == null) return null;
    return _tempBox!.get(key);
  }

  /// 删除临时文件
  Future<void> deleteTemp(String key) async {
    await _tempBox?.delete(key);
  }

  // ==================== 删除操作 ====================

  /// 删除图片
  Future<void> deleteImage(String fileName) async {
    await _imageBox?.delete(fileName);
  }

  /// 删除视频
  Future<void> deleteVideo(String fileName) async {
    await _videoBox?.delete(fileName);
  }

  /// 批量删除图片
  Future<void> deleteImages(List<String> fileNames) async {
    await _imageBox?.deleteAll(fileNames);
  }

  /// 批量删除视频
  Future<void> deleteVideos(List<String> fileNames) async {
    await _videoBox?.deleteAll(fileNames);
  }

  // ==================== 统计 ====================

  /// 获取存储空间使用情况
  Future<StorageStats> getStorageStats() async {
    int imageCount = _imageBox?.length ?? 0;
    int imageTotalBytes = 0;
    int videoCount = _videoBox?.length ?? 0;
    int videoTotalBytes = 0;

    // 计算图片总大小
    for (final key in _imageBox?.keys ?? []) {
      final bytes = _imageBox!.get(key);
      if (bytes != null) {
        imageTotalBytes += bytes.length;
      }
    }

    // 计算视频总大小
    for (final key in _videoBox?.keys ?? []) {
      final bytes = _videoBox!.get(key);
      if (bytes != null) {
        videoTotalBytes += bytes.length;
      }
    }

    return StorageStats(
      imageCount: imageCount,
      imageTotalMB: (imageTotalBytes / (1024 * 1024)).toStringAsFixed(1),
      videoCount: videoCount,
      videoTotalMB: (videoTotalBytes / (1024 * 1024)).toStringAsFixed(1),
      totalMB: ((imageTotalBytes + videoTotalBytes) / (1024 * 1024)).toStringAsFixed(1),
    );
  }

  // ==================== 清理 ====================

  /// 关闭所有 Box
  Future<void> dispose() async {
    await _imageBox?.close();
    await _videoBox?.close();
    await _tempBox?.close();
  }

  /// 清空所有数据（慎用）
  Future<void> clearAll() async {
    await _imageBox?.clear();
    await _videoBox?.clear();
    await _tempBox?.clear();
  }
}

/// 存储统计
class StorageStats {
  final int imageCount;
  final String imageTotalMB;
  final int videoCount;
  final String videoTotalMB;
  final String totalMB;

  StorageStats({
    required this.imageCount,
    required this.imageTotalMB,
    required this.videoCount,
    required this.videoTotalMB,
    required this.totalMB,
  });
}
