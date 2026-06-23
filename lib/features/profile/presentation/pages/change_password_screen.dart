import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/theme/typography.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:streaming_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:streaming_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  late final ProfileRepository _profileRepository;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    try {
      await _profileRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        setState(() => _isSaving = false);

        CustomToast.show(
          context,
          'Нууц үг амжилттай солигдлоо',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Нууц үг солих',
          style: AppTypography.appBarTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Icon Header
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderSubtle.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppColors.textPrimary,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Old Password Input
                CustomTextField(
                  hintText: 'Хуучин нууц үгээ оруулна уу',
                  labelText: 'Хуучин нууц үг',
                  controller: _oldPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Хуучин нууц үгийг оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // New Password Input
                CustomTextField(
                  hintText: 'Шинэ нууц үгээ оруулна уу',
                  labelText: 'Шинэ нууц үг',
                  controller: _newPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Шинэ нууц үгийг оруулна уу';
                    }
                    if (val.length < 8) {
                      return 'Шинэ нууц үг доод тал нь 8 тэмдэгт байх ёстой';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Repeat Password Input
                CustomTextField(
                  hintText: 'Шинэ нууц үгээ давтан оруулна уу',
                  labelText: 'Шинэ нууц үг давтах',
                  controller: _repeatPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  onFieldSubmitted: (_) => _changePassword(),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Шинэ нууц үгийг давтан оруулна уу';
                    }
                    if (val != _newPasswordController.text) {
                      return 'Шинэ нууц үгс хоорондоо тохирохгүй байна';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A1F22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE94560).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFE94560), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFEE788C), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),

                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.grey700,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                          ),
                        )
                      : const Text(
                          'Хадгалах',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
