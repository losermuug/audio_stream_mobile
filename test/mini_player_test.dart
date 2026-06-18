import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streaming_app/features/home/presentation/widgets/mini_player.dart';

void main() {
  testWidgets('MiniPlayer triggers onLikeTap when Like button is tapped', (WidgetTester tester) async {
    bool likeTapped = false;
    bool playerTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniPlayer(
            title: 'Test Title',
            artist: 'Test Artist',
            gradientColors: const [Colors.red, Colors.blue],
            isPlaying: false,
            progress: 0.5,
            onPlayPauseTap: () {},
            isLiked: false,
            onLikeTap: () {
              likeTapped = true;
            },
            onTap: () {
              playerTapped = true;
            },
          ),
        ),
      ),
    );

    // Find like button by finding the favorite_border_rounded icon
    final likeButton = find.byIcon(Icons.favorite_border_rounded);
    expect(likeButton, findsOneWidget);

    await tester.tap(likeButton);
    await tester.pump();

    expect(likeTapped, isTrue);
    expect(playerTapped, isFalse);
  });
}
