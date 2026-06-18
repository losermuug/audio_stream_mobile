import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/features/auth/presentation/widgets/custom_button.dart';
import 'package:streaming_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:streaming_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:streaming_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late final AuthRepository _authRepository;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Password strength
  int _passwordStrength = 0;

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

    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 10) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$%\^&\*]').hasMatch(password)) strength++;

    setState(() {
      _passwordStrength = strength.clamp(0, 4);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSignup() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        CustomToast.show(
          context,
          'Үйлчилгээний нөхцөлийг зөвшөөрнө үү',
          isError: true,
        );
        return;
      }
      setState(() => _isLoading = true);
      try {
        await _authRepository.register(
          userName: _nameController.text.trim(),
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
          if (errorMsg.contains('Password must be at least')) {
            errorMsg = 'Нууц үг хамгийн багадаа 8 тэмдэгт байх ёстой.';
          } else if (errorMsg.toLowerCase().contains('unique constraint') || 
                     errorMsg.toLowerCase().contains('already exists') ||
                     errorMsg.toLowerCase().contains('fields: (`email`)')) {
            errorMsg = 'Энэ имэйл хаяг аль хэдийн бүртгэгдсэн байна.';
          } else if (errorMsg.contains('Unexpected error')) {
            errorMsg = 'Бүртгэл үүсгэхэд алдаа гарлаа. Мэдээллээ шалгана уу.';
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

  Color _getStrengthColor(int index) {
    if (index >= _passwordStrength) return AppColors.grey700;
    if (_passwordStrength <= 1) return AppColors.grey400;
    if (_passwordStrength <= 2) return AppColors.grey300;
    if (_passwordStrength <= 3) return AppColors.warmWhite;
    return AppColors.white;
  }

  String _getStrengthText() {
    if (_passwordController.text.isEmpty) return '';
    if (_passwordStrength <= 1) return 'Сул';
    if (_passwordStrength <= 2) return 'Дунд';
    if (_passwordStrength <= 3) return 'Сайн';
    return 'Хүчтэй';
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
                      const SizedBox(height: 16),

                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.grey900,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Header
                      const Text(
                        'Бүртгүүлэх',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Шинэ бүртгэлээ үүсгэж хэмнэлтэй залуустай нэгдээрэй',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Name Field
                      CustomTextField(
                        labelText: 'Нэр',
                        hintText: 'Нэрээ оруулна уу',
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нэрээ оруулна уу';
                          }
                          return null;
                        },
                      ),

                      // const SizedBox(height: 20),

                      // Date of Birth Field
                      // CustomDatePicker(
                      //   labelText: 'Төрсөн огноо',
                      //   hintText: 'Төрсөн огноогоо сонгоно уу',
                      //   initialValue: _selectedDate,
                      //   prefixIcon: const Icon(Icons.cake_outlined),
                      //   onDateSelected: (date) {
                      //     setState(() {
                      //       _selectedDate = date;
                      //     });
                      //   },
                      //   validator: (value) {
                      //     if (value == null) {
                      //       return 'Төрсөн огноогоо сонгоно уу';
                      //     }
                      //     return null;
                      //   },
                      // ),

                      const SizedBox(height: 20),

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
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
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

                      // Password Strength Indicator
                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ...List.generate(4, (index) {
                              return Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 3,
                                  margin: EdgeInsets.only(
                                    right: index < 3 ? 6 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStrengthColor(index),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            Text(
                              _getStrengthText(),
                              style: TextStyle(
                                color: _passwordStrength <= 1
                                    ? AppColors.grey400
                                    : _passwordStrength <= 2
                                        ? AppColors.grey300
                                        : AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      CustomTextField(
                        labelText: 'Нууц үг давтах',
                        hintText: 'Нууц үгээ дахин оруулна уу',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        onFieldSubmitted: (_) => _onSignup(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нууц үгээ давтана уу';
                          }
                          if (value != _passwordController.text) {
                            return 'Нууц үг таарахгүй байна';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Terms Agreement
                      GestureDetector(
                        onTap: () {
                          setState(() => _agreeToTerms = !_agreeToTerms);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _agreeToTerms
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreeToTerms
                                      ? AppColors.white
                                      : AppColors.grey500,
                                  width: 1.5,
                                ),
                              ),
                              child: _agreeToTerms
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: AppColors.black,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Би ',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Үйлчилгээний нөхцөл',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.grey500,
                                      ),
                                    ),
                                    TextSpan(text: ' болон '),
                                    TextSpan(
                                      text: 'Нууцлалын бодлого',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.grey500,
                                      ),
                                    ),
                                    TextSpan(text: '-г зөвшөөрч байна'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Signup Button
                      CustomButton(
                        text: 'Бүртгүүлэх',
                        onPressed: _onSignup,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.divider,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'эсвэл',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.divider,
                            ),
                          ),
                        ],
                      ),

                      // const SizedBox(height: 24),

                      // Social Buttons
                      // SocialButton(
                      //   text: 'Google-ээр бүртгүүлэх',
                      //   iconData: Icons.g_mobiledata_rounded,
                      //   onPressed: () {},
                      // ),
                      // const SizedBox(height: 12),
                      // SocialButton(
                      //   text: 'Apple-ээр бүртгүүлэх',
                      //   iconData: Icons.apple_rounded,
                      //   onPressed: () {},
                      // ),

                      const SizedBox(height: 32),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Бүртгэлтэй юу? ',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Нэвтрэх',
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
}
