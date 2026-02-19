import 'dart:io';

import 'package:chatty/core/constants/pngs.dart';
import 'package:chatty/core/di/injectable.dart';
import 'package:chatty/core/framework/app_preferance.dart';
import 'package:flutter/material.dart';

class ChatBackGround extends StatelessWidget {
  final Widget child;
  const ChatBackGround({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<AppPreferences>();
    final wallpaperPath = prefs.chatWallpaperPath;
    final brightness = prefs.chatWallpaperBrightness;

    // Default to first preset if none saved
    final effectivePath =
        wallpaperPath.isEmpty ? Pngs.defaultChatWallpaper : wallpaperPath;

    // Determine if it's an asset or a file
    final isAsset = effectivePath.startsWith('assets/') ||
        effectivePath.contains('png') && !effectivePath.startsWith('/');

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isAsset
              ? AssetImage(effectivePath)
              : FileImage(File(effectivePath)) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Overlay darkness: 0.0 = fully transparent (bright), 1.0 = fully opaque (dark)
        color: Colors.black.withValues(alpha: brightness),
        child: child,
      ),
    );
  }
}