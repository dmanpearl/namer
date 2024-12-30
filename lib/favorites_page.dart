import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'utils.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    var units = appState.favorites.length == 1 ? "favorite" : "favorites";
    var title = '${appState.favorites.length} $units';

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pairToString(pair, appState.pairStyle)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                appState.removeFavorite(pair);
              },
              child: Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
