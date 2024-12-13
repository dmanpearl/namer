import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'utils.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedIndex = 0;
  String example = "";
  int favoriteCount = 0;
  int historyCount = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    selectedIndex = appState.pairStyle;
    example = pairToString(appState.current, selectedIndex);
    favoriteCount = appState.favorites.length;
    historyCount = appState.history.length;

    final menuItems = <PopupMenuItem>[];
    for (var idx = 0; idx < pairStyles.length; idx++) {
      final item = PopupMenuItem(
        value: idx,
        child: StyleMenuItem(
          pairStyle: pairStyles[idx],
          example: pairToString(appState.current, idx),
        ),
      );
      menuItems.add(item);
    }

    DataCell createLabel(String label) =>
        DataCell(SizedBox(width: 80, child: Text(label)));

    List<DataRow> createRows() {
      return [
        DataRow(cells: [
          // History
          createLabel("History:"),
          DataCell(ElevatedButton.icon(
            onPressed: historyCount == 0
                ? null
                : () {
                    showAlertDialog(
                      context,
                      "Alert", // Alert title
                      "Are you sure you want to delete $historyCount history ${historyCount == 1 ? "record" : "records"}? This cannot be undone.",
                      () {
                        // Callback executed on user confirmation.
                        appState.clearHistory();
                        setState(() => historyCount = 0); // Force rerender
                      },
                    );
                  },
            label: Text("$historyCount"),
            icon: Icon(Icons.delete_forever),
          )),
        ]),

        // Case Style
        DataRow(cells: [
          // Favorites
          createLabel("Favorites:"),
          DataCell(ElevatedButton.icon(
            onPressed: favoriteCount == 0
                ? null
                : () {
                    showAlertDialog(
                      context,
                      "Alert", // Alert title
                      "Are you sure you want to delete $favoriteCount ${favoriteCount == 1 ? "favorite" : "favorites"}? This cannot be undone.",
                      () {
                        // Callback executed on user confirmation.
                        appState.clearFavorites();
                        setState(() => favoriteCount = 0); // Force rerender
                      },
                    );
                  },
            label: Text("$favoriteCount"),
            icon: Icon(Icons.delete_forever),
          )),
        ]),

        // Case Style
        DataRow(cells: [
          createLabel("Case Style:"),
          DataCell(PopupMenuButton(
            onSelected: (value) {
              appState.pairStyle = value;
              setState(() {
                selectedIndex = value;
                example = pairToString(appState.current, selectedIndex);
              });
            },
            itemBuilder: (BuildContext bc) {
              return menuItems;
            },
            initialValue: appState.pairStyle,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(19))),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
                child: StyleMenuItem(
                  pairStyle: pairStyles[selectedIndex],
                  example: example,
                ),
              ),
            ),
          )),
        ]),
      ];
    }

    final theme = Theme.of(context);
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Settings
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text("Settings:", style: theme.textTheme.titleLarge),
        ),

        DataTable(
          headingRowHeight: 0,
          dividerThickness: 0,
          columns: [
            DataColumn(label: Container()),
            DataColumn(label: Container()),
          ],
          rows: createRows(),
        ),
      ]),
    );
  }
}

class StyleMenuItem extends StatelessWidget {
  const StyleMenuItem({
    super.key,
    required this.pairStyle,
    required this.example,
  });

  final String pairStyle;
  final String example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          pairStyle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.primaryColor,
          ),
        ),

        // Subtitle
        Text(
          "example: $example",
          style: TextStyle(color: theme.primaryColor),
          textScaler: TextScaler.linear(0.7),
        ),
      ],
    );
  }
}

showAlertDialog(
    BuildContext context, String title, body, VoidCallback callback) {
  // set up the buttons
  Widget cancelButton = ElevatedButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop(); // dismiss dialog
    },
  );
  Widget continueButton = ElevatedButton(
    child: Text("Yes"),
    onPressed: () {
      callback();
      Navigator.of(context).pop(); // dismiss dialog
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(body),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
