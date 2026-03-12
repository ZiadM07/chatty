import 'dart:io';

import 'package:Chatty/core/constants/pngs.dart';
import 'package:Chatty/core/di/injectable.dart';
import 'package:Chatty/core/framework/app_preferance.dart';
import 'package:flutter/material.dart';

class ChatBackGround extends StatelessWidget {
  final Widget child;
  const ChatBackGround({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<AppPreferences>();
    final wallpaperPath = prefs.chatWallpaperPath;
    final brightness = prefs.chatWallpaperBrightness;

    final effectivePath = wallpaperPath.isEmpty
        ? Pngs.defaultChatWallpaper
        : wallpaperPath;

    final isAsset =
        effectivePath.startsWith('assets/') ||
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
        color: Colors.black.withValues(alpha: brightness),
        child: child,
      ),
    );
  }
}
