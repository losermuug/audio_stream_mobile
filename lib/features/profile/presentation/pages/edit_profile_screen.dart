import 'package:flutter/material.dart';
import 'package:streaming_app/shared/theme/colors.dart';
import 'package:streaming_app/shared/theme/typography.dart';
import 'package:streaming_app/shared/widgets/custom_text_field.dart';
import 'package:streaming_app/shared/services/auth_session.dart';
import 'package:streaming_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:streaming_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:streaming_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:streaming_app/shared/services/api_client.dart';
import 'package:streaming_app/shared/widgets/custom_toast.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final ProfileRepository _profileRepository;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: AuthSession().userName ?? '');
    _emailController = TextEditingController(text: AuthSession().userEmail ?? '');
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: ProfileRemoteDataSource(
        apiClient: ApiClient(),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();

    try {
      await _profileRepository.updateProfile(
        userName: userName,
        email: email,
      );

      // Cache the new credentials locally
      await AuthSession().updateProfile(
        userName: userName,
        userEmail: email,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        
        CustomToast.show(
          context,
          'Хувийн мэдээлэл амжилттай шинэчлэгдлээ',
        );
        
        // Return success flag
        Navigator.pop(context, true);
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
          'Хувийн мэдээлэл засах',
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
                      Icons.person_rounded,
                      color: AppColors.textPrimary,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Username input
                CustomTextField(
                  hintText: 'Нэрээ оруулна уу',
                  labelText: 'Хэрэглэгчийн нэр',
                  controller: _userNameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Хэрэглэгчийн нэрийг оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Email input
                CustomTextField(
                  hintText: 'Имэйл хаяг оруулна уу',
                  labelText: 'Имэйл хаяг',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                  onFieldSubmitted: (_) => _saveProfile(),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Имэйл хаягийг оруулна уу';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return 'Зөв имэйл хаяг оруулна уу';
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
                  onPressed: _isSaving ? null : _saveProfile,
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
