import 'package:isar/isar.dart';

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
  final String wallet;

  Expense(
      {required this.name,
      required this.amount,
      required this.date,
      this.wallet = "default"});
}
