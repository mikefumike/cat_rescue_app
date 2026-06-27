import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

/// 媒体文件存储服务（移动端实现）
/// 管理图片和视频的本地存储、读取、删除
class MediaStorageService {
  static const String _imageDirName = 'cat_images';
  static const String _videoDirName = 'cat_videos';
  static const String _tempDirName = 'temp';

  static final MediaStorageService _instance = MediaStorageService._internal();
  factory MediaStorageService() => _instance;
  MediaStorageService._internal();

  String? _appDocDir;

  /// 初始化存储目录
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _appDocDir = dir.path;
    await _ensureDirectory(_imageDirName);
    await _ensureDirectory(_videoDirName);
    await _ensureDirectory(_tempDirName);
  }

  Future<void> _ensureDirectory(String name) async {
    final dir = Directory('$_appDocDir/$name');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 获取存储目录路径
  String get imageDirPath => '$_appDocDir/$_imageDirName';
  String get videoDirPath => '$_appDocDir/$_videoDirName';

  // ==================== 图片操作 ====================

  /// 从相册/相机选择图片并保存到本地
  /// 返回保存后的相对文件名列表
  Future<List<String>> pickAndSaveImages({int maxImages = 9}) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFiles.length > maxImages) {
      pickedFiles.removeRange(maxImages, pickedFiles.length);
    }

    final savedNames = <String>[];
    for (final file in pickedFiles) {
      final name = await saveImage(file);
      if (name != null) savedNames.add(name);
    }
    return savedNames;
  }

  /// 拍照并保存
  Future<String?> takePhotoAndSave() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (photo == null) return null;
    return await saveImage(photo);
  }

  /// 保存图片文件到本地存储
  /// 返回文件名（不含路径）
  Future<String?> saveImage(XFile source) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (timestamp % 10000).toString().padLeft(4, '0');
      final ext = source.name.split('.').last.toLowerCase();
      final fileName = 'img_${timestamp}_$random.$ext';
      final destPath = '$imageDirPath/$fileName';

      final bytes = await source.readAsBytes();
      final file = File(destPath);
      await file.writeAsBytes(bytes);

      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// 保存图片字节数据
  Future<String?> saveImageBytes(Uint8List bytes, {String? ext}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = ext ?? 'jpg';
      final fileName = 'img_${timestamp}.$extension';
      final destPath = '$imageDirPath/$fileName';

      final file = File(destPath);
      await file.writeAsBytes(bytes);

      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// 获取图片完整路径
  String getImageFullPath(String fileName) {
    return '$imageDirPath/$fileName';
  }

  /// 获取图片文件
  File? getImageFile(String fileName) {
    final path = getImageFullPath(fileName);
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  /// 获取图片字节数据（用于显示）
  Future<Uint8List?> getImageBytes(String fileName) async {
    final file = getImageFile(fileName);
    if (file == null) return null;
    return await file.readAsBytes();
  }

  // ==================== 视频操作 ====================

  /// 选择视频并保存
  Future<String?> pickAndSaveVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video == null) return null;
    return await saveVideo(video);
  }

  /// 拍摄视频并保存
  Future<String?> recordAndSaveVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (video == null) return null;
    return await saveVideo(video);
  }

  /// 保存视频文件
  Future<String?> saveVideo(XFile source) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = source.name.split('.').last.toLowerCase();
      final fileName = 'vid_${timestamp}.$ext';
      final destPath = '$videoDirPath/$fileName';

      // 复制文件
      final sourceFile = File(source.path);
      await sourceFile.copy(destPath);

      return fileName;
    } catch (e) {
      return null;
    }
  }

  /// 获取视频完整路径
  String getVideoFullPath(String fileName) {
    return '$videoDirPath/$fileName';
  }

  /// 获取视频文件
  File? getVideoFile(String fileName) {
    final path = getVideoFullPath(fileName);
    final file = File(path);
    return file.existsSync() ? file : null;
  }

  // ==================== 删除操作 ====================

  /// 删除图片
  Future<void> deleteImage(String fileName) async {
    final file = getImageFile(fileName);
    if (file != null) await file.delete();
  }

  /// 删除视频
  Future<void> deleteVideo(String fileName) async {
    final file = getVideoFile(fileName);
    if (file != null) await file.delete();
  }

  /// 批量删除图片
  Future<void> deleteImages(List<String> fileNames) async {
    for (final name in fileNames) {
      await deleteImage(name);
    }
  }

  // ==================== 统计 ====================

  /// 获取存储空间使用情况
  Future<StorageStats> getStorageStats() async {
    int imageCount = 0;
    int imageTotalBytes = 0;
    int videoCount = 0;
    int videoTotalBytes = 0;

    final imageDir = Directory(imageDirPath);
    if (await imageDir.exists()) {
      await for (final entity in imageDir.list()) {
        if (entity is File) {
          imageCount++;
          imageTotalBytes += await entity.length();
        }
      }
    }

    final videoDir = Directory(videoDirPath);
    if (await videoDir.exists()) {
      await for (final entity in videoDir.list()) {
        if (entity is File) {
          videoCount++;
          videoTotalBytes += await entity.length();
        }
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
