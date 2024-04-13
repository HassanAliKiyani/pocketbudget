import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketbudget/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("S E T T I N G S"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(12.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Dark Mode",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CupertinoSwitch(
                value:
                    Provider.of<ThemeProvider>(context, listen: false).isDark,
                onChanged: (vlaue) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleThemeData();
                })
          ],
        ),
      ),
    );
  }
}
