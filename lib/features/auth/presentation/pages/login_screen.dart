import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:streaming_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:streaming_app/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:streaming_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:streaming_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:streaming_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  late final AuthRepository _authRepository;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          String errorMsg = e.toString().replaceAll('Exception: ', '');
          if (errorMsg.contains('Invalid email or password') || errorMsg.contains('Unexpected error')) {
            errorMsg = 'Имэйл эсвэл нууц үг буруу байна.';
          }
          CustomToast.show(
            context,
            errorMsg,
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),

                      // Logo / Brand
                      Center(
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'lib/assets/images/logo.svg',
                              width: 160,
                              height: 160,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'KHEMNEL',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Хэмнэлийг мэдэр',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        labelText: 'Имэйл',
                        hintText: 'Имэйл хаягаа оруулна уу',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Имэйл хаягаа оруулна уу';
                          }
                          if (!value.contains('@')) {
                            return 'Зөв имэйл хаяг оруулна уу';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        labelText: 'Нууц үг',
                        hintText: 'Нууц үгээ оруулна уу',
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        onFieldSubmitted: (_) => _onLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нууц үгээ оруулна уу';
                          }
                          if (value.length < 6) {
                            return 'Нууц үг хамгийн багадаа 6 тэмдэгт байна';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _rememberMe
                                        ? AppColors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _rememberMe
                                          ? AppColors.white
                                          : AppColors.grey500,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _rememberMe
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: AppColors.black,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Сануулах',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                _createRoute(const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              'Нууц үг мартсан?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      CustomButton(
                        text: 'Нэвтрэх',
                        onPressed: _onLogin,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 32),

                      // Divider
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Container(
                      //         height: 1,
                      //         color: AppColors.divider,
                      //       ),
                      //     ),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         'эсвэл',
                      //         style: TextStyle(
                      //           color: AppColors.textTertiary,
                      //           fontSize: 13,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Container(
                      //         height: 1,
                      //         color: AppColors.divider,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 24),

                      // // Social Buttons
                      // SocialButton(
                      //   text: 'Google-ээр нэвтрэх',
                      //   iconData: Icons.g_mobiledata_rounded,
                      //   onPressed: () {
                      //     // TODO: Google sign in
                      //   },
                      // ),
                      // const SizedBox(height: 12),
                      // SocialButton(
                      //   text: 'Apple-ээр нэвтрэх',
                      //   iconData: Icons.apple_rounded,
                      //   onPressed: () {
                      //     // TODO: Apple sign in
                      //   },
                      // ),

                      const SizedBox(height: 40),

                      // Sign Up Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              _createRoute(const SignupScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: 'Бүртгэл байхгүй юу? ',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Бүртгүүлэх',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
