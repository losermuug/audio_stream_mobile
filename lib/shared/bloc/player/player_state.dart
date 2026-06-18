import 'package:streaming_app/features/home/domain/track.dart';

class PlayerState {
  final Track? currentTrack;
  final bool isPlaying;
  final bool isLoading;
  final List<Track> queue;
  final int currentIndex;
  final Duration position;
  final Duration duration;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;

  const PlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLoading = false,
    this.queue = const [],
    this.currentIndex = -1,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
  });

  double get progress {
    if (duration.inMilliseconds > 0) {
      return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  PlayerState copyWith({
    Track? Function()? currentTrack,
    bool? isPlaying,
    bool? isLoading,
    List<Track>? queue,
    int? currentIndex,
    Duration? position,
    Duration? duration,
    bool? isShuffleEnabled,
    bool? isRepeatEnabled,
  }) {
    return PlayerState(
      currentTrack: currentTrack != null ? currentTrack() : this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
    );
  }
}
