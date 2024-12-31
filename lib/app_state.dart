import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'persist_local.dart';
import 'utils.dart';
import 'utils_logger.dart';
import 'utils_serialize.dart';

var logger = getLogger();

class AppState extends ChangeNotifier {
  // Initial values may be overwritten by stored shared preferences
  WordPair _current = emptyWordPair;
  List<WordPair> _history = <WordPair>[];
  List<WordPair> _favorites = <WordPair>[];
  int _pairStyle = 0;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Object _currentSubscription = Null;
  Object _historySubscription = Null;
  Object _favoritesSubscription = Null;
  Object _pairStyleSubscription = Null;

  GlobalKey? historyListKey;

  AppState() {
    // Load stored state from shared preferences
    final (cr, fv, hs, ps) = sharedPrefs.readAll();
    if (cr == emptyWordPair) {
      // Use a new random WordPair, since persistent storage is empty.
      _current = WordPair.random();
      sharedPrefs.saveCurrent(_current);
    } else {
      // Use current from persistent storage.
      _current = cr;
    }
    current = _current; // Forces sharedPrefs.saveCurrent
    _favorites = fv;
    _history = hs;
    _pairStyle = ps;
    initFirebase();
  }

  // _current
  WordPair get current => _current;
  set current(WordPair value) {
    if (_current != value) _current = value;
    sharedPrefs.saveCurrent(value);
    if (loggedIn) {
      remoteSaveCurrent(value);
    }
  }

  void getNext() {
    addHistory(current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random(); // Generate next WordPair
    notifyListeners();
  }

  // _history
  List<WordPair> get history => _history;
  set history(List<WordPair> values) {
    if (!wordPairListsEqual(_history, values)) {
      final int oldLen = _history.length;
      _history = values;
      var animatedList = historyListKey?.currentState as AnimatedListState?;
      for (int i = 0; i < values.length - oldLen; i++) {
        animatedList?.insertItem(0); // Insert new items
      }
      sharedPrefs.saveHistory(values);
      if (loggedIn) {
        remoteSaveHistory(values);
      }
      notifyListeners();
    }
  }

  // Insert the current pair into history, and limit the total size of the history buffer.
  void addHistory(WordPair pair) {
    const historyMax = 100;
    if (_history.length >= historyMax) {
      _history.removeRange(historyMax - 1, _history.length);
    }
    _history.insert(0, current);
    sharedPrefs.saveHistory(_history);
    if (loggedIn) {
      remoteSaveHistory(_history);
    }
    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    sharedPrefs.saveHistory(_history);
    if (loggedIn) {
      remoteSaveHistory(_history);
    }
    notifyListeners();
  }

  // _favorites
  List<WordPair> get favorites => _favorites;
  set favorites(List<WordPair> values) {
    if (!wordPairListsEqual(_favorites, values)) {
      _favorites = values;
      sharedPrefs.saveFavorites(values);
      if (loggedIn) {
        remoteSaveFavorites(values);
      }
      notifyListeners();
    }
  }

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (_favorites.contains(pair)) {
      _favorites.remove(pair);
    } else {
      _favorites.add(pair);
    }
    sharedPrefs.saveFavorites(_favorites);
    if (loggedIn) {
      remoteSaveFavorites(_favorites);
    }
    notifyListeners();
  }

  List<WordPair> removeFavorite(WordPair pair) {
    _favorites.removeWhere((favorite) => favorite == pair);
    sharedPrefs.saveFavorites(_favorites);
    if (loggedIn) {
      remoteSaveFavorites(_favorites);
    }
    notifyListeners();
    return _favorites;
  }

  void clearFavorites() {
    _favorites = [];
    sharedPrefs.saveFavorites(_favorites);
    if (loggedIn) {
      remoteSaveFavorites(_favorites);
    }
    notifyListeners();
  }

  // _pairStyle
  int get pairStyle => _pairStyle;
  set pairStyle(int value) {
    _pairStyle = value;
    sharedPrefs.savePairStyle(value);
    if (loggedIn) {
      remoteSavePairStyle(value);
    }
    notifyListeners();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        // Logged Out
        _loggedIn = false;
        logger.d('app_state - FirebaseAuth - LOGOUT');
        if (_currentSubscription != Null) {
          (_currentSubscription as StreamSubscription).cancel();
        }
        if (_historySubscription != Null) {
          (_historySubscription as StreamSubscription).cancel();
        }
        if (_favoritesSubscription != Null) {
          (_favoritesSubscription as StreamSubscription).cancel();
        }
        if (_pairStyleSubscription != Null) {
          (_pairStyleSubscription as StreamSubscription).cancel();
        }
        notifyListeners();
        return;
      }

      // Logged In
      _loggedIn = true;
      logger.d(
          'app_state - FirebaseAuth - LOGIN - user: ${user.displayName}, listening...');
      _currentSubscription = FirebaseFirestore.instance
          .collection('current')
          .where('name', isEqualTo: user.displayName)
          .snapshots()
          .listen((snapshot) {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final incoming = deserializeOne(data['current']);
          if (current == incoming) {
            continue;
          }
          logger.i(
              'app_state - listen - current - change "$current" to "$incoming"');
          current = incoming;
          notifyListeners();
        }
      });

      _historySubscription = FirebaseFirestore.instance
          .collection('history')
          .where('name', isEqualTo: user.displayName)
          .snapshots()
          .listen((snapshot) {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final incoming =
              deserializeMany(List<String>.from(data['history'] as List));
          if (wordPairListsEqual(history, incoming)) {
            continue;
          }
          logger.i(
              'app_state - listen - history - change "$history" to "$incoming"');
          history = incoming;
          notifyListeners();
        }
      });

      _favoritesSubscription = FirebaseFirestore.instance
          .collection('favorites')
          .where('name', isEqualTo: user.displayName)
          .snapshots()
          .listen((snapshot) {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final incoming =
              deserializeMany(List<String>.from(data['favorites'] as List));
          if (wordPairListsEqual(favorites, incoming)) {
            continue;
          }
          logger.i(
              'app_state - listen - favorites - change "$favorites" to "$incoming"');
          favorites = incoming;
          notifyListeners();
        }
      });

      _pairStyleSubscription = FirebaseFirestore.instance
          .collection('pairStyle')
          .where('name', isEqualTo: user.displayName)
          .snapshots()
          .listen((snapshot) {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (DocumentSnapshot doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final incoming = data['pairStyle'];
          if (pairStyle == incoming) {
            continue;
          }
          logger.i(
              'app_state - listen - pairStyle - change "$pairStyle" to "$incoming"');
          pairStyle = incoming;
        }
        notifyListeners();
      });

      notifyListeners();
    });
  }

  // SAVE to FireStore

  void remoteSave(String collection, Object value) {
    if (!_loggedIn) {
      throw Exception('Must be logged in');
    }
    final user = FirebaseAuth.instance.currentUser;
    final uid = user!.uid;
    final data = <String, dynamic>{
      collection: value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': user.displayName,
      'userId': uid,
    };
    FirebaseFirestore.instance.collection(collection).doc(uid).set(data);
  }

  void remoteSaveCurrent(WordPair pair) =>
      remoteSave('current', serializeOne(pair));

  void remoteSaveFavorites(List<WordPair> pairs) =>
      remoteSave('favorites', serializeMany(pairs));

  void remoteSaveHistory(List<WordPair> pairs) =>
      remoteSave('history', serializeMany(pairs));

  void remoteSavePairStyle(int pairStyle) => remoteSave('pairStyle', pairStyle);
}
