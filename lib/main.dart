import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/auth/presentation/pages/login_screen.dart';
import 'package:streaming_app/features/home/presentation/pages/home_screen.dart';
import 'package:streaming_app/shared/services/auth_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Khemnel',
      theme: AppColors.darkTheme,
      initialRoute: isAuthenticated ? '/home' : '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
