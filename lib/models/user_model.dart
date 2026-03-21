/// User model for HomeFix Pro
class UserModel {
  final String name;
  final String email;
  final String phone;
  final bool isLoggedIn;

  const UserModel({
    required this.name,
    required this.email,
    required this.phone,
    this.isLoggedIn = false,
  });

  /// Create a copy with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isLoggedIn,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  /// Default guest user
  static const UserModel guest = UserModel(
    name: 'Guest',
    email: '',
    phone: '',
    isLoggedIn: false,
  );
}
