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
