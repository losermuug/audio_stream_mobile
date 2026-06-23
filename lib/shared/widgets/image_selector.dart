import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class ImageSelector extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<int>? initialBytes;
  final String? initialFilename;
  final Function(List<int>? bytes, String? filename) onImageSelected;
  final double height;

  const ImageSelector({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.initialBytes,
    this.initialFilename,
    required this.onImageSelected,
    this.height = 115,
  });

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  List<int>? _bytes;
  String? _filename;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _bytes = widget.initialBytes;
    _filename = widget.initialFilename;
  }

  @override
  void didUpdateWidget(covariant ImageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBytes != oldWidget.initialBytes) {
      setState(() {
        _bytes = widget.initialBytes;
        _filename = widget.initialFilename;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _bytes = bytes;
          _filename = image.name;
        });
        widget.onImageSelected(bytes, image.name);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          'Зураг сонгоход алдаа гарлаа: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _clearImage() {
    setState(() {
      _bytes = null;
      _filename = null;
    });
    widget.onImageSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFile = _bytes != null;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.white : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (hasFile)
              Positioned.fill(
                child: Image.memory(
                  Uint8List.fromList(_bytes!),
                  fit: BoxFit.cover,
                ),
              ),
            if (hasFile)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasFile ? Icons.check_circle_outline_rounded : widget.icon,
                      color: hasFile ? AppColors.white : AppColors.iconDefault,
                      size: 28,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasFile ? (_filename ?? 'cover.png') : widget.subtitle,
                      style: TextStyle(
                        color: hasFile ? AppColors.textSecondary : AppColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (hasFile)
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _clearImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
