class Profile {
  final int id;
  final int userId;
  final String username; // obrigatório

  String? name;
  String? bio;
  String? profilePicture;
  String? thumbnail;
  int? followersCount;
  int? followingCount;
  int? livrosCount;

  Profile({
    required this.id,
    required this.userId,
    required this.username,
    this.name,
    this.bio,
    this.profilePicture,
    this.thumbnail,
    this.followersCount,
    this.followingCount,
    this.livrosCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
  final id = int.tryParse(json['id'].toString()) ?? 0;
  final userId = json.containsKey('user') 
      ? int.tryParse(json['user'].toString()) ?? 0 
      : id; // fallback se user não existir

  return Profile(
    id: id,
    userId: userId,
    username: json['username'] ?? '',
    name: json['name'] ?? '',
    bio: json['bio'] ?? '',
    profilePicture: json['profile_picture'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    followersCount: json['followers_count'] ?? 0,
    followingCount: json['following_count'] ?? 0,
    livrosCount: json['livros_count'] ?? 0,
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
      'followers_count': followersCount ?? 0,
      'following_count': followingCount ?? 0,
      'livros_count': livrosCount ?? 0,
    };
  }
}
