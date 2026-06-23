import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class AppTypography {
  AppTypography._();

  /// Standard style for main screen page headers (Search, Library, Profile)
  static const TextStyle screenTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  /// Standard style for sub-screen AppBars (Edit Profile, Change Password, Publish Song)
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
