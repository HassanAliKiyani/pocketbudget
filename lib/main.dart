import 'package:flutter/material.dart';
import 'package:pocketbudget/Database/expense_database.dart';
import 'package:pocketbudget/Pages/HomePage.dart';
import 'package:pocketbudget/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize database
  await ExpenseDatabase.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpenseDatabase>(
          create: (context) => ExpenseDatabase(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}
