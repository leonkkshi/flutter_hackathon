class UserDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String imageUrl;
  // Detail fields from DummyJSON
  final String phone;
  final int age;
  final String gender;
  final String birthDate;
  final String address;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    this.phone = '',
    this.age = 0,
    this.gender = '',
    this.birthDate = '',
    this.address = '',
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    // DummyJSON address is a nested object
    final addr = json['address'] as Map<String, dynamic>?;
    final addressStr = addr != null
        ? [
            addr['address'] as String? ?? '',
            addr['city'] as String? ?? '',
            addr['state'] as String? ?? '',
            addr['country'] as String? ?? '',
          ].where((s) => s.isNotEmpty).join(', ')
        : '';

    // DummyJSON gender: "male"/"female" → Vietnamese
    final rawGender = (json['gender'] as String? ?? '').toLowerCase();
    final genderVi = rawGender == 'male'
        ? 'Nam'
        : rawGender == 'female'
            ? 'Nữ'
            : rawGender;

    // Format birthDate from "YYYY-MM-DD" to "DD/MM/YYYY"
    final rawBirth = json['birthDate'] as String? ?? '';
    final birthFormatted = _formatBirthDate(rawBirth);

    return UserDto(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: genderVi,
      birthDate: birthFormatted,
      address: addressStr,
    );
  }

  static String _formatBirthDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parts = raw.split('-');
      if (parts.length == 3) {
        final day = parts[2].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[0];
        return '$day/$month/$year';
      }
    } catch (_) {
      // ignore
    }
    return raw;
  }
}
