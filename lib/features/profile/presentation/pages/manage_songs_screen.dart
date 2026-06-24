import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/theme/typography.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/shared/widgets/gradient_album_art.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:streaming_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:streaming_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/features/profile/presentation/pages/publish_song_screen.dart';

class ManageSongsScreen extends StatefulWidget {
  const ManageSongsScreen({super.key});

  @override
  State<ManageSongsScreen> createState() => _ManageSongsScreenState();
}

class _ManageSongsScreenState extends State<ManageSongsScreen> {
  late final ProfileRepository _profileRepository;
  bool _isLoading = true;
  List<Track> _myTracks = [];
  List<String> _allGenres = const ['Хип Хоп', 'Поп', 'Рок', 'Инди', 'R&B'];

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final tracks = await _profileRepository.fetchMyTracks();
      final genres = await _profileRepository.fetchGenres();
      if (mounted) {
        setState(() {
          _myTracks = tracks;
          if (genres.isNotEmpty) {
            _allGenres = genres;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomToast.show(
          context,
          'Дуунуудыг ачаалахад алдаа гарлаа: $e',
          isError: true,
        );
      }
    }
  }

  void _showDeleteConfirmation(Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.7),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.modalBackground.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border.all(
                  color: AppColors.borderSubtle.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFFF5252),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '"${track.title}" устгах уу?',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Энэ дууг устгаснаар та дахин сэргээх боломжгүй болно.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: AppColors.borderStrong,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Үгүй',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            _executeDelete(track);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5252),
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Устгах',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _executeDelete(Track track) async {
    setState(() => _isLoading = true);
    try {
      final success = await _profileRepository.deleteTrack(track.id);
      if (success) {
        if (mounted) {
          CustomToast.show(context, 'Дууг амжилттай устгалаа');
        }
      } else {
        if (mounted) {
          CustomToast.show(context, 'Дууг устгаж чадсангүй', isError: true);
        }
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomToast.show(context, 'Алдаа гарлаа: $e', isError: true);
      }
    }
  }

  void _showEditSheet(Track track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.7),
      builder: (context) {
        return _EditTrackSheet(
          track: track,
          allGenres: _allGenres,
          repository: _profileRepository,
          onSaveSuccess: () {
            Navigator.pop(context);
            _loadData();
          },
        );
      },
    );
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
        title: const Text(
          'Миний дуунууд',
          style: AppTypography.appBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublishSongScreen(
                onTrackPublished: (_) => _loadData(),
              ),
            ),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.white,
        backgroundColor: AppColors.cardBackground,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : _myTracks.isEmpty
                ? _buildEmptyState()
                : _buildTrackList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: AppColors.textTertiary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Нийтэлсэн дуу одоогоор байхгүй байна',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 8),
            // const Text(
            //   'Та өөрийн бүтээсэн дуугаа цацаж, эндээс сонсогчдын хандалт, статистикийг хянах боломжтой.',
            //   style: TextStyle(
            //     color: AppColors.textSecondary,
            //     fontSize: 13,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PublishSongScreen(
                      onTrackPublished: (_) => _loadData(),
                    ),
                  ),
                ).then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text(
                'Дуу нийтлэх',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
      itemCount: _myTracks.length,
      itemBuilder: (context, index) {
        final track = _myTracks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GradientAlbumArt(
                  size: 56,
                  borderRadius: 10,
                  gradientColors: track.gradientColors,
                  imagePath: track.imagePath,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              track.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusTag(track.isPublished),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.genres.isNotEmpty
                            ? track.genres.join(', ')
                            : 'Төрөлгүй',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${track.playCount}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.favorite_border_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${track.likeCount}',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            track.duration,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  color: AppColors.modalBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.borderSubtle,
                      width: 0.5,
                    ),
                  ),
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditSheet(track);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(track);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.white),
                          SizedBox(width: 10),
                          Text(
                            'Засах',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF5252)),
                          SizedBox(width: 10),
                          Text(
                            'Устгах',
                            style: TextStyle(color: Color(0xFFFF5252), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublished
            ? const Color(0xFF00E676).withValues(alpha: 0.12)
            : AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPublished ? 'Нийтэлсэн' : 'Ноорог',
        style: TextStyle(
          color: isPublished ? const Color(0xFF00E676) : AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EditTrackSheet extends StatefulWidget {
  final Track track;
  final List<String> allGenres;
  final ProfileRepository repository;
  final VoidCallback onSaveSuccess;

  const _EditTrackSheet({
    required this.track,
    required this.allGenres,
    required this.repository,
    required this.onSaveSuccess,
  });

  @override
  State<_EditTrackSheet> createState() => _EditTrackSheetState();
}

class _EditTrackSheetState extends State<_EditTrackSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late String _selectedGenre;
  late bool _isPublished;
  bool _isSaving = false;

  List<int>? _newCoverBytes;
  String? _newCoverFilename;
  bool _isPickingCover = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.track.title);
    _isPublished = widget.track.isPublished;
    
    // Pick the track's first genre if available, else hip hop
    if (widget.track.genres.isNotEmpty && widget.allGenres.contains(widget.track.genres.first)) {
      _selectedGenre = widget.track.genres.first;
    } else if (widget.allGenres.isNotEmpty) {
      _selectedGenre = widget.allGenres.first;
    } else {
      _selectedGenre = 'Хип Хоп';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingCover) return;
    setState(() => _isPickingCover = true);
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
          _newCoverBytes = bytes;
          _newCoverFilename = image.name;
        });
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
        setState(() => _isPickingCover = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? coverUrl;
      if (_newCoverBytes != null && _newCoverFilename != null) {
        // Upload cover first
        coverUrl = await widget.repository.uploadCoverImage(_newCoverBytes!, _newCoverFilename!);
      }

      await widget.repository.updateTrack(
        id: widget.track.id,
        title: _titleController.text.trim(),
        isPublished: _isPublished,
        genres: [_selectedGenre],
        coverUrl: coverUrl,
      );

      widget.onSaveSuccess();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        CustomToast.show(
          context,
          'Алдаа гарлаа: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 24 + bottomInset,
          ),
          decoration: BoxDecoration(
            color: AppColors.modalBackground.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Дуу засах',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cover Art Selection / Preview
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: _newCoverBytes != null
                                ? Image.memory(
                                    Uint8List.fromList(_newCoverBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : GradientAlbumArt(
                                    size: 100,
                                    borderRadius: 15,
                                    gradientColors: widget.track.gradientColors,
                                    imagePath: widget.track.imagePath,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Text Field
                  CustomTextField(
                    hintText: 'Дууны нэр оруулна уу',
                    labelText: 'Дууны нэр',
                    controller: _titleController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Дууны нэрийг оруулна уу';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

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
                      itemCount: widget.allGenres.length,
                      itemBuilder: (context, index) {
                        final genre = widget.allGenres[index];
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

                  // Status Toggle (SwitchTile)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtle.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: SwitchListTile(
                      activeThumbColor: AppColors.white,
                      activeTrackColor: const Color(0xFF00E676),
                      inactiveThumbColor: AppColors.grey500,
                      inactiveTrackColor: AppColors.grey700,
                      title: const Text(
                        'Нийтлэх (Publish)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Сонсогчдод харагдах эсэх',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: _isPublished,
                      onChanged: (val) {
                        setState(() {
                          _isPublished = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: AppColors.borderStrong,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Цуцлах',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                                  ),
                                )
                              : const Text(
                                  'Хадгалах',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
