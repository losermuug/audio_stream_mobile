class AuthUser {
  final String id;
  final String userName;
  final String email;
  final String role;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });
}
