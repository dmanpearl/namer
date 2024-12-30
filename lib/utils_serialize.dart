import 'package:english_words/english_words.dart';

import 'utils.dart';

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
