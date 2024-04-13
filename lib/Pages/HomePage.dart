// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pocketbudget/Components/custom_drawer.dart';
import 'package:pocketbudget/Components/custom_list_tile.dart';
import 'package:pocketbudget/Database/expense_database.dart';
import 'package:pocketbudget/Graphs/bar_graph.dart';
import 'package:pocketbudget/Models/expense.dart';
import 'package:pocketbudget/Helper/helper_functions.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  //load bar graph data
  Future<Map<String, double>>? _monthlyTotalFuture;

  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    //initial load call to read expenses
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //Future to refresh the bar graph data
    refreshData();

    super.initState();
  }

  void refreshData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotalExpenses();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurentMonthExpenses();
  }

  //Create Expense Box
  void openExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Expense"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Name"),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText: "Amount"),
                )
              ]),
              actions: [
                _createButton(),
                _cancelButton(),
              ],
            ));
  }

  //Edit Expense Box
  void editExpenseBox({required Expense expense}) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Edit Expense"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: existingName),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(hintText: existingAmount),
                )
              ]),
              actions: [
                _editExpenseButton(expense),
                _cancelButton(),
              ],
            ));
  }

  //Delete Expense Box
  void deleteExpenseBox({required Expense expense}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Expense"),
              actions: [
                _deleteExpenseButton(expense),
                _cancelButton(),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // Get the starting dates for the data
      // int startMonth = value.getStartMonth();
      // int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      // Calculate the number of months since the stating date
      // int numberOfMonths = calculateNumberOfMonth(
      //   startYear: startYear,
      //   startMonth: startMonth,
      //   currentYear: currentYear,
      //   currentMonth: currentMonth,
      // );
      // Only display the expenses for the current month
      List<Expense> expenseOfCurrentMonth = value.allExpenses.where((expense) {
        return expense.date.month == currentMonth &&
            expense.date.year == currentYear;
      }).toList();

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        drawer: CustomDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: openExpenseBox,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: FutureBuilder(
            future: _calculateCurrentMonthTotal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(convertAmountToCurreny(snapshot.data ?? 0)),
                    Text(getMonthInitials(DateTime.now().month)),
                  ],
                );
              } else {
                return Text("Loading...");
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                  height: 250,
                  child: FutureBuilder(
                      future: _monthlyTotalFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, double> monthlyData = snapshot.data ?? {};
                          print(monthlyData);
                          int startMonth = value.getStartMonth();
                          int startYear = value.getStartYear();
                          int numberOfMonths = calculateNumberOfMonth(
                            startYear: startYear,
                            startMonth: startMonth,
                            currentYear: DateTime.now().year,
                            currentMonth: DateTime.now().month,
                          );
                          // print("currentmonth $currentMonth");
                          // print("currentYear $currentYear");
                          // print("startmonth $startMonth");
                          // print("startyear $startYear");
                          // print(numberOfMonths);
                          //Generate the list of monthly expenses
                          List<double> monthlySummary =
                              List.generate(numberOfMonths, (index) {
                            int year =
                                startYear + (startMonth + index - 1) ~/ 12;
                            int month = (startMonth + index - 1) % 12 + 1;

                            // print(month);

                            String key = "${year}_$month";
                            print(key);

                            return monthlyData[key] ?? 0.0;
                          });
                          print(monthlySummary);

                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth);
                        }
                        return const Center(child: Text("Loading..."));
                      })),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: expenseOfCurrentMonth.length,
                    itemBuilder: (context, index) {
                      //latest to the first
                      int reverseIndex =
                          expenseOfCurrentMonth.length - 1 - index;
                      // get the expense
                      Expense individualExpense =
                          expenseOfCurrentMonth[reverseIndex];
                      return CustomListTile(
                        title: individualExpense.name,
                        trailing:
                            convertAmountToCurreny(individualExpense.amount),
                        onEditPressed: (context) =>
                            editExpenseBox(expense: individualExpense),
                        onDeletePressed: (context) =>
                            deleteExpenseBox(expense: individualExpense),
                      );
                    }),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _createButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //Pop Alert
          Navigator.pop(context);
          //Create expense instance
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());
          //Save expense to database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          nameController.clear();
          amountController.clear();
          refreshData();
        }
      },
      child: Text("Save"),
    );
  }

  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //Pop Alert
          Navigator.pop(context);
          //Create expense instance
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());

          int existingId = expense.id;
          //Update expense to database

          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          nameController.clear();
          amountController.clear();
          refreshData();
        }
      },
      child: Text("Update"),
    );
  }

  Widget _deleteExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        nameController.clear();
        amountController.clear();
        Navigator.pop(context);
        await context.read<ExpenseDatabase>().deleteExpense(expense.id);
        refreshData();
      },
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        nameController.clear();
        amountController.clear();
        Navigator.pop(context);
      },
      child: Text("Cancel"),
    );
  }
}
