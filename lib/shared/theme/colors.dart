import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Absolute black — primary background (dark mode base)
  static const Color black = Color(0xFF000000);

  /// Near black — card / surface backgrounds
  static const Color blackSurface = Color(0xFF0A0A0A);

  /// Deep charcoal — elevated surfaces, modals
  static const Color blackElevated = Color(0xFF141414);

  /// Dark grey — secondary surfaces, bottom sheets
  static const Color grey900 = Color(0xFF1A1A1A);

  /// Medium-dark grey — dividers, inactive tracks
  static const Color grey800 = Color(0xFF262626);

  /// Mid grey — disabled states, borders
  static const Color grey700 = Color(0xFF333333);

  /// Neutral grey — placeholder text, muted icons
  static const Color grey500 = Color(0xFF737373);

  /// Light-medium grey — secondary text
  static const Color grey400 = Color(0xFF9E9E9E);

  /// Soft grey — tertiary text, subtle labels
  static const Color grey300 = Color(0xFFBDBDBD);

  /// Near white — secondary foreground, subtitles
  static const Color grey100 = Color(0xFFE8E8E8);

  /// Absolute white — primary foreground, headlines, icons
  static const Color white = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  //  ACCENT — Minimal Warm White (Anti-Sterile)
  // ─────────────────────────────────────────────

  /// Warm white — for waveform highlights, active elements
  /// Slightly warmer than pure white to avoid clinical feel
  static const Color warmWhite = Color(0xFFF5F0EB);

  /// Off-white — album art placeholder, soft glows
  static const Color offWhite = Color(0xFFF0EEEC);

  // ─────────────────────────────────────────────
  //  SEMANTIC — UI States
  // ─────────────────────────────────────────────

  /// Active / playing — pure white (maximum contrast on black)
  static const Color active = white;

  /// Inactive / paused — muted grey
  static const Color inactive = grey500;

  /// Selected track highlight
  static const Color selected = grey800;

  /// Pressed / tap feedback
  static const Color pressed = grey700;

  /// Focus ring (accessibility)
  static const Color focus = grey300;

  // ─────────────────────────────────────────────
  //  SURFACES
  // ─────────────────────────────────────────────

  /// App scaffold background
  static const Color background = black;

  /// Card surface (track cards, playlist items)
  static const Color cardBackground = blackSurface;

  /// Elevated card (featured album, hero card)
  static const Color cardElevated = blackElevated;

  /// Bottom navigation bar
  static const Color navBarBackground = grey900;

  /// Mini player background
  static const Color miniPlayerBackground = grey900;

  /// Full-screen player background
  static const Color playerBackground = black;

  /// Modal / bottom sheet background
  static const Color modalBackground = blackElevated;

  /// Input field background
  static const Color inputBackground = grey800;

  // ─────────────────────────────────────────────
  //  TEXT
  // ─────────────────────────────────────────────

  /// Primary text — track title, album name
  static const Color textPrimary = white;

  /// Secondary text — artist name, duration
  static const Color textSecondary = grey300;

  /// Tertiary text — genre tags, metadata
  static const Color textTertiary = grey500;

  /// Disabled text
  static const Color textDisabled = grey700;

  /// Placeholder text in search / inputs
  static const Color textPlaceholder = grey500;

  // ─────────────────────────────────────────────
  //  ICONS
  // ─────────────────────────────────────────────

  /// Active icon (play, like, current tab)
  static const Color iconActive = white;

  /// Default icon
  static const Color iconDefault = grey400;

  /// Muted / disabled icon
  static const Color iconMuted = grey700;

  // ─────────────────────────────────────────────
  //  BORDERS & DIVIDERS
  // ─────────────────────────────────────────────

  /// Subtle divider between list items
  static const Color divider = grey800;

  /// Card border — barely-there stroke
  static const Color borderSubtle = grey800;

  /// Focused input border
  static const Color borderFocused = grey500;

  /// Strong border for outlined buttons
  static const Color borderStrong = grey700;

  // ─────────────────────────────────────────────
  //  PLAYBACK — Waveform & Progress
  // ─────────────────────────────────────────────

  /// Played portion of seek bar / waveform
  static const Color waveformPlayed = white;

  /// Unplayed portion of seek bar / waveform
  static const Color waveformUnplayed = grey700;

  /// Seek thumb
  static const Color seekThumb = white;

  /// Buffered portion
  static const Color waveformBuffered = grey500;

  // ─────────────────────────────────────────────
  //  OVERLAYS & SCRIM
  // ─────────────────────────────────────────────

  /// Dark scrim over album art (for text legibility)
  static const Color scrimDark = Color(0xB3000000); // 70% black

  /// Light scrim — subtle gradient
  static const Color scrimLight = Color(0x33000000); // 20% black

  /// Album art overlay gradient — bottom fade
  static const LinearGradient albumGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
    colors: [
      Color(0x00000000), // transparent
      Color(0x66000000), // 40% black
      Color(0xCC000000), // 80% black
    ],
  );

  // ─────────────────────────────────────────────
  //  SPECIAL EFFECTS
  // ─────────────────────────────────────────────

  /// Glow effect around active/playing elements (white soft glow)
  static const Color glow = Color(0x1AFFFFFF); // 10% white

  /// Strong glow for now-playing indicator
  static const Color glowStrong = Color(0x33FFFFFF); // 20% white

  /// Shimmer base for loading skeletons
  static const Color shimmerBase = grey800;

  /// Shimmer highlight
  static const Color shimmerHighlight = grey700;

  // ─────────────────────────────────────────────
  //  STATUS — Minimal (no bright colors)
  // ─────────────────────────────────────────────

  /// Error — red accent
  static const Color error = Color(0xFFFF3333);

  /// Error background
  static const Color errorBackground = grey900;

  /// Success (e.g. track added to playlist)
  static const Color success = grey300;

  // ─────────────────────────────────────────────
  //  MATERIAL THEME HELPERS
  // ─────────────────────────────────────────────

  /// Primary ColorScheme for ThemeData
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: white,
    onPrimary: black,
    secondary: grey300,
    onSecondary: black,
    surface: blackSurface,
    onSurface: white,
    error: error,
    onError: black,
  );

  /// Full ThemeData — plug into MaterialApp
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: background,
        cardColor: cardBackground,
        dividerColor: divider,
        iconTheme: const IconThemeData(color: iconDefault),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          displayMedium: TextStyle(color: textPrimary),
          displaySmall: TextStyle(color: textPrimary),
          headlineLarge: TextStyle(color: textPrimary),
          headlineMedium: TextStyle(color: textPrimary),
          headlineSmall: TextStyle(color: textPrimary),
          titleLarge: TextStyle(color: textPrimary),
          titleMedium: TextStyle(color: textPrimary),
          titleSmall: TextStyle(color: textSecondary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textTertiary),
          labelLarge: TextStyle(color: textPrimary),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textTertiary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: navBarBackground,
          selectedItemColor: iconActive,
          unselectedItemColor: iconMuted,
          elevation: 0,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: waveformPlayed,
          inactiveTrackColor: waveformUnplayed,
          thumbColor: seekThumb,
          overlayColor: glowStrong,
          trackHeight: 2.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: inputBackground,
          filled: true,
          hintStyle: TextStyle(color: textPlaceholder),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderSubtle),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderFocused),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        useMaterial3: true,
      );
}