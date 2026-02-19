import '../../core/constants/exports.dart';

class AppColorScheme {
  /// Light Theme
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    // Primary
    primary: Color(0xFF2684FC),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD7E2FF),
    onPrimaryContainer: Color(0xFF001B3F),

    // Secondary
    secondary: Color(0xFF02B091),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF73F9D6),
    onSecondaryContainer: Color(0xFF002019),

    // Tertiary
    tertiary: Color(0xFFFA00FF),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD6E3FF),
    onTertiaryContainer: Color(0xFF001B3E),

    // Error
    error: Color(0xFFB81717),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),

    // Surface
    surface: Color(0xFFF6F8FC),
    onSurface: Color(0xFF1A1E28),
    onSurfaceVariant: Color(0xFF4A4A4A),

    // Border & Outline
    outline: Color(0xFFB3B3B3),
    outlineVariant: Color(0xFFE0E0E0),

    // Shadows / Scrims
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),

    // Inverse
    inverseSurface: Color(0xFF1A1E28),
    onInverseSurface: Color(0xFFE3E2E6),
    inversePrimary: Color(0xFF1A2335),

    // Tint
    surfaceTint: Color(0xFF2684FC),

    // Surface levels (Material 3)
    surfaceBright: Color(0xFFF8F8F8),
    surfaceDim: Color(0xFFEAEAEA),

    surfaceContainer: Color(0xFFF4F4F4),
    surfaceContainerHigh: Color(0xFFEFEFEF),
    surfaceContainerHighest: Color(0xFFE6E6E6),
    surfaceContainerLow: Color(0xFFF7F7F7),
    surfaceContainerLowest: Color(0xFFFFFFFF),

    // Fixed brand colors
    primaryFixed: Color(0xFFD7E2FF),
    primaryFixedDim: Color(0xFFB0C6FF),

    secondaryFixed: Color(0xFF73F9D6),
    secondaryFixedDim: Color(0xFF48D4B4),
    onSecondaryFixed: Color(0xFF002019),

    tertiaryFixed: Color(0xFFD6E3FF),
    tertiaryFixedDim: Color(0xFFB8C7FF),
  );

  /// Dark Theme
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    // Primary
    primary: Color(0xFF2684FC),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF1A2335),
    onPrimaryContainer: Color(0xFFD7E2FF),

    // Secondary
    secondary: Color(0xFF02B091),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF0F3B34),
    onSecondaryContainer: Color(0xFF73F9D6),

    // Tertiary
    tertiary: Color(0xFFFA00FF),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF3A003C),
    onTertiaryContainer: Color(0xFFD6E3FF),

    // Error
    error: Color(0xFFB81717),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    // Surface
    surface: Color(0xFF1A1E28),
    // surface: Color(0xFF17191B),
    onSurface: Color(0xFFE3E2E6),
    onSurfaceVariant: Color(0xFFB2B2B2),

    // Border & Outline
    outline: Color(0xFF8E9099),
    outlineVariant: Color(0xFF313131),

    // Shadows / Scrims
    shadow: Color(0xFF000000),
    scrim: Color(0xFF1B1C1D),

    // Inverse
    inverseSurface: Color(0xFFF4F4F4),
    onInverseSurface: Color(0xFF181818),
    inversePrimary: Color(0xFF1A2335),

    // Tint
    surfaceTint: Color(0xFF2684FC),

    // Surface levels (Material 3)
    surfaceBright: Color(0xFF2D2D2D),
    surfaceDim: Color(0xFF111418),

    surfaceContainerLowest: Color(0xFF12151D), // app background / deepest layer
    surfaceContainerLow: Color(0xFF1A1E28), // base surface
    surfaceContainer: Color(0xFF1F2430), // slight elevation
    surfaceContainerHigh: Color(0xFF272D3A), // cards / media tiles
    surfaceContainerHighest: Color(0xFF31384A), // dialogs / sheets
    // Fixed brand colors
    primaryFixed: Color(0xFF1A2335),
    primaryFixedDim: Color(0xFF121A27),

    secondaryFixed: Color(0xFF0F3B34),
    secondaryFixedDim: Color(0xFF0A2621),

    tertiaryFixed: Color(0xFF3A003C),
    tertiaryFixedDim: Color(0xFF260026),
  );
}

extension ColorSchemeExt on ColorScheme {
  bool isLightMode() => brightness == Brightness.light;

  // Success Colors
  Color get success => const Color(0xFF27AE60);
  Color get onSuccess => const Color(0xFFFEFEFE);
  Color get successContainer => const Color(0xFFBFE9D1);
  Color get onSuccessContainer => const Color(0xFFC1FFEC);

  // Warning Colors
  Color get warning => const Color(0xFFFF9933);
  Color get onWarning => const Color(0xFFFEFEFE);
  Color get warningContainer => const Color(0xFFFFF4D6);
  Color get onWarningContainer => const Color(0xFFDC6803);

  // Disabled
  Color get surfaceDisabled =>
      isLightMode() ? const Color(0xFFD8D8D8) : const Color(0xFF2F2F2F);

  Color get onSurfaceDisabled =>
      isLightMode() ? const Color(0xFFB3B3B3) : const Color(0xFF717178);

  // Borders
  Color get border =>
      isLightMode() ? const Color(0xFFD5D5D5) : const Color(0xFF414141);

  Color get lightBorder =>
      isLightMode() ? const Color(0xFFE8E8E8) : const Color(0xFF363636);

  // Surface Variant
  Color get surfaceVariant =>
      isLightMode() ? const Color(0xFFF8F8F8) : const Color(0xFF1B1C1D);

  // Icon background colors
  Color get iconBackgroundPrimary => primary.withValues(alpha: 0.15);
  Color get iconBackgroundSecondary => secondary.withValues(alpha: 0.15);
  Color get iconBackgroundSurface => isLightMode()
      ? onSurface.withValues(alpha: 0.08)
      : surfaceContainerHighest;

  // Text opacity helpers
  Color get textPrimary => onSurface;
  Color get textSecondary => onSurface.withValues(alpha: 0.85);
  Color get textTertiary => onSurfaceVariant.withValues(alpha: 0.7);
  Color get textDisabled => onSurfaceDisabled;

  // Shimmer colors for loading states
  LinearGradient get shimmerGradient => LinearGradient(
    colors: [
      surfaceContainerHigh,
      surfaceContainerHighest,
      surfaceContainerHigh,
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
  );
}
