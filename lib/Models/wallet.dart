import 'package:isar/isar.dart';

/*
* Isra realted command to generate isar file
* run this cmd in terminal: dart run build_runner build
*/
part 'wallet.g.dart';

@Collection()
class Wallet {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime creationDate;
  final DateTime lastTransaction;

  Wallet({
    required this.name,
    required this.amount,
    required this.lastTransaction,
  }) : creationDate = DateTime.now();
}
