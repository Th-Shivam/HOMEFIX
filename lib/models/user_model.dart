/// User model for HomeFix Pro
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final bool isLoggedIn;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.isLoggedIn = false,
  });

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    bool? isLoggedIn,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  /// Default guest (not logged in) user
  static const UserModel guest = UserModel(
    uid: '',
    name: 'Guest',
    email: '',
    phone: '',
    isLoggedIn: false,
  );
}
