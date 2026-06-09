import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';

class PublishSongScreen extends StatefulWidget {
  final Function(Track)? onTrackPublished;

  const PublishSongScreen({
    super.key,
    this.onTrackPublished,
  });

  @override
  State<PublishSongScreen> createState() => _PublishSongScreenState();
}

class _PublishSongScreenState extends State<PublishSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _albumNameController = TextEditingController();

  bool _isAlbum = false; // false = Single, true = Album
  bool _isExplicit = false;
  String _selectedGenre = 'Хип Хоп';
  bool _hasAudio = false;
  bool _hasCover = false;
  String? _fileError;

  bool _isPublishing = false;
  int _currentStep = 0;
  bool _publishSuccess = false;

  final List<String> _genres = ['Хип Хоп', 'Поп', 'Рок', 'Инди', 'R&B'];

  final List<String> _publishSteps = [
    'UUID үүсгэж байна... (uuid_generate_v4())',
    'Уран бүтээлчийн artists.id холбож байна... (FK check)',
    'tracks.audio_url хадгалах сан руу хуулж байна... (S3 upload)',
    'tracks.cover_url цомгийн зургийг байршуулж байна...',
    'tracks.is_published = true өөрчлөлтийг хийж байна...',
    'Өгөгдлийн санд шинэ бичилт амжилттай үүсгэгдлээ!',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _albumNameController.dispose();
    super.dispose();
  }

  void _startPublishing() {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasAudio || !_hasCover) {
      setState(() {
        _fileError = 'Дууны файл болон хавтасны зургийг сонгоно уу';
      });
      return;
    }

    setState(() {
      _fileError = null;
      _isPublishing = true;
      _currentStep = 0;
      _publishSuccess = false;
    });

    // Simulate database transaction step-by-step
    Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentStep < _publishSteps.length - 1) {
          _currentStep++;
        } else {
          timer.cancel();
          _publishSuccess = true;

          // Generate new track
          final newTrack = Track(
            id: 'tr_${DateTime.now().millisecondsSinceEpoch}',
            title: _titleController.text.trim(),
            artist: 'Анужин', // Logged in User/Artist
            duration: '3:20',
            gradientColors: const [
              Color(0xFF1A1A1A),
              Color(0xFF333333),
            ],
            isLiked: false,
            imagePath: null, // default music note icon
          );

          // Insert into global MockData so it shows in Home & Search
          MockData.recentlyPlayed.insert(0, newTrack);

          if (widget.onTrackPublished != null) {
            widget.onTrackPublished!(newTrack);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isPublishing ? 'Цацаж байна' : 'Уран бүтээл цацах',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_publishSuccess) {
      return _buildSuccessView();
    }
    if (_isPublishing) {
      return _buildPublishingProgressView();
    }
    return _buildFormView();
  }

  // ──────────────────────────────────────────────
  //  Form View
  // ──────────────────────────────────────────────
  Widget _buildFormView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track Title
            CustomTextField(
              hintText: 'Дууны нэр оруулна уу',
              labelText: 'Дууны нэр',
              controller: _titleController,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Дууны нэрийг оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Album Type Selection
            const Text(
              'Цомгийн төрөл',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSelectorCard(
                    title: 'Сингл (Single)',
                    subtitle: 'Ганц дуу',
                    icon: Icons.music_note_rounded,
                    isSelected: !_isAlbum,
                    onTap: () => setState(() => _isAlbum = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectorCard(
                    title: 'Цомог (Album)',
                    subtitle: 'Олон дууны цомог',
                    icon: Icons.album_rounded,
                    isSelected: _isAlbum,
                    onTap: () => setState(() => _isAlbum = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Album Name (Conditional)
            if (_isAlbum) ...[
              CustomTextField(
                hintText: 'Цомгийн нэр оруулна уу',
                labelText: 'Цомгийн нэр',
                controller: _albumNameController,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Цомгийн нэрийг оруулна уу';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],

            // Genre Selector
            const Text(
              'Дууны төрөл (Genre)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _genres.length,
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = _selectedGenre == genre;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGenre = genre),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.white : AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: isSelected ? AppColors.black : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Explicit Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Насны хязгаартай (Explicit)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Дуунд зохисгүй үг хэллэг орсон эсэх',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isExplicit,
                    onChanged: (val) => setState(() => _isExplicit = val),
                    activeThumbColor: AppColors.white,
                    activeTrackColor: AppColors.grey500,
                    inactiveThumbColor: AppColors.grey700,
                    inactiveTrackColor: AppColors.grey900,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // File Upload Mock Cards
            Row(
              children: [
                Expanded(
                  child: _buildMockUploadCard(
                    title: 'Аудио файл (.mp3)',
                    subtitle: _hasAudio ? 'audio_track.mp3' : 'Дуу сонгох',
                    icon: Icons.audiotrack_rounded,
                    hasFile: _hasAudio,
                    onTap: () => setState(() => _hasAudio = !_hasAudio),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMockUploadCard(
                    title: 'Хавтасны зураг',
                    subtitle: _hasCover ? 'cover_art.png' : 'Зураг сонгох',
                    icon: Icons.image_rounded,
                    hasFile: _hasCover,
                    onTap: () => setState(() => _hasCover = !_hasCover),
                  ),
                ),
              ],
            ),

            if (_fileError != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _fileError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 40),

            // Submit Release Button
            ElevatedButton(
              onPressed: _startPublishing,
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
                'Цацах (Publish)',
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

  Widget _buildSelectorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.white : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.white : AppColors.iconDefault,
              size: 24,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool hasFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? AppColors.white : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline_rounded : icon,
              color: hasFile ? AppColors.white : AppColors.iconDefault,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: hasFile ? AppColors.textSecondary : AppColors.textTertiary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Publishing Progress View
  // ──────────────────────────────────────────────
  Widget _buildPublishingProgressView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.white,
                  backgroundColor: AppColors.borderSubtle,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Өгөгдлийн санд шинэ бичилт хийж байна',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Display transactions steps progress
            ...List.generate(_publishSteps.length, (index) {
              final isDone = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : isCurrent
                              ? Icons.sync_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: isDone || isCurrent ? AppColors.white : AppColors.grey700,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _publishSteps[index],
                        style: TextStyle(
                          color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Success View
  // ──────────────────────────────────────────────
  Widget _buildSuccessView() {
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
                  _buildSuccessDetailRow('Дууны нэр:', _titleController.text.trim()),
                  _buildSuccessDetailRow('Уран бүтээлч:', 'Анужин'),
                  _buildSuccessDetailRow('Төрөл:', _isAlbum ? 'Цомог (Album)' : 'Сингл (Single)'),
                  if (_isAlbum) _buildSuccessDetailRow('Цомгийн нэр:', _albumNameController.text.trim()),
                  _buildSuccessDetailRow('Дууны төрөл:', _selectedGenre),
                  _buildSuccessDetailRow('Хязгаарлалт:', _isExplicit ? 'Explicit (18+)' : 'Тохиромжтой'),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Back button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
