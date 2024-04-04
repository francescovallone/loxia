import 'package:loxia/loxia.dart';
import 'todo_entity.dart';

part 'user_entity.g.dart';

@EntityMeta()
class User extends Entity {
  static UserEntity get entity => UserEntity();

  @PrimaryKey(autoIncrement: true)
  int id;
  @Column()
  String email;
  @Column()
  String password;
  @Column()
  String firstName;
  @Column()
  String lastName;

  @OneToMany(
    on: Todo,
  )
  List<Todo> todos;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.todos = const [],
  });

  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password, firstName: $firstName, lastName: $lastName}';
  }
}
