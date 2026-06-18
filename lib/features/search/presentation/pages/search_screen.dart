import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/home/domain/track.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/shared/widgets/gradient_album_art.dart';
import 'package:streaming_app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:streaming_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:streaming_app/features/search/domain/repositories/search_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Search genre categories with color identity
// ─────────────────────────────────────────────────────────────────────────────

class _Genre {
  final String name;
  final Color colorA;
  final Color colorB;
  final IconData icon;

  const _Genre({
    required this.name,
    required this.colorA,
    required this.colorB,
    required this.icon,
  });
}

const List<_Genre> _genres = [
  _Genre(
    name: 'Поп',
    colorA: Color(0xFF8E2DE2),
    colorB: Color(0xFF4A00E0),
    icon: Icons.star_rounded,
  ),
  _Genre(
    name: 'Хип-хоп',
    colorA: Color(0xFF1A1A2E),
    colorB: Color(0xFFE94560),
    icon: Icons.graphic_eq_rounded,
  ),
  _Genre(
    name: 'Рок',
    colorA: Color(0xFF2C3E50),
    colorB: Color(0xFFE74C3C),
    icon: Icons.electric_bolt_rounded,
  ),
  _Genre(
    name: 'Жазз',
    colorA: Color(0xFF1A472A),
    colorB: Color(0xFF2ECC71),
    icon: Icons.piano_rounded,
  ),
  _Genre(
    name: 'Акустик',
    colorA: Color(0xFF4A2F00),
    colorB: Color(0xFFD4A017),
    icon: Icons.music_note_rounded,
  ),
  _Genre(
    name: 'Лофи',
    colorA: Color(0xFF0D2137),
    colorB: Color(0xFF1B6CA8),
    icon: Icons.headphones_rounded,
  ),
  _Genre(
    name: 'Кино',
    colorA: Color(0xFF2D132C),
    colorB: Color(0xFFEE4540),
    icon: Icons.movie_rounded,
  ),
  _Genre(
    name: 'Электрон',
    colorA: Color(0xFF0F0C29),
    colorB: Color(0xFF24243E),
    icon: Icons.flash_on_rounded,
  ),
];


// ─────────────────────────────────────────────────────────────────────────────
//  Search Screen
// ─────────────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  final void Function(Track track)? onTrackSelected;

  const SearchScreen({super.key, this.onTrackSelected});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final SearchRepository _searchRepository;
  Timer? _debounceTimer;

  String _query = '';
  List<Track> _results = [];
  bool _isSearching = false;

  late final AnimationController _entryController;
  late final Animation<double> _barFade;
  late final Animation<Offset> _barSlide;
  late final Animation<double> _gridFade;
  late final Animation<Offset> _gridSlide;

  @override
  void initState() {
    super.initState();
    _searchRepository = SearchRepositoryImpl(
      remoteDataSource: SearchRemoteDataSource(
        client: ApiClient(),
      ),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _barFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _barSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _gridFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOut),
      ),
    );
    _gridSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();

    _searchController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final q = _searchController.text.trim();
    setState(() {
      _query = q;
      _isSearching = q.isNotEmpty;
    });

    _debounceTimer?.cancel();
    if (q.isEmpty) {
      setState(() {
        _results = [];
      });
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 350), () {
        _performSearch(q);
      });
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchRepository.searchTracks(query);
      if (_query == query && mounted) {
        setState(() {
          _results = results;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _entryController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            SlideTransition(
              position: _barSlide,
              child: FadeTransition(
                opacity: _barFade,
                child: _buildSearchBar(),
              ),
            ),

            // ── Body — genre grid OR results ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isSearching
                    ? _buildResults()
                    : SlideTransition(
                        position: _gridSlide,
                        child: FadeTransition(
                          opacity: _gridFade,
                          child: _buildGenreGrid(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Search bar
  // ──────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Хайх',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          CustomTextField(
            hintText: 'Дуу, уран бүтээлч хайх...',
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          key: const ValueKey('clear'),
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.grey700,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('empty')),
            ),
            onChanged: (_) {}, // listener handles it
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Genre grid
  // ──────────────────────────────────────────────

  Widget _buildGenreGrid() {
    return CustomScrollView(
      key: const ValueKey('genre_grid'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Жанраар хайх',
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 160),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final genre = _genres[index];
                return _GenreCard(
                  genre: genre,
                  onTap: () {
                    _searchController.text = genre.name;
                    _debounceTimer?.cancel();
                    _performSearch(genre.name);
                  },
                );
              },
              childCount: _genres.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  //  Search results list
  // ──────────────────────────────────────────────

  Widget _buildResults() {
    if (_results.isEmpty) {
      return _buildEmptyResults();
    }

    return CustomScrollView(
      key: const ValueKey('results'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${_results.length} үр дүн',
              style: TextStyle(
                color: AppColors.textTertiary.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = _results[index];
                return _SearchResultTile(
                  track: track,
                  query: _query,
                  onTap: () {
                    widget.onTrackSelected?.call(track);
                    _focusNode.unfocus();
                  },
                );
              },
              childCount: _results.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      key: const ValueKey('empty_results'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.iconMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '"$_query"',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'гэсэн үр дүн олдсонгүй',
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Genre card widget
// ─────────────────────────────────────────────────────────────────────────────

class _GenreCard extends StatefulWidget {
  final _Genre genre;
  final VoidCallback? onTap;
  const _GenreCard({required this.genre, this.onTap});

  @override
  State<_GenreCard> createState() => _GenreCardState();
}

class _GenreCardState extends State<_GenreCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [widget.genre.colorA, widget.genre.colorB],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Subtle noise texture via decorative circles
              Positioned(
                right: -14,
                bottom: -14,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: -10,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.genre.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Icon(
                      widget.genre.icon,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search result tile widget
// ─────────────────────────────────────────────────────────────────────────────

class _SearchResultTile extends StatefulWidget {
  final Track track;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.track,
    required this.query,
    required this.onTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.grey900
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              // Gradient album art thumbnail
              GradientAlbumArt(
                size: 52,
                borderRadius: 10,
                gradientColors: widget.track.gradientColors,
                iconSize: 20,
                imagePath: widget.track.imagePath,
                boxShadow: [
                  BoxShadow(
                    color: widget.track.gradientColors.last
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Track info with highlighted query match
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: widget.track.title,
                      query: widget.query,
                      baseStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                      highlightStyle: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        backgroundColor: Color(0x22FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 3),
                    _HighlightedText(
                      text: widget.track.artist,
                      query: widget.query,
                      baseStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      highlightStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Duration
              Text(
                widget.track.duration,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),

              // Play icon
              Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.iconMuted.withValues(alpha: 0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper — highlights matching substrings in search results
// ─────────────────────────────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(qLower, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: highlightStyle,
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
