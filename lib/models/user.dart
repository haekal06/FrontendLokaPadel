class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      lastName: json["last_name"],
      email: json["email"],
      role: json["role"],
    );
  }
}
