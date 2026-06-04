import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const StreamingApp());
}

class StreamingApp extends StatelessWidget {
  const StreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khemnel',
      theme: AppColors.darkTheme,
      home: const LoginScreen(),
    );
  }
}
