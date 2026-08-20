import 'package:flutter/material.dart';

/// Maps a product/category name to a representative emoji + soft tint.
///
/// The backend often stores no image URL, so this keeps the catalog looking
/// rich and food-like. When a real image URL is present the UI uses that
/// instead — this is only the fallback.
class FoodEmoji {
  FoodEmoji._();

  static const Map<String, String> _keywords = {
    'broccoli': '🥦', 'radish': '🥬', 'spinach': '🥬', 'lettuce': '🥬',
    'squash': '🎃', 'pumpkin': '🎃', 'zucchini': '🥒', 'cucumber': '🥒',
    'carrot': '🥕', 'pepper': '🫑', 'chilli': '🌶️', 'tomato': '🍅',
    'corn': '🌽', 'potato': '🥔', 'onion': '🧅', 'garlic': '🧄',
    'mushroom': '🍄', 'avocado': '🥑', 'eggplant': '🍆', 'vegetable': '🥦',
    'apple': '🍎', 'strawberr': '🍓', 'apricot': '🍑', 'peach': '🍑',
    'orange': '🍊', 'banana': '🍌', 'grape': '🍇', 'pineapple': '🍍',
    'watermelon': '🍉', 'melon': '🍈', 'lemon': '🍋', 'cherr': '🍒',
    'mango': '🥭', 'kiwi': '🥝', 'coconut': '🥥', 'blueberr': '🫐',
    'pomegranate': '🫐', 'pear': '🍐', 'fruit': '🍎',
    'beef': '🥩', 'steak': '🥩', 'meat': '🥩', 'chicken': '🍗',
    'bacon': '🥓', 'pork': '🥓', 'sausage': '🌭',
    'fish': '🐟', 'salmon': '🐟', 'shrimp': '🦐', 'prawn': '🦐', 'crab': '🦀',
    'egg': '🥚', 'bread': '🍞', 'scone': '🥯', 'bagel': '🥯',
    'croissant': '🥐', 'baguette': '🥖', 'nut': '🥜', 'peanut': '🥜',
    'almond': '🥜', 'honey': '🍯', 'wheat': '🌾', 'flour': '🌾',
    'cheese': '🧀', 'milk': '🥛', 'butter': '🧈', 'yogurt': '🥛',
    'pasta': '🍝', 'spaghetti': '🍝', 'rice': '🍚', 'noodle': '🍜',
    'water': '💧', 'juice': '🧃', 'coffee': '☕', 'tea': '🍵',
  };

  static const List<Color> _tints = [
    Color(0xFFE8F5E9),
    Color(0xFFFFEBEE),
    Color(0xFFFBE9E7),
    Color(0xFFE3F2FD),
    Color(0xFFFFF8E1),
    Color(0xFFF3E5F5),
    Color(0xFFE0F2F1),
    Color(0xFFFFF3E0),
  ];

  static String forName(String name) {
    final n = name.toLowerCase();
    for (final entry in _keywords.entries) {
      if (n.contains(entry.key)) return entry.value;
    }
    return '🛒';
  }

  static Color tintFor(String key) {
    final hash = key.codeUnits.fold<int>(0, (a, b) => a + b);
    return _tints[hash % _tints.length];
  }
}
