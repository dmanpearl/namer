import 'package:english_words/english_words.dart';
import 'package:test/test.dart';

import 'package:namer/utils.dart';

void main() {
  final pair = WordPair('a', 'b');
  test('pair styles', () {
    expect(pairToString(pair, 0), 'ab', reason: 'none');
    expect(pairToString(pair, 1), 'aB', reason: 'camelCase');
    expect(pairToString(pair, 2), 'ab', reason: 'lowercase');
    expect(pairToString(pair, 3), 'AB', reason: 'PascalCase');
    expect(pairToString(pair, 4), 'a_b', reason: 'snake_case');
    expect(pairToString(pair, 5), 'A_B', reason: 'SCREAMING_SNAKE');
    expect(pairToString(pair, 6), 'a-b', reason: 'kebab-case');
    expect(pairToString(pair, 7), 'AB', reason: 'UPPERCASE');
    expect(pairToString(pair, 8), 'a b', reason: 'space cace');
    expect(pairToString(pair, 9), 'a & b', reason: 'DnD case');
  });

  final pairSame = WordPair('a', 'b');
  final pairsDifferent = [
    WordPair('c', 'd'),
    WordPair('full', 'empty'),
    WordPair('very', 'spec!@! ch@rs')
  ];
  test('word pairs equal', () {
    expect(wordPairsEqual(pair, pairSame), true);
  });
  test('word pairs not equal', () {
    for (WordPair pairDifferent in pairsDifferent) {
      expect(wordPairsEqual(pair, pairDifferent), false);
    }
  });

  test('word pair lists equal', () {
    expect(
        wordPairListsEqual(
          [WordPair('a', 'b'), WordPair('c', 'd')],
          [WordPair('a', 'b'), WordPair('c', 'd')],
        ),
        true);
  });

  test('word pair lists not equal', () {
    expect(
        wordPairListsEqual(
          [WordPair('a', 'b'), WordPair('c', 'd')],
          [WordPair('a', 'b'), WordPair('c', 'X')],
        ),
        false);
  });
}
