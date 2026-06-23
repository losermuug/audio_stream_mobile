import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';
import 'package:streaming_app/shared/widgets/image_selector.dart';
import 'package:just_audio/just_audio.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/theme/typography.dart';
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
  String _selectedGenre = 'Хип Хоп';
  bool _hasAudio = false;

  List<int>? _audioBytes;
  String? _audioFilename;
  int _audioDurationMs = 200000;

  List<int>? _coverBytes;
  String? _coverFilename;

  bool _isPickingFile = false;

  bool _isPublishing = false;
  int _currentStep = 0;
  bool _publishSuccess = false;

  late final ProfileRepository _profileRepository;

  void _pickAudio() async {
    if (_isPickingFile) return;
    setState(() {
      _isPickingFile = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'flac', 'aac'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        List<int> bytes;
        if (kIsWeb) {
          bytes = file.bytes!;
        } else {
          bytes = file.bytes ?? File(file.path!).readAsBytesSync();
        }

        setState(() {
          _audioBytes = bytes;
          _audioFilename = file.name;
          _hasAudio = true;
        });

        try {
          final player = AudioPlayer();
          Duration? duration;
          if (kIsWeb) {
            duration = await player.setAudioSource(
              AudioSource.uri(Uri.dataFromBytes(bytes, mimeType: 'audio/mpeg')),
            );
          } else if (file.path != null) {
            duration = await player.setAudioSource(
              AudioSource.file(file.path!),
            );
          }
          if (duration != null) {
            setState(() {
              _audioDurationMs = duration!.inMilliseconds;
            });
          }
          await player.dispose();
        } catch (e) {
          debugPrint('Error getting audio duration: $e');
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(
        context,
        'Аудио файл сонгоход алдаа гарлаа: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isPickingFile = false;
      });
    }
  }



  List<String> _genres = const ['Хип Хоп', 'Поп', 'Рок', 'Инди', 'R&B'];
  bool _isLoadingGenres = false;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    if (!mounted) return;
    setState(() {
      _isLoadingGenres = true;
    });
    try {
      final dbGenres = await _profileRepository.fetchGenres();
      if (!mounted) return;
      setState(() {
        if (dbGenres.isNotEmpty) {
          _genres = dbGenres;
          if (!_genres.contains(_selectedGenre)) {
            _selectedGenre = _genres.first;
          }
        }
        _isLoadingGenres = false;
      });
    } catch (e) {
      debugPrint('Failed to load genres for publishing: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingGenres = false;
      });
    }
  }

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
    if (_audioBytes == null || _audioFilename == null) {
      CustomToast.show(
        context,
        'Дууны файл (.mp3) сонгоно уу',
        isError: true,
      );
      return;
    }
    if (_coverBytes == null || _coverFilename == null) {
      CustomToast.show(
        context,
        'Хавтасны зураг сонгоно уу',
        isError: true,
      );
      return;
    }

    setState(() {
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

      // Step 3: Performing network upload and DB registration
      setState(() {
        _currentStep = 3;
      });

      final newTrack = await _profileRepository.publishTrack(
        title: _titleController.text.trim(),
        genre: _selectedGenre,
        audioBytes: _audioBytes!,
        audioFilename: _audioFilename!,
        coverBytes: _coverBytes,
        coverFilename: _coverFilename,
        albumName: _isAlbum ? _albumNameController.text.trim() : null,
        durationMs: _audioDurationMs,
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
      });
      if (!mounted) return;
      CustomToast.show(
        context,
        e.toString().replaceAll('Exception: ', ''),
        isError: true,
      );
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
          style: AppTypography.appBarTitle,
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

            Row(
              children: [
                const Text(
                  'Дууны төрөл (Genre)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isLoadingGenres) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
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

            // File Upload Mock Cards
            Row(
              children: [
                Expanded(
                  child: MockUploadCard(
                    title: 'Аудио файл (.mp3)',
                    subtitle: _hasAudio ? _audioFilename ?? 'audio_track.mp3' : 'Дуу сонгох',
                    icon: Icons.audiotrack_rounded,
                    hasFile: _hasAudio,
                    onTap: _pickAudio,
                  ),
                ),
                const SizedBox(width: 16),
                 Expanded(
                  child: ImageSelector(
                    title: 'Хавтасны зураг',
                    subtitle: 'Зураг сонгох',
                    icon: Icons.image_rounded,
                    initialBytes: _coverBytes,
                    initialFilename: _coverFilename,
                    onImageSelected: (bytes, filename) {
                      setState(() {
                        _coverBytes = bytes;
                        _coverFilename = filename;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Error text removed and replaced by CustomToast
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
