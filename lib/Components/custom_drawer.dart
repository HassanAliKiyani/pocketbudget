import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pocketbudget/Pages/SettingsPage.dart';
import 'package:pocketbudget/Pages/WalletPage.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DrawerHeader(
            // child: Lottie.network(
            //     "https://lottie.host/embed/6709e27f-04c8-4d01-b5cd-0b83442c871c/zOUPRnINEa.json",
            //     animate: true),
            child: Icon(
              Icons.wallet_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 25.0),
            child: ListTile(
              title: Text(
                "H O M E",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              leading: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                //Poping the drawer
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 0),
            child: ListTile(
              title: Text(
                "W A L L E T S",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              leading: Icon(
                Icons.wallet_giftcard,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                //Pop the drawer
                Navigator.pop(context);
                //Navigate to the settings page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WalletPage()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 0),
            child: ListTile(
              title: Text(
                "S E T T I N G S",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              leading: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                //Pop the drawer
                Navigator.pop(context);
                //Navigate to the settings page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),
          )
        ],
      ),
    );
  }
}
