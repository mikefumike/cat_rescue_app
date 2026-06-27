import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 统一媒体存储服务
/// 自动根据平台选择实现：移动端/桌面端用文件系统，Web端用 Hive (IndexedDB)
class MediaStorageService {
  static const String _webBoxName = 'web_media';

  static final MediaStorageService _instance = MediaStorageService._internal();
  factory MediaStorageService() => _instance;
  MediaStorageService._internal();

  // ==================== 初始化 ====================
  Future<void> init() async {
    if (kIsWeb) {
      await Hive.initFlutter();
      debugPrint('[MediaStorage] Web平台，使用Hive/IndexedDB存储');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${dir.path}/cat_images');
      final videoDir = Directory('${dir.path}/cat_videos');
      if (!await imageDir.exists()) await imageDir.create(recursive: true);
      if (!await videoDir.exists()) await videoDir.create(recursive: true);
      debugPrint('[MediaStorage] 移动端，存储目录: ${dir.path}');
    }
  }

  // ==================== 图片操作 ====================
  Future<List<String>> pickAndSaveImages({int maxImages = 9}) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (files.length > maxImages) {
      files.removeRange(maxImages, files.length);
    }
    final names = <String>[];
    for (final f in files) {
      final name = await _saveImageToPlatform(f);
      if (name != null) names.add(name);
    }
    return names;
  }

  Future<String?> takePhotoAndSave() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (photo == null) return null;
    return await _saveImageToPlatform(photo);
  }

  // ==================== 平台适配私有方法 ====================
  Future<String?> _saveImageToPlatform(XFile source) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = source.name.split('.').last.toLowerCase();
      final fileName = 'img_${timestamp}_${(timestamp % 10000).toString().padLeft(4, '0')}.$ext';

      if (kIsWeb) {
        final bytes = await source.readAsBytes();
        final box = await Hive.openBox(_webBoxName);
        await box.put(fileName, bytes);
        return fileName;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final dest = '${dir.path}/cat_images/$fileName';
        final bytes = await source.readAsBytes();
        await File(dest).writeAsBytes(bytes);
        return fileName;
      }
    } catch (e) {
      debugPrint('[MediaStorage] 保存图片失败: $e');
      return null;
    }
  }

  Future<Uint8List?> getImageBytes(String fileName) async {
    try {
      if (kIsWeb) {
        final box = await Hive.openBox(_webBoxName);
        final data = box.get(fileName);
        if (data is Uint8List) return data;
        if (data is List<int>) return Uint8List.fromList(data);
        return null;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/cat_images/$fileName');
        if (await file.exists()) return await file.readAsBytes();
        return null;
      }
    } catch (e) {
      debugPrint('[MediaStorage] 读取图片失败: $e');
      return null;
    }
  }

  String getImageDisplayPath(String fileName) {
    if (kIsWeb) return fileName; // Web端返回文件名，调用方用 getImageBytes 获取字节
    return fileName; // 移动端目前也存文件名，实际显示时需拼接路径
  }

  // ==================== 视频操作 ====================
  Future<String?> pickAndSaveVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (video == null) return null;
    return await _saveVideoToPlatform(video);
  }

  Future<String?> _saveVideoToPlatform(XFile source) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = source.name.split('.').last.toLowerCase();
      final fileName = 'vid_$timestamp.$ext';

      if (kIsWeb) {
        final bytes = await source.readAsBytes();
        final box = await Hive.openBox(_webBoxName);
        await box.put(fileName, bytes);
        return fileName;
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final dest = '${dir.path}/cat_videos/$fileName';
        await File(source.path).copy(dest);
        return fileName;
      }
    } catch (e) {
      debugPrint('[MediaStorage] 保存视频失败: $e');
      return null;
    }
  }

  // ==================== 删除操作 ====================
  Future<void> deleteImage(String fileName) async {
    try {
      if (kIsWeb) {
        final box = await Hive.openBox(_webBoxName);
        await box.delete(fileName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/cat_images/$fileName');
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('[MediaStorage] 删除图片失败: $e');
    }
  }

  Future<void> deleteVideo(String fileName) async {
    try {
      if (kIsWeb) {
        final box = await Hive.openBox(_webBoxName);
        await box.delete(fileName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/cat_videos/$fileName');
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('[MediaStorage] 删除视频失败: $e');
    }
  }

  // ==================== 统计 ====================
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      if (kIsWeb) {
        final box = await Hive.openBox(_webBoxName);
        int imgCount = 0, vidCount = 0, totalBytes = 0;
        for (final key in box.keys) {
          final val = box.get(key);
          if (val is List<int>) {
            totalBytes += val.length;
            final k = key.toString();
            if (k.startsWith('img_')) imgCount++;
            if (k.startsWith('vid_')) vidCount++;
          }
        }
        return {
          'imageCount': imgCount,
          'videoCount': vidCount,
          'totalMB': (totalBytes / (1024 * 1024)).toStringAsFixed(1),
        };
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final imgDir = Directory('${dir.path}/cat_images');
        final vidDir = Directory('${dir.path}/cat_videos');
        int imgCount = 0, vidCount = 0, totalBytes = 0;
        if (await imgDir.exists()) {
          await for (final f in imgDir.list()) {
            if (f is File) { imgCount++; totalBytes += await f.length(); }
          }
        }
        if (await vidDir.exists()) {
          await for (final f in vidDir.list()) {
            if (f is File) { vidCount++; totalBytes += await f.length(); }
          }
        }
        return {
          'imageCount': imgCount,
          'videoCount': vidCount,
          'totalMB': (totalBytes / (1024 * 1024)).toStringAsFixed(1),
        };
      }
    } catch (e) {
      return {'imageCount': 0, 'videoCount': 0, 'totalMB': '0.0'};
    }
  }
}
