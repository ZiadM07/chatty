import 'dart:io';

import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

class Multipart {
  static Future<List<MultipartFile>> prepareFiles(List<File> files) async {
    return files.map((file) {
      final filename = file.path.split(Platform.pathSeparator).last;
      final mimeType = _getMimeType(file.path);

      return MultipartFile.fromFileSync(
        file.path,
        filename: filename,
        contentType: mimeType,
      );
    }).toList();
  }

  static MediaType _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'webp':
        return MediaType('image', 'webp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'svg':
        return MediaType('image', 'svg+xml');
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'webm':
      case 'mkv':
      case 'flv':
      case 'wmv':
      case '3gp':
        return MediaType('video', 'mp4');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  static bool isVideo(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'heic':
      case 'svg':
        return false;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'webm':
      case 'mkv':
      case 'flv':
      case 'wmv':
      case '3gp':
        return true;
      default:
        return false;
    }
  }
}
