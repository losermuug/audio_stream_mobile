import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:streaming_app/features/home/domain/track.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  AudioPlayerService._internal();

  AudioPlayer get player => _player;

  // Dynamically resolve backend base URL
  static String get baseUrl {
    // Read from environment variable passed via --dart-define-from-file=.env or --dart-define=API_URL=...
    const String envApiUrl = String.fromEnvironment('API_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // For physical device testing, we use your MacBook's local network IP as fallback.
    // Make sure your phone and MacBook are connected to the same Wi-Fi network.
    const String macbookIp = '10.1.0.17';

    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      return 'http://$macbookIp:8080';
    }
  }

  // Get stream URL for a track ID
  static String getStreamUrl(String trackId) {
    // If the trackId is already a full URL, return it
    if (trackId.startsWith('http://') || trackId.startsWith('https://')) {
      return trackId;
    }
    return '$baseUrl/tracks/$trackId/stream';
  }

  // Resolve cover image provider
  static ImageProvider getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/image/cover1.png');
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else if (path.startsWith('/')) {
      return NetworkImage('$baseUrl$path');
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      if (path.contains('/') && !path.startsWith('assets/')) {
        return NetworkImage('$baseUrl/$path');
      } else {
        return AssetImage(path);
      }
    }
  }

  // Streams for UI consumption
  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  // Play audio from track ID or stream URL
  Future<void> playTrack(String trackId) async {
    try {
      final streamUrl = getStreamUrl(trackId);
      debugPrint('Streaming audio from: $streamUrl');
      
      // Stop current playback and set the new source
      await _player.stop();
      await _player.setUrl(streamUrl);
      
      // Start playing
      _player.play();
    } catch (e) {
      debugPrint('Error playing track $trackId: $e');
      rethrow;
    }
  }

  // Basic controls
  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();
  Future<void> seek(Duration position) async => _player.seek(position);
  Future<void> setVolume(double volume) async => _player.setVolume(volume);

  // Fetch tracks from GraphQL backend database
  Future<List<Track>> fetchTracks() async {
    try {
      final url = Uri.parse('$baseUrl/graphql');
      final query = {
        'query': '''
          query {
            tracks {
              id
              title
              durationMs
              coverUrl
              artist {
                name
              }
            }
          }
        '''
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(query),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['errors'] != null) {
          throw Exception(data['errors'][0]['message']);
        }
        
        final List rawTracks = data['data']['tracks'] ?? [];
        return rawTracks.map((item) {
          final int durMs = item['durationMs'] ?? 180000;
          final int minutes = (durMs / 60000).floor();
          final int seconds = ((durMs % 60000) / 1000).round();
          final durationStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

          return Track(
            id: item['id'] ?? '',
            title: item['title'] ?? 'Unknown Title',
            artist: item['artist']?['name'] ?? 'Unknown Artist',
            duration: durationStr,
            gradientColors: const [
              Color(0xFF2C3E50),
              Color(0xFFFD746C)
            ],
            imagePath: item['coverUrl'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch tracks: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching tracks: $e');
      rethrow;
    }
  }

  bool _isShuffleActive = false;
  bool get isShuffleActive => _isShuffleActive;

  bool _isRepeatActive = false;
  bool get isRepeatActive => _isRepeatActive;

  void setShuffleMode(bool enabled) {
    _isShuffleActive = enabled;
    debugPrint('Shuffle mode updated: $_isShuffleActive');
  }

  Future<void> setRepeatMode(bool enabled) async {
    _isRepeatActive = enabled;
    debugPrint('Repeat mode updated: $_isRepeatActive');
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
  }

  // Clean up
  Future<void> dispose() async {
    await _player.dispose();
  }
}
