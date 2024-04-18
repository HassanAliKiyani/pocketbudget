import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pocketbudget/Database/wallet_datebase.dart';
import 'package:pocketbudget/Pages/HomePage.dart';
import 'package:pocketbudget/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateToHomePage();
    Provider.of<WalletDatabase>(context, listen: false).createDefaultWallet();

  }

  _navigateToHomePage() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset("lib/images/dollarsymbol.json"),
        // child: Provider.of<ThemeProvider>(context).isDark
        //     ? Lottie.asset("lib/images/splashdark.json")
        //     : Lottie.asset("lib/images/splash.json"),
      ),
    );
  }
}