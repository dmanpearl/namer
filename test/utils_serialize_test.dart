import 'package:english_words/english_words.dart';
import 'package:test/test.dart';

import 'package:namer/utils.dart';
import 'package:namer/utils_serialize.dart';

void main() {
  test('serializeOne', () {
    expect(serializeOne(WordPair('a', 'b')), 'a--b');
  });
  test('deserializeOne', () {
    expect(wordPairsEqual(deserializeOne('a--b'), WordPair('a', 'b')), true);
  });
  test('serializeMany', () {
    expect(serializeMany([WordPair('a', 'b'), WordPair('c', 'd')]),
        ['a--b', 'c--d']);
  });
  test('deserializeMany', () {
    expect(
      wordPairListsEqual(
        deserializeMany(['a--b', 'c--d']),
        [WordPair('a', 'b'), WordPair('c', 'd')],
      ),
      true,
    );
  });
}
