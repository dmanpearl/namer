import 'package:english_words/english_words.dart';

final WordPair emptyWordPair = WordPair("m", "t");

final Map<String, Function> pairStyleMap = {
  "none": (WordPair pair) => pair.asString,
  "camelCase": (WordPair pair) => pair.asCamelCase,
  "lowercase": (WordPair pair) => pair.asLowerCase,
  "PascalCase": (WordPair pair) => pair.asPascalCase,
  "snake_case": (WordPair pair) => pair.asSnakeCase,
  "SCREAMING_SNAKE": (WordPair pair) => pair.asSnakeCase.toUpperCase(),
  "kebab-case": (WordPair pair) => pair.asSnakeCase.replaceAll("_", "-"),
  "UPPERCASE": (WordPair pair) => pair.asUpperCase,
  "space cace": (WordPair pair) => "${pair.first} ${pair.second}",
  "DnD case": (WordPair pair) => "${pair.first} & ${pair.second}",
};
final pairStyles = pairStyleMap.keys.toList();

String pairToString(WordPair pair, int styleIdx) {
  final String pairStyle = pairStyles[styleIdx];
  return pairStyleMap[pairStyle]!(pair);
}

bool wordPairsEqual(WordPair p1, WordPair p2) =>
    p1.first == p2.first && p1.second == p2.second;

bool wordPairListsEqual(List<WordPair> l1, List<WordPair> l2) {
  if (l1.length != l2.length) {
    return false;
  }
  for (int i = 0; i < l1.length; i++) {
    if (!wordPairsEqual(l1[i], l2[i])) {
      return false;
    }
  }
  return true;
}
