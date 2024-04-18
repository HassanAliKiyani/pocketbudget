import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbudget/Models/expense.dart';
import 'package:pocketbudget/Models/wallet.dart';

//Singleton class for database connection
class IsarDatabaseInitializer {
  static late Isar isar;

  Isar get isarInstance => isar;

  /*
    S E T U P
  */

  //initialize the data base
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    //List all collection to open connections with them
    isar = await Isar.open([ExpenseSchema, WalletSchema], directory: dir.path);
  }
}
