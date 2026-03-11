import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_conversion.dart';

class FavoriteConversionsService {
  static const String _key = 'favorite_conversions';
  static const int _maxFavorites = 20;

  Future<List<FavoriteConversion>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (item) => FavoriteConversion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorite({
    required String categoryName,
    required String fromSymbol,
    required String toSymbol,
  }) async {
    final favorites = await getFavorites();
    return favorites.any(
      (favorite) =>
          favorite.categoryName == categoryName &&
          favorite.fromSymbol == fromSymbol &&
          favorite.toSymbol == toSymbol,
    );
  }

  Future<bool> toggleFavorite({
    required String categoryName,
    required String fromSymbol,
    required String toSymbol,
    required String title,
  }) async {
    final favorites = await getFavorites();
    final existingIndex = favorites.indexWhere(
      (favorite) =>
          favorite.categoryName == categoryName &&
          favorite.fromSymbol == fromSymbol &&
          favorite.toSymbol == toSymbol,
    );

    if (existingIndex != -1) {
      favorites.removeAt(existingIndex);
      await _saveFavorites(favorites);
      return false;
    }

    favorites.insert(
      0,
      FavoriteConversion(
        categoryName: categoryName,
        fromSymbol: fromSymbol,
        toSymbol: toSymbol,
        title: title,
        createdAt: DateTime.now(),
      ),
    );
    if (favorites.length > _maxFavorites) {
      favorites.removeRange(_maxFavorites, favorites.length);
    }

    await _saveFavorites(favorites);
    return true;
  }

  Future<void> removeFavorite(FavoriteConversion favorite) async {
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.id == favorite.id);
    await _saveFavorites(favorites);
  }

  Future<void> _saveFavorites(List<FavoriteConversion> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      favorites.map((favorite) => favorite.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}