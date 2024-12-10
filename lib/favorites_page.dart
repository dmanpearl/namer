import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'utils.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  var favorites = [];
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    var units = favorites.length == 1 ? "favorite" : "favorites";
    var title = '${favorites.length} $units';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        for (var pair in favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pairToString(pair, appState.pairStyleIndex)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                appState.favorites.removeWhere((fav) => fav == pair);
                setState(() => favorites = appState.favorites);
              },
              child: Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
