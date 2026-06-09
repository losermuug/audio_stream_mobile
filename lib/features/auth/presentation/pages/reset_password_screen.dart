import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/features/auth/presentation/widgets/custom_button.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _successController;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;

  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _successController = AnimationController(
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
    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut,
      ),
    );
    _successOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

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
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _onResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // TODO: Reset password logic
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });
          _successController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessView();
    }
    return _buildFormView();
  }

  Widget _buildFormView() {
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

                      const SizedBox(height: 40),

                      // Shield Icon
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppColors.grey900,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.grey800,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glow,
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Header
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'Шинэ нууц үг',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Таны шинэ нууц үг өмнөх нууц үгээс ялгаатай байх шаардлагатай',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // New Password Field
                      CustomTextField(
                        labelText: 'Шинэ нууц үг',
                        hintText: 'Шинэ нууц үгээ оруулна уу',
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

                      // Password Strength
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
                        onFieldSubmitted: (_) => _onResetPassword(),
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

                      const SizedBox(height: 16),

                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Нууц үгийн шаардлага',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildRequirement(
                              'Хамгийн багадаа 6 тэмдэгт',
                              _passwordController.text.length >= 6,
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement(
                              'Том үсэг агуулсан',
                              RegExp(r'[A-Z]')
                                  .hasMatch(_passwordController.text),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement(
                              'Тоо агуулсан',
                              RegExp(r'[0-9]')
                                  .hasMatch(_passwordController.text),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirement(
                              'Тусгай тэмдэгт (!@#\$%)',
                              RegExp(r'[!@#\$%\^&\*]')
                                  .hasMatch(_passwordController.text),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Reset Button
                      CustomButton(
                        text: 'Нууц үг шинэчлэх',
                        onPressed: _onResetPassword,
                        isLoading: _isLoading,
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

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: met ? AppColors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: met ? AppColors.white : AppColors.grey700,
              width: 1.5,
            ),
          ),
          child: met
              ? const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: AppColors.black,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: met ? AppColors.textSecondary : AppColors.textTertiary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _AnimBuilder(
              animation: _successController,
              builder: (context) {
                return Opacity(
                  opacity: _successOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _successScaleAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glowStrong,
                                blurRadius: 48,
                                spreadRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: AppColors.black,
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Text(
                          'Амжилттай!',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Таны нууц үг амжилттай шинэчлэгдлээ.\nОдоо шинэ нууц үгээрээ нэвтэрч болно.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        CustomButton(
                          text: 'Нэвтрэх хуудас руу буцах',
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context) builder;

  const _AnimBuilder({
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
