import 'package:loxia/loxia.dart';
import 'package:loxia/src/entity/entity.dart';
import 'package:loxia_annotations/loxia_annotations.dart';

part 'user_entity.g.dart';

@EntityMeta()
class User extends Entity{

  static UserEntity get entity => UserEntity();

  @PrimaryKey(
    uuid: true
  )
  final String id;
  @Column()
  final String email;
  @Column()
  final String password;
  @Column()
  final String firstName;
  @Column()
  final String lastName;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });


  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password, firstName: $firstName, lastName: $lastName}';
  }
}