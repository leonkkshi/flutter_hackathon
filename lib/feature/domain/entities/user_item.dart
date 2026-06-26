class UserItem {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String imageUrl;
  // Detail fields
  final String phone;
  final int age;
  final String gender;
  final String birthDate;
  final String address;

  const UserItem({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.imageUrl,
    this.phone = '',
    this.age = 0,
    this.gender = '',
    this.birthDate = '',
    this.address = '',
  });

  UserItem copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? imageUrl,
    String? phone,
    int? age,
    String? gender,
    String? birthDate,
    String? address,
  }) {
    return UserItem(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
    );
  }
}
