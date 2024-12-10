import 'package:english_words/english_words.dart';

const pairStyles = [
  "none",
  "camelCase",
  "lowercase",
  "PascalCase",
  "snake_case",
  "SCREAMING_SNAKE",
  "kebab-case",
  "UPPERCASE",
  "sp ace",
];

String pairToString(WordPair pair, int styleIdx) {
  switch (styleIdx) {
    case 0:
      return pair.asString;
    case 1:
      return pair.asCamelCase;
    case 2:
      return pair.asLowerCase;
    case 3:
      return pair.asPascalCase;
    case 4:
      return pair.asSnakeCase;
    case 5:
      return pair.asSnakeCase.toUpperCase();
    case 6:
      return pair.asSnakeCase.replaceAll("_", "-");
    case 7:
      return pair.asUpperCase;
    case 8:
      return "${pair.first} ${pair.second}";
    default:
      throw UnimplementedError('no option for style index: $styleIdx');
  }
}
