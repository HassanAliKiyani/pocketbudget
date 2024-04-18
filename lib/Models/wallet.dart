import 'package:isar/isar.dart';
import 'package:pocketbudget/Database/database_init.dart';

/*
* Isra realted command to generate isar file
* run this cmd in terminal: dart run build_runner build
*/
part 'wallet.g.dart';

@Collection()
class Wallet {
  Id id = Isar.autoIncrement;
  final String name;
  double amount;
  final DateTime creationDate;
  final DateTime lastTransaction;

  Wallet({
    required this.name,
    required this.amount,
    required this.lastTransaction,
  }) : creationDate = DateTime.now();

  static Future<Wallet?> getWalletById(int id) async {
    Wallet? fetchWalletFromDb =
        await IsarDatabaseInitializer.isar.wallets.get(id);
    return fetchWalletFromDb;
  }
}
