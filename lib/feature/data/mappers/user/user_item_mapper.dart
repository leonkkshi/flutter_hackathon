import 'package:flutter_hackathon/feature/data/dtos/user/user_dto.dart';
import 'package:flutter_hackathon/feature/data/mappers/i_mapper.dart';
import 'package:flutter_hackathon/feature/domain/entities/user_item.dart';

class UserItemMapper implements IMapper<UserDto, UserItem> {
  @override
  UserItem map(UserDto source) {
    return UserItem(
      id: source.id,
      username: source.username,
      email: source.email,
      fullName: '${source.firstName} ${source.lastName}'.trim(),
      imageUrl: source.imageUrl,
      phone: source.phone,
      age: source.age,
      gender: source.gender,
      birthDate: source.birthDate,
      address: source.address,
    );
  }
}
