class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? createdAt;
  const UserModel({this.id, required this.name, required this.email, this.createdAt});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: _asInt(json['id'] ?? json['user_id']),
    name: (json['name'] ?? json['username'] ?? 'User').toString(),
    email: (json['email'] ?? '').toString(),
    createdAt: json['created_at']?.toString(),
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'created_at': createdAt};
}
int? _asInt(dynamic value) => value == null ? null : int.tryParse(value.toString());
