import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pocketbudget/Database/database_init.dart';
import 'package:pocketbudget/Models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  List<Expense> _allExpenses = [];
  /*
    S E T U P
 */

  /// G E T T E R S

  List<Expense> get allExpenses => _allExpenses;

  /*
   * O P E R A T I O N S _ C R U D
   */
  //CREATE - new expenses
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await IsarDatabaseInitializer.isar
        .writeTxn(() => IsarDatabaseInitializer.isar.expenses.put(newExpense));

    //re-read
    await readExpenses();

    //notify the UI
    notifyListeners();
  }

  //READ - expenses from database
  Future<void> readExpenses() async {
    List<Expense> fetchExpenseFromDb =
        await IsarDatabaseInitializer.isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchExpenseFromDb);

    //notify UI
    notifyListeners();
  }

  //UPDATE

  Future<void> updateExpense(int id, Expense updatedExpense) async {
    //new expense has the same id
    updatedExpense.id = id;

    await IsarDatabaseInitializer.isar.writeTxn(
        () => IsarDatabaseInitializer.isar.expenses.put(updatedExpense));
    //re-read
    await readExpenses();

    //notify the UI
    notifyListeners();
  }

  //DELETE
  Future<void> deleteExpense(int id) async {
    await IsarDatabaseInitializer.isar
        .writeTxn(() => IsarDatabaseInitializer.isar.expenses.delete(id));

    //re-read
    await readExpenses();

    notifyListeners();
  }

  /*
   * H E L P E R S
   */

  Future<Map<String, double>> calculateMonthlyTotalExpenses() async {
    //read data form the database
    await readExpenses();
    //create the map to track
    Map<String, double> monthlyExpenses = {};
    //iterate over expenses
    for (var expense in _allExpenses) {
      String yearMonth = "${expense.date.year}_${expense.date.month}";
      // print(yearMonth);
      if (!monthlyExpenses.containsKey(yearMonth)) {
        monthlyExpenses[yearMonth] = 0;
      }
      monthlyExpenses[yearMonth] = monthlyExpenses[yearMonth]! + expense.amount;
    }
    //return the totals
    // print(monthlyExpenses);
    return monthlyExpenses;
  }

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month; // default goes for the current month
    }
    //Sort all the data to get the current month value

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    // Ensure that the list is sorted in ascending order before retrieving the first item's month
    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year; // default goes for the current year
    }
    //Sort all the data to get the current year value

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }

  Future<double> calculateCuurentMonthExpenses() async {
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth &&
          expense.date.year == currentYear;
    }).toList();

    //calculating the whole expenses
    double total =
        currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }
}
