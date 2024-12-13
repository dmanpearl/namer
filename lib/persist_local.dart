import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  String serializeOne(WordPair pair) {
    return "${pair.first}--${pair.second}";
  }

  WordPair deserializeOne(String s) {
    final List<String> tokens = s.split("--");
    if (tokens.length < 2) {
      return emptyWordPair;
    }
    return WordPair(tokens[0], tokens[1]);
  }

  List<String> serializeMany(List<WordPair> pairs) {
    List<String> ss = [];
    for (var pair in pairs) {
      ss.add(serializeOne(pair));
    }
    return ss;
  }

  List<WordPair> deserializeMany(List<String> ss) {
    List<WordPair> pairs = [];
    for (var s in ss) {
      pairs.add(deserializeOne(s));
    }
    return pairs;
  }

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
