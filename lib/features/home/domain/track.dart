import 'package:flutter/material.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final List<Color> gradientColors;
  final bool isLiked;
  final String? imagePath;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    required this.gradientColors,
    this.isLiked = false,
    this.imagePath,
  });
}

class MockData {
  static const List<Track> recentlyPlayed = [
    Track(
      id: 'r1',
      title: 'Улаанбаатарын Нулимс',
      artist: 'Гантулга',
      duration: '3:45',
      gradientColors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
      imagePath: 'assets/image/cover1.png',
    ),
    Track(
      id: 'r2',
      title: 'Намрын Салхи',
      artist: 'The Colors',
      duration: '4:12',
      gradientColors: [Color(0xFF2B1B17), Color(0xFF5C3A21)],
      imagePath: 'assets/image/cover2.png',
    ),
    Track(
      id: 'r3',
      title: 'Үүлэн Хээ',
      artist: 'Магнолиан',
      duration: '3:20',
      gradientColors: [Color(0xFF0F2027), Color(0xFF203A43)],
      imagePath: 'assets/image/cover3.png',
    ),
    Track(
      id: 'r4',
      title: 'Зүүдний Хөлөг Онгоц',
      artist: 'Нисванис',
      duration: '5:01',
      gradientColors: [Color(0xFF141E30), Color(0xFF243B55)],
      imagePath: 'assets/image/cover4.png',
    ),
  ];

  static const List<Track> recommended = [
    Track(
      id: 'rec1',
      title: 'Энгийн Зүйлс',
      artist: 'Vandebo',
      duration: '3:34',
      gradientColors: [Color(0xFF310F3F), Color(0xFF64105B)],
      imagePath: 'assets/image/cover3.png',
    ),
    Track(
      id: 'rec2',
      title: 'Хайр',
      artist: 'Seryoja',
      duration: '2:58',
      gradientColors: [Color(0xFF0D2C54), Color(0xFFC1121F)],
      imagePath: 'assets/image/cover4.png',
    ),
    Track(
      id: 'rec3',
      title: 'Бидний Хэмнэл',
      artist: 'Ginjin x Mrs.M',
      duration: '4:05',
      gradientColors: [Color(0xFF1D976C), Color(0xFF93F9B9)],
      imagePath: 'assets/image/cover5.png',
    ),
    Track(
      id: 'rec4',
      title: 'Сүүлчийн Бүжиг',
      artist: 'A-Sound',
      duration: '4:40',
      gradientColors: [Color(0xFFBA5370), Color(0xFFF1E1C6)],
      imagePath: 'assets/image/cover6.png',
    ),
  ];

  static const List<Track> featuredPlaylists = [
    Track(
      id: 'pl1',
      title: 'Оройн Намуун Хэмнэл',
      artist: '15 Дуу • Chill & Lofi',
      duration: '45 мин',
      gradientColors: [Color(0xFF111111), Color(0xFF444444)],
      imagePath: 'assets/image/cover1.png',
    ),
    Track(
      id: 'pl2',
      title: 'Эрч Хүчтэй Монгол Рок',
      artist: '20 Дуу • Heavy Beats',
      duration: '1 ц 12 мин',
      gradientColors: [Color(0xFF2C3E50), Color(0xFFFD746C)],
      imagePath: 'assets/image/cover2.png',
    ),
  ];

  static const Track featuredHero = Track(
    id: 'hero',
    title: 'Оддын Зүг',
    artist: 'Чингис Хаан хамтлаг',
    duration: '4:15',
    gradientColors: [Color(0xFF000000), Color(0xFF434343)],
    imagePath: 'assets/image/cover6.png',
  );
}
