import 'package:isar/isar.dart';
import 'package:pocketbudget/Database/database_init.dart';

/*
* Isra realted command to generate isar file
* run this cmd in terminal: dart run build_runner build
*/
part 'expense.g.dart';

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;
  bool isExpense;
  int? wallet;

  Expense(
      {required this.name,
      required this.amount,
      required this.date,
      required this.isExpense,
      this.wallet});

  
}
