class Profile {
  final int id;
  final int userId;
  final String username; // obrigatório

  String? name;
  String? bio;
  String? profilePicture;
  String? thumbnail;

  Profile({
    required this.id,
    required this.userId,
    required this.username,
    this.name,
    this.bio,
    this.profilePicture,
    this.thumbnail,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: (json['id'] != null) ? json['id'] as int : 0,       // valor default se null
      userId: (json['user'] != null) ? json['user'] as int : 0,
      username: json['username'] ?? '',                        // assegura string
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'username': username,
      'name': name ?? '',
      'bio': bio ?? '',
      'profile_picture': profilePicture ?? '',
      'thumbnail': thumbnail ?? '',
    };
  }
}
