class Profile {
  final int id;
  String? name;
  String? bio;
  String? profilePicture;
  String? thumbnail;

  Profile({
    required this.id,
    required this.name,
    required this.bio,
    this.profilePicture,
    this.thumbnail,
  });

  // Converter de JSON para objeto Dart
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profile_picture'],
      thumbnail: json['thumbnail'],
    );
  }

  // Converter objeto Dart para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'profile_picture': profilePicture,
      'thumbnail': thumbnail,
    };
  }
}
