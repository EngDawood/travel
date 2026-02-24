// lib/models/user.dart
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;
  final String password; // hashed
  @JsonKey(
    fromJson: _categoriesFromJson,
    toJson: _categoriesToJson,
  )
  final List<String> preferredCategories;

  const User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.preferredCategories = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// SQLite stores preferred_categories as a JSON string
  factory User.fromDb(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      preferredCategories: map['preferred_categories'] != null
          ? List<String>.from(jsonDecode(map['preferred_categories'] as String))
          : [],
    );
  }

  Map<String, dynamic> toDb() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'password': password,
      'preferred_categories': jsonEncode(preferredCategories),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    List<String>? preferredCategories,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }

  static List<String> _categoriesFromJson(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) return List<String>.from(jsonDecode(value));
    return [];
  }

  static dynamic _categoriesToJson(List<String> categories) => categories;
}
