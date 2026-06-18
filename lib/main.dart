import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/auth/presentation/pages/login_screen.dart';
import 'package:streaming_app/features/home/presentation/pages/home_screen.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/shared/bloc/player/player_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final authSession = AuthSession();
  await authSession.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(StreamingApp(isAuthenticated: authSession.isAuthenticated));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class StreamingApp extends StatelessWidget {
  final bool isAuthenticated;

  const StreamingApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerBloc>(
      create: (context) => PlayerBloc(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Khemnel',
        theme: AppColors.darkTheme,
        initialRoute: isAuthenticated ? '/home' : '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
