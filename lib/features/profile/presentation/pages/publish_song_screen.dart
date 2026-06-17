import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/features/profile/presentation/widgets/publish_selector_card.dart';
import 'package:streaming_app/features/profile/presentation/widgets/mock_upload_card.dart';
import 'package:streaming_app/features/profile/presentation/widgets/publishing_progress_view.dart';
import 'package:streaming_app/features/profile/presentation/widgets/publish_success_view.dart';
import 'package:streaming_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:streaming_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:streaming_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';

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

  late final ProfileRepository _profileRepository;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
  }

  final List<String> _genres = ['Хип Хоп', 'Поп', 'Рок', 'Инди', 'R&B'];

  final List<String> _publishSteps = [
    'Холболтыг бэлдэж байна...',
    'Уран бүтээлчийн мэдээллийг татаж байна...',
    'Аудио файлыг сервер рүү илгээж байна...',
    'Өгөгдлийн санд шинэ бичилт үүсгэж байна...',
    'Дуу амжилттай цацагдлаа!',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _albumNameController.dispose();
    super.dispose();
  }

  void _startPublishing() async {
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

    try {
      // Step 1: Initialize connection
      setState(() {
        _currentStep = 1;
      });

      // Step 2: Prepare payload
      setState(() {
        _currentStep = 2;
      });

      final List<int> dummyAudioBytes = List.filled(50000, 0);
      final filename = 'device_track_${DateTime.now().millisecondsSinceEpoch}.mp3';

      // Step 3: Performing network upload and DB registration
      setState(() {
        _currentStep = 3;
      });

      final newTrack = await _profileRepository.publishTrack(
        title: _titleController.text.trim(),
        genre: _selectedGenre,
        audioBytes: dummyAudioBytes,
        filename: filename,
      );

      setState(() {
        _currentStep = 4;
        _publishSuccess = true;
        _isPublishing = false;
      });

      if (widget.onTrackPublished != null) {
        widget.onTrackPublished!(newTrack);
      }
    } catch (e) {
      setState(() {
        _isPublishing = false;
        _fileError = e.toString().replaceAll('Exception: ', '');
      });
    }
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
      return PublishSuccessView(
        trackTitle: _titleController.text.trim(),
        isAlbum: _isAlbum,
        albumName: _albumNameController.text.trim(),
        selectedGenre: _selectedGenre,
        isExplicit: _isExplicit,
        onBackPressed: () => Navigator.pop(context),
      );
    }
    if (_isPublishing) {
      return PublishingProgressView(
        currentStep: _currentStep,
        steps: _publishSteps,
      );
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
                  child: PublishSelectorCard(
                    title: 'Сингл (Single)',
                    subtitle: 'Ганц дуу',
                    icon: Icons.music_note_rounded,
                    isSelected: !_isAlbum,
                    onTap: () => setState(() => _isAlbum = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PublishSelectorCard(
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
                  child: MockUploadCard(
                    title: 'Аудио файл (.mp3)',
                    subtitle: _hasAudio ? 'audio_track.mp3' : 'Дуу сонгох',
                    icon: Icons.audiotrack_rounded,
                    hasFile: _hasAudio,
                    onTap: () => setState(() => _hasAudio = !_hasAudio),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MockUploadCard(
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


}
