import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';

class PublishSuccessView extends StatelessWidget {
  final String trackTitle;
  final bool isAlbum;
  final String albumName;
  final String selectedGenre;
  final VoidCallback onBackPressed;

  const PublishSuccessView({
    super.key,
    required this.trackTitle,
    required this.isAlbum,
    required this.albumName,
    required this.selectedGenre,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Vinyl Disk Outline
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white.withValues(alpha: 0.15), width: 3),
              ),
              child: const Center(
                child: Icon(
                  Icons.album_rounded,
                  color: AppColors.white,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Амжилттай цацагдлаа!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // Released metadata detail box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildSuccessDetailRow('Дууны нэр:', trackTitle),
                  _buildSuccessDetailRow('Уран бүтээлч:', 'Мөнхзул'),
                  _buildSuccessDetailRow('Төрөл:', isAlbum ? 'Цомог (Album)' : 'Сингл (Single)'),
                  if (isAlbum) _buildSuccessDetailRow('Цомгийн нэр:', albumName),
                  _buildSuccessDetailRow('Дууны төрөл:', selectedGenre),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Back button
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Нүүр хуудас руу буцах',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
