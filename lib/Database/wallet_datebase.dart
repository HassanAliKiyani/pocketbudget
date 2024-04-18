import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pocketbudget/Database/database_init.dart';
import 'package:pocketbudget/Models/wallet.dart';

class WalletDatabase extends ChangeNotifier {
  List<Wallet> _allWallets = [];

  List<Wallet> get allWallets => _allWallets;

  /*
   * O P E R A T I O N S _ C R U D
   */

  //Create default wallet

  Future<void> createDefaultWallet() async {
    try {
      //add to db
      List<Wallet> fetchWalletFromDb =
          await IsarDatabaseInitializer.isar.wallets.where().findAll();
      if (fetchWalletFromDb.isNotEmpty) {
        return;
      }
      Wallet newWallet = Wallet(
          name: "Default", amount: 10000, lastTransaction: DateTime.now());
      await IsarDatabaseInitializer.isar
          .writeTxn(() => IsarDatabaseInitializer.isar.wallets.put(newWallet));

      //re-read
      await readWallets();

      //notify the UI
      notifyListeners();
    } catch (e) {
      debugPrintStack();
    }
  }

  //CREATE - new Wallets
  Future<void> createNewWallet(Wallet newWallet) async {
    try {
      //add to db
      await IsarDatabaseInitializer.isar
          .writeTxn(() => IsarDatabaseInitializer.isar.wallets.put(newWallet));

      //re-read
      await readWallets();

      //notify the UI
      notifyListeners();
    } catch (e) {
      debugPrintStack();
    }
  }

  //READ - Wallets from database
  Future<void> readWallets() async {
    try {
      List<Wallet> fetchWalletFromDb =
          await IsarDatabaseInitializer.isar.wallets.where().findAll();

      _allWallets.clear();
      _allWallets.addAll(fetchWalletFromDb);

      //notify UI
      notifyListeners();
    } catch (e) {
      print("hello $e");
    }
  }

  //UPDATE

  Future<void> updateWallet(int id, Wallet updatedWallet) async {
    //new Wallet has the same id
    updatedWallet.id = id;

    await IsarDatabaseInitializer.isar.writeTxn(
        () => IsarDatabaseInitializer.isar.wallets.put(updatedWallet));
    //re-read
    await readWallets();

    //notify the UI
    notifyListeners();
  }

  //DELETE
  Future<void> deleteWallet(int id) async {
    await IsarDatabaseInitializer.isar
        .writeTxn(() => IsarDatabaseInitializer.isar.wallets.delete(id));

    //re-read
    await readWallets();

    notifyListeners();
  }
}
