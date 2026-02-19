import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/exports.dart';

abstract class StorageDataSource {
  /// Uploads [file] to Supabase storage under [path] (a folder path).
  /// A unique timestamped filename is appended automatically.
  ///
  /// Example: path = 'profiles/uid' → stores as 'profiles/uid/1234567890.jpg'
  ///
  /// Returns the permanent public URL of the uploaded file.
  Future<String> uploadFile({required File file, required String path});

  /// Uploads a video [file] to the videos bucket under [path].
  /// Returns the permanent public URL.
  Future<String> uploadVideo({required File file, required String path});

  /// Deletes a file from Supabase storage.
  /// [path] must be the FULL public URL returned by [uploadFile],
  /// not a relative path. The bucket and object path are parsed from it.
  Future<void> deleteFile({required String path});
}

// ─── Bucket Names ─────────────────────────────────────────────────────────────

class _Buckets {
  static const String images = 'images';
  static const String videos = 'videos';
}

// ─── Storage Paths ────────────────────────────────────────────────────────────

class StoragePaths {
  static String profilePhoto(String uid) => 'profiles/$uid';
  static String chatMedia(String chatId) => 'chat_media/$chatId';
  static String storyImage(String uid) => 'stories/$uid/images';
  static String storyVideo(String uid) => 'stories/$uid/videos';
}

// ─── Implementation ───────────────────────────────────────────────────────────

@LazySingleton(as: StorageDataSource)
class SupabaseStorageDataSourceImpl implements StorageDataSource {
  final SupabaseClient _supabase;

  const SupabaseStorageDataSourceImpl(this._supabase);

  // ─── Upload ───────────────────────────────────────────────────────────────
  //
  //  [path] is a FOLDER path, e.g. 'profiles/<uid>'
  //  A timestamped filename is appended automatically so re-uploads never
  //  collide and old files are cleanly replaced via deleteImageByUrl first.
  //
  //  Returns the permanent public URL.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<String> uploadFile({required File file, required String path}) async {
    try {
      final ext = _safeExtension(file.path, fallback: '.jpg');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final objectPath = '$path/$fileName'; // e.g. profiles/uid/1234567890.jpg

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

  // ─── Upload Video ─────────────────────────────────────────────────────────
  //
  //  Videos go to the `videos` bucket (can be larger, separate lifecycle rules).
  //  Same path/timestamp convention as uploadFile.
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─── Delete ───────────────────────────────────────────────────────────────
  //
  //  [path] is the FULL public URL returned by a previous uploadFile call.
  //  We parse out the bucket and object path from the URL — same approach
  //  as the working SupabaseService.deleteImageByUrl.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteFile({required String path}) async {
    if (path.isEmpty) return;

    try {
      final uri = Uri.parse(path);

      // URL segments example:
      // [ 'storage', 'v1', 'object', 'public', 'images', 'profiles', 'uid', 'file.jpg' ]
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

  // ─── Helper ───────────────────────────────────────────────────────────────

  String _safeExtension(String filePath, {required String fallback}) {
    final ext = p.extension(filePath).toLowerCase();
    return ext.isNotEmpty ? ext : fallback;
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class StorageUploadException implements Exception {
  final String message;
  const StorageUploadException(this.message);

  @override
  String toString() => 'StorageUploadException: $message';
}
