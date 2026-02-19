import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class PickFile {
  static final picker = ImagePicker();

  static Future<File?> media() async {
    final media = await picker.pickMedia();
    if (media != null) return File(media.path);
    return null;
  }

  static Future<File?> image({ImageSource? source}) async {
    final media = await picker.pickImage(
      source: source ?? ImageSource.gallery,
      imageQuality: 50,
    );
    if (media != null) return File(media.path);
    return null;
  }

  static Future<List<File>> multiImage() async {
    final files = await picker.pickMultiImage(imageQuality: 50);
    return files.map((item) => File(item.path)).toList();
  }

  static Future<File?> video() async {
    final media = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (media != null) return File(media.path);
    return null;
  }

  static Future<File?> pickFile({
    FileType type = FileType.custom,
    bool allowMultiple = false,
    List<String> extensions = const ['pdf', 'doc', 'txt', 'tiff'],
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: type,
      allowedExtensions: extensions,
    );
    if (result != null) {
      File file = File(result.paths[0]!);
      return file;
    }
    return null;
  }

  static Future<List<File>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      return result.paths.map((item) => File('$item')).toList();
    }
    return [];
  }
}
