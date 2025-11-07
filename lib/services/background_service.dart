import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService {
  static const String _backgroundKey = 'selected_background';
  
  // Доступні градієнтні фони
  static final List<BackgroundOption> backgrounds = [
    BackgroundOption(
      id: 'default',
      name: 'Кремовий класичний',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAF5EF), Color(0xFFF5EDE0)],
      ),
    ),
    BackgroundOption(
      id: 'golden_sunset',
      name: 'Золотий захід',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF4E6), Color(0xFFFFE4B5), Color(0xFFFFD89B)],
      ),
    ),
    BackgroundOption(
      id: 'warm_library',
      name: 'Тепла бібліотека',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8E1), Color(0xFFFFE082), Color(0xFFFFD54F)],
      ),
    ),
    BackgroundOption(
      id: 'soft_peach',
      name: 'М\'який персик',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFE5D9), Color(0xFFFFCCBC), Color(0xFFFFAB91)],
      ),
    ),
    BackgroundOption(
      id: 'vintage_paper',
      name: 'Вінтажний папір',
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFF5F5DC), Color(0xFFE8DCC4), Color(0xFFD4C5A9)],
      ),
    ),
    BackgroundOption(
      id: 'calm_morning',
      name: 'Спокійний ранок',
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4), Color(0xFFFFF59D)],
      ),
    ),
    BackgroundOption(
      id: 'gentle_rose',
      name: 'Ніжна троянда',
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFF48FB1)],
      ),
    ),
    BackgroundOption(
      id: 'misty_lavender',
      name: 'Туманна лаванда',
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7), Color(0xFFCE93D8)],
      ),
    ),
  ];

  static Future<String> getSavedBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backgroundKey) ?? 'default';
  }

  static Future<void> saveBackground(String backgroundId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, backgroundId);
  }

  static BackgroundOption getBackgroundById(String id) {
    return backgrounds.firstWhere(
      (bg) => bg.id == id,
      orElse: () => backgrounds[0],
    );
  }
}

class BackgroundOption {
  final String id;
  final String name;
  final LinearGradient gradient;

  const BackgroundOption({
    required this.id,
    required this.name,
    required this.gradient,
  });
}
