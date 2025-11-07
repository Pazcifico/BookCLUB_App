class Usuario {
  final int? id;
  String username;
  String email;
  String name;
  String? password; // opcional (usado só no cadastro ou login)

  Usuario({
    this.id,
    required this.username,
    required this.email,
    required this.name,
    this.password,
  });

  // Converter de JSON para objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'] ?? '',
    );
  }

  // Converter objeto Dart para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'name': name,
      if (password != null) 'password': password,
    };
  }
}
