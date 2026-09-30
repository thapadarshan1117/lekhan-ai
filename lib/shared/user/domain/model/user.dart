class User {
  final String userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final bool? isActive;
  final String? whatsapp;
  final String? role;
  final String? branch;
  final String? country;
  final String? timezone;
  final bool? isTeamMember;

  User({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.isActive,
    this.whatsapp,
    this.role,
    this.branch,
    this.country,
    this.timezone,
    this.isTeamMember,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['fullName'] ?? json['full_name'] ?? json['name'],
      email: json['email'],
      phone: (json['phone_number'] ?? json['phone'])?.toString(),
      profileImage:
          json['profile_picture'] ??
          json['profileImage'] ??
          (json['profile'] != null ? json['profile']['profile_picture'] : null),
      isActive: json['is_active'],
      whatsapp:
          (json['whatsapp'] ??
                  (json['profile'] != null
                      ? json['profile']['whatsapp']
                      : null))
              ?.toString(),
      role: json['role'] is Map
          ? (json['role']['role'] ??
                json['role']['name'] ??
                json['role'].toString())
          : (json['role']?.toString()),
      branch: json['branch'] is Map<String, dynamic>
          ? (json['branch']['name']?.toString())
          : (json['branch']?.toString()),
        country: json['country']?.toString() ??
          json['nationality']?.toString() ??
          (json['branch'] is Map<String, dynamic>
            ? json['branch']['country']?.toString()
            : null),
        timezone: json['timezone']?.toString() ?? json['time_zone']?.toString(),
      isTeamMember: json['is_team_member'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'full_name': name,
      'email': email,
      'phone_number': phone,
      'profile_picture': profileImage,
      'is_active': isActive,
      'whatsapp': whatsapp,
      'role': role,
      'branch': branch,
      'country': country,
      'timezone': timezone,
      'is_team_member': isTeamMember,
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isActive,
    String? whatsapp,
    String? role,
    String? branch,
    String? country,
    String? timezone,
    bool? isTeamMember,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
      whatsapp: whatsapp ?? this.whatsapp,
      role: role ?? this.role,
      branch: branch ?? this.branch,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      isTeamMember: isTeamMember ?? this.isTeamMember,
    );
  }

  // Get user's name with null handling
  String get getName => name ?? 'Unknown';

  // Get user's email with null handling
  String get getEmail => email ?? 'No email';

  // Get user's phone with null handling
  String get getPhone => phone ?? 'No phone';

  // Get user's status
  String get getStatusString => isActive == true ? 'Active' : 'Inactive';

  // Empty user constructor
  static User empty() {
    return User(userId: '');
  }

  @override
  String toString() {
    return 'User(userId: $userId, name: $name, email: $email, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
