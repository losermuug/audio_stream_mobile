import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:streaming_app/shared/services/audio_player_service.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _audioService = AudioPlayerService();

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;
  StreamSubscription? _processingSub;

  PlayerBloc() : super(const PlayerState()) {
    on<PlayTrackEvent>(_onPlayTrack);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<NextTrackEvent>(_onNextTrack);
    on<PreviousTrackEvent>(_onPreviousTrack);
    on<SeekEvent>(_onSeek);
    on<ToggleShuffleEvent>(_onToggleShuffle);
    on<ToggleRepeatEvent>(_onToggleRepeat);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<UpdatePlayingEvent>(_onUpdatePlaying);
    on<UpdateLoadingEvent>(_onUpdateLoading);
    on<UpdateTrackEvent>(_onUpdateTrack);

    _initStreamSubscriptions();
  }

  void _initStreamSubscriptions() {
    _playingSub = _audioService.isPlayingStream.listen((playing) {
      add(UpdatePlayingEvent(playing));
    });

    _positionSub = _audioService.positionStream.listen((position) {
      add(UpdatePositionEvent(position));
    });

    _durationSub = _audioService.durationStream.listen((duration) {
      if (duration != null) {
        add(UpdateDurationEvent(duration));
      }
    });

    _processingSub = _audioService.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        add(const NextTrackEvent());
      } else if (state == ProcessingState.loading || state == ProcessingState.buffering) {
        add(const UpdateLoadingEvent(true));
      } else {
        add(const UpdateLoadingEvent(false));
      }
    });
  }

  Future<void> _onPlayTrack(PlayTrackEvent event, Emitter<PlayerState> emit) async {
    final index = event.queue.indexWhere((t) => t.id == event.track.id);
    emit(state.copyWith(
      currentTrack: () => event.track,
      queue: event.queue,
      currentIndex: index != -1 ? index : 0,
      isLoading: true,
    ));

    try {
      await _audioService.playTrack(event.track);
    } catch (e) {
      add(const UpdateLoadingEvent(false));
    }
  }

  Future<void> _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<PlayerState> emit) async {
    if (state.currentTrack == null && state.queue.isNotEmpty) {
      add(PlayTrackEvent(track: state.queue.first, queue: state.queue));
      return;
    }

    if (state.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  void _onNextTrack(NextTrackEvent event, Emitter<PlayerState> emit) {
    if (state.queue.isEmpty) return;

    int nextIndex = 0;
    if (state.isShuffleEnabled) {
      nextIndex = Random().nextInt(state.queue.length);
    } else {
      nextIndex = state.currentIndex + 1;
      if (nextIndex >= state.queue.length) {
        nextIndex = 0;
      }
    }

    final nextTrack = state.queue[nextIndex];
    emit(state.copyWith(
      currentTrack: () => nextTrack,
      currentIndex: nextIndex,
      isLoading: true,
    ));

    _audioService.playTrack(nextTrack).catchError((_) {
      add(const UpdateLoadingEvent(false));
    });
  }

  void _onPreviousTrack(PreviousTrackEvent event, Emitter<PlayerState> emit) {
    if (state.queue.isEmpty) return;

    int prevIndex = 0;
    if (state.isShuffleEnabled) {
      prevIndex = Random().nextInt(state.queue.length);
    } else {
      prevIndex = state.currentIndex - 1;
      if (prevIndex < 0) {
        prevIndex = state.queue.length - 1;
      }
    }

    final prevTrack = state.queue[prevIndex];
    emit(state.copyWith(
      currentTrack: () => prevTrack,
      currentIndex: prevIndex,
      isLoading: true,
    ));

    _audioService.playTrack(prevTrack).catchError((_) {
      add(const UpdateLoadingEvent(false));
    });
  }

  Future<void> _onSeek(SeekEvent event, Emitter<PlayerState> emit) async {
    await _audioService.seek(event.position);
  }

  Future<void> _onToggleShuffle(ToggleShuffleEvent event, Emitter<PlayerState> emit) async {
    final nextMode = !state.isShuffleEnabled;
    _audioService.setShuffleMode(nextMode);
    emit(state.copyWith(isShuffleEnabled: nextMode));
  }

  Future<void> _onToggleRepeat(ToggleRepeatEvent event, Emitter<PlayerState> emit) async {
    final nextMode = !state.isRepeatEnabled;
    await _audioService.setRepeatMode(nextMode);
    emit(state.copyWith(isRepeatEnabled: nextMode));
  }

  void _onUpdatePosition(UpdatePositionEvent event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onUpdateDuration(UpdateDurationEvent event, Emitter<PlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onUpdatePlaying(UpdatePlayingEvent event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isPlaying: event.isPlaying));
  }

  void _onUpdateLoading(UpdateLoadingEvent event, Emitter<PlayerState> emit) {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  void _onUpdateTrack(UpdateTrackEvent event, Emitter<PlayerState> emit) {
    final updatedQueue = state.queue.map((t) {
      return t.id == event.track.id ? event.track : t;
    }).toList();

    final isCurrent = state.currentTrack?.id == event.track.id;
    emit(state.copyWith(
      currentTrack: isCurrent ? () => event.track : null,
      queue: updatedQueue,
    ));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _processingSub?.cancel();
    return super.close();
  }
}
