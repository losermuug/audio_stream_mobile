import 'package:streaming_app/features/home/domain/track.dart';

abstract class PlayerEvent {
  const PlayerEvent();
}

class PlayTrackEvent extends PlayerEvent {
  final Track track;
  final List<Track> queue;

  const PlayTrackEvent({required this.track, required this.queue});
}

class TogglePlayPauseEvent extends PlayerEvent {
  const TogglePlayPauseEvent();
}

class NextTrackEvent extends PlayerEvent {
  const NextTrackEvent();
}

class PreviousTrackEvent extends PlayerEvent {
  const PreviousTrackEvent();
}

class SeekEvent extends PlayerEvent {
  final Duration position;

  const SeekEvent(this.position);
}

class ToggleShuffleEvent extends PlayerEvent {
  const ToggleShuffleEvent();
}

class ToggleRepeatEvent extends PlayerEvent {
  const ToggleRepeatEvent();
}

class UpdatePositionEvent extends PlayerEvent {
  final Duration position;

  const UpdatePositionEvent(this.position);
}

class UpdateDurationEvent extends PlayerEvent {
  final Duration duration;

  const UpdateDurationEvent(this.duration);
}

class UpdatePlayingEvent extends PlayerEvent {
  final bool isPlaying;

  const UpdatePlayingEvent(this.isPlaying);
}

class UpdateLoadingEvent extends PlayerEvent {
  final bool isLoading;

  const UpdateLoadingEvent(this.isLoading);
}

class UpdateTrackEvent extends PlayerEvent {
  final Track track;

  const UpdateTrackEvent(this.track);
}
