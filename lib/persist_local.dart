import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';
import 'utils_serialize.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  Future<void> init() async =>
      _sharedPrefs = await SharedPreferences.getInstance();

  void saveCurrent(WordPair pair) =>
      _sharedPrefs.setString('current', serializeOne(pair));
  void saveFavorites(List<WordPair> pairs) =>
      _sharedPrefs.setStringList('favorites', serializeMany(pairs));
  void saveHistory(List<WordPair> pairs) =>
      _sharedPrefs.setStringList('history', serializeMany(pairs));
  void savePairStyle(int pairStyle) =>
      _sharedPrefs.setInt('pairStyle', pairStyle);

  (WordPair, List<WordPair>, List<WordPair>, int) readAll() {
    // current
    final WordPair current = _sharedPrefs.containsKey('current')
        ? deserializeOne(_sharedPrefs.getString('current')!)
        : emptyWordPair;

    // favorites
    final List<WordPair> favorites = _sharedPrefs.containsKey('favorites')
        ? deserializeMany(_sharedPrefs.getStringList('favorites')!)
        : [];

    // history
    final List<WordPair> history = _sharedPrefs.containsKey('history')
        ? deserializeMany(_sharedPrefs.getStringList('history')!)
        : [];

    // pairStyle
    final int pairStyle = _sharedPrefs.getInt('pairStyle') ?? 0;

    return (current, favorites, history, pairStyle);
  }
}

final sharedPrefs = SharedPrefs();
