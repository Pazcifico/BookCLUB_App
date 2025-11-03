class Usuario {
  final int id;
  String nome;
  String usuario;
  String bio;
  String? fotoUrl;

  Usuario({
    required this.id,
    required this.nome,
    required this.usuario,
    required this.bio,
    this.fotoUrl,
  });


  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      usuario: json['usuario'],
      bio: json['bio'] ?? '',
      fotoUrl: json['fotoUrl'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'usuario': usuario,
      'bio': bio,
      'fotoUrl': fotoUrl,
    };
  }
}
