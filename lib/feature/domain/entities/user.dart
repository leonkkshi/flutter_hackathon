class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String imageUrl;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.imageUrl,
    required this.accessToken,
    required this.refreshToken,
  });
}
