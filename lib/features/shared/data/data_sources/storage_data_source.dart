import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/exports.dart';

abstract class StorageDataSource {
  Future<String> uploadFile({required File file, required String path});

  Future<String> uploadVideo({required File file, required String path});

  Future<void> deleteFile({required String path});
}

class _Buckets {
  static const String images = 'images';
  static const String videos = 'videos';
}

class StoragePaths {
  static String profilePhoto(String uid) => 'profiles/$uid';
  static String chatMedia(String chatId) => 'chat_media/$chatId';
  static String storyImage(String uid) => 'stories/$uid/images';
  static String storyVideo(String uid) => 'stories/$uid/videos';
}

@LazySingleton(as: StorageDataSource)
class SupabaseStorageDataSourceImpl implements StorageDataSource {
  final SupabaseClient _supabase;

  const SupabaseStorageDataSourceImpl(this._supabase);

  @override
  Future<String> uploadFile({required File file, required String path}) async {
    try {
      final ext = _safeExtension(file.path, fallback: '.jpg');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final objectPath = '$path/$fileName';

      final bytes = await file.readAsBytes();

      await _supabase.storage
          .from(_Buckets.images)
          .uploadBinary(objectPath, bytes);

      return _supabase.storage.from(_Buckets.images).getPublicUrl(objectPath);
    } catch (e, st) {
      debugPrint('SupabaseStorageDataSourceImpl.uploadFile error: $e\n$st');
      throw StorageUploadException('Failed to upload file: $e');
    }
  }

  @override
  Future<String> uploadVideo({required File file, required String path}) async {
    try {
      final ext = _safeExtension(file.path, fallback: '.mp4');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final objectPath = '$path/$fileName';

      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path) ?? 'video/mp4';

      await _supabase.storage
          .from(_Buckets.videos)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );

      return _supabase.storage.from(_Buckets.videos).getPublicUrl(objectPath);
    } catch (e, st) {
      debugPrint('SupabaseStorageDataSourceImpl.uploadVideo error: $e\n$st');
      throw StorageUploadException('Failed to upload video: $e');
    }
  }

  @override
  Future<void> deleteFile({required String path}) async {
    if (path.isEmpty) return;

    try {
      final uri = Uri.parse(path);
      final segments = uri.pathSegments;

      final publicIndex = segments.indexOf('public');
      if (publicIndex == -1 || publicIndex + 1 >= segments.length) {
        throw StorageUploadException(
          'Unexpected Supabase storage URL format: $path',
        );
      }

      final bucket = segments[publicIndex + 1];
      final objectPath = segments.sublist(publicIndex + 2).join('/');

      final res = await _supabase.storage.from(bucket).remove([objectPath]);
      debugPrint('Supabase delete response: $res');
    } catch (e) {
      debugPrint('SupabaseStorageDataSourceImpl.deleteFile failed: $e');
      throw StorageUploadException('Failed to delete file: $e');
    }
  }

  String _safeExtension(String filePath, {required String fallback}) {
    final ext = p.extension(filePath).toLowerCase();
    return ext.isNotEmpty ? ext : fallback;
  }
}

class StorageUploadException implements Exception {
  final String message;
  const StorageUploadException(this.message);

  @override
  String toString() => 'StorageUploadException: $message';
}
