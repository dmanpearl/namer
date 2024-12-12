import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favorites_page.dart';
import 'generate_page.dart';
import 'persist_local.dart';
import 'settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Initial values may be overwritten by stored shared preferences
  var _current = WordPair.random();
  var _history = <WordPair>[];
  var _favorites = <WordPair>[];
  var _pairStyle = 0;

  GlobalKey? historyListKey;

  MyAppState() {
    // Load stored state from shared preferences
    final (current, favorites, history, pairStyle) = sharedPrefs.readAll();
    if (current != WordPair("m", "t")) {
      // Saved current is not empty, use it instead of the new random pair
      _current = current;
    }
    setCurrent(_current);
    _favorites = favorites;
    _history = history;
    setPairStyle(pairStyle);
  }

  // _current
  WordPair getCurrent() => _current;
  void setCurrent(WordPair pair) {
    _current = pair;
    sharedPrefs.saveCurrent(_current);
  }

  void getNext() {
    addHistory(getCurrent());
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    setCurrent(WordPair.random()); // Generate next WordPair
    notifyListeners();
  }

  // _history
  List<WordPair> getHistory() => _history;
  // Insert the current pair into history, and limit the total size of the history buffer.
  void addHistory(WordPair pair) {
    const historyMax = 100;
    if (_history.length >= historyMax) {
      _history.removeRange(historyMax - 1, _history.length);
    }
    _history.insert(0, getCurrent());
    sharedPrefs.saveHistory(_history);
    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    sharedPrefs.saveHistory(_history);
    notifyListeners();
  }

  // _favorites
  List<WordPair> getFavorites() => _favorites;
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? getCurrent();
    if (_favorites.contains(pair)) {
      _favorites.remove(pair);
    } else {
      _favorites.add(pair);
    }
    sharedPrefs.saveFavorites(_favorites);
    notifyListeners();
  }

  List<WordPair> removeFavorite(WordPair pair) {
    _favorites.removeWhere((favorite) => favorite == pair);
    sharedPrefs.saveFavorites(_favorites);
    notifyListeners();
    return _favorites;
  }

  void clearFavorites() {
    _favorites = [];
    sharedPrefs.saveFavorites(_favorites);
    notifyListeners();
  }

  // _pairStyle
  int getPairStyle() => _pairStyle;
  void setPairStyle(int value) {
    _pairStyle = value;
    sharedPrefs.savePairStyle(value);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    var pages = [
      GeneratorPage(),
      FavoritesPage(),
      SettingsPage(),
    ];
    if (selectedIndex < 0 || selectedIndex >= pages.length) {
      throw UnimplementedError('no widget for selected index: $selectedIndex');
    }
    var page = pages[selectedIndex];

    // The container for the current page, with its background color
    // and subtle switching animation.
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(child: mainArea),
          ],
        ),
      );
    });
  }
}
