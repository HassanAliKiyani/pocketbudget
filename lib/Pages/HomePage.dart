// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pocketbudget/Components/custom_drawer.dart';
import 'package:pocketbudget/Components/custom_list_tile.dart';
import 'package:pocketbudget/Components/progress_loader.dart';
import 'package:pocketbudget/Database/expense_database.dart';
import 'package:pocketbudget/Database/wallet_datebase.dart';
import 'package:pocketbudget/Graphs/bar_graph.dart';
import 'package:pocketbudget/Models/expense.dart';
import 'package:pocketbudget/Helper/helper_functions.dart';
import 'package:pocketbudget/Models/wallet.dart';
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

  Map<int, String> dropdownWallets = {};
  int selectedWallet = 1;
  bool isExpense = true;

  @override
  void initState() {
    //initial load call to read expenses
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    Provider.of<WalletDatabase>(context, listen: false).readWallets();

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
    dropdownWallets.clear();
    Provider.of<WalletDatabase>(context, listen: false)
        .allWallets
        .forEach((element) {
      dropdownWallets.putIfAbsent(element.id, () => element.name);
    });

    showDialog(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, StateSetter setState) {
              return AlertDialog(
                title: Text("New Expense"),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Name"),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(hintText: "Amount"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Wallet",
                      ),
                      DropdownButton<int>(
                          borderRadius: BorderRadius.circular(10.0),
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          value: selectedWallet,
                          items: [
                            ...dropdownWallets.keys.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(dropdownWallets[e]!),
                                ))
                          ],
                          onChanged: (int? newSelect) {
                            if (newSelect != null) {
                              setState(() {
                                selectedWallet = newSelect;
                              });
                            }
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isExpense ? "Expense" : "Income",
                      ),
                      CupertinoSwitch(
                          activeColor: Colors.red,
                          trackColor: Colors.green,
                          value: isExpense,
                          onChanged: (value) {
                            setState(() {
                              isExpense = value;
                            });
                          })
                    ],
                  ),
                ]),
                actions: [
                  _createButton(),
                  _cancelButton(),
                ],
              );
            }));
  }

  //Edit Expense Box
  void editExpenseBox({required Expense expense}) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    isExpense = expense.isExpense;
    dropdownWallets.clear();
    Provider.of<WalletDatabase>(context, listen: false)
        .allWallets
        .forEach((element) {
      dropdownWallets.putIfAbsent(element.id, () => element.name);
    });

    selectedWallet = expense.wallet!;

    showDialog(
        context: context,
        builder: (context) =>
            StatefulBuilder(builder: (context, StateSetter setState) {
              return AlertDialog(
                title: Text("Edit Expense"),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Wallet",
                      ),
                      DropdownButton<int>(
                          borderRadius: BorderRadius.circular(10.0),
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          value: selectedWallet,
                          items: [
                            ...dropdownWallets.keys.map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(dropdownWallets[e]!),
                                ))
                          ],
                          onChanged: null),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isExpense ? "Expense" : "Income",
                      ),
                      CupertinoSwitch(
                          activeColor: Colors.red,
                          trackColor: Colors.green,
                          value: isExpense,
                          onChanged: (value) {
                            setState(() {
                              isExpense = value;
                            });
                          })
                    ],
                  ),
                ]),
                actions: [
                  _editExpenseButton(expense),
                  _cancelButton(),
                ],
              );
            }));
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
                    Expanded(
                      flex: 2,
                      child: Text(convertAmountToCurreny(snapshot.data ?? 0)),
                    ),
                    Text(getMonthInitials(DateTime.now().month)),
                    ElevatedButton(
                        onPressed: () {
                          refreshData();
                        },
                        child: Icon(Icons.refresh))
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
                          // print(monthlyData);
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
                            // print(key);

                            return monthlyData[key] ?? 0.0;
                          });
                          // print(monthlySummary);

                          return MyBarGraph(
                              monthlySummary: monthlySummary,
                              startMonth: startMonth);
                        }
                        return Center(
                            child: Lottie.asset("lib/images/loader.json"));
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

          double amount = convertStringToDouble(amountController.text);
          //Create expense instance
          Expense newExpense = Expense(
              name: nameController.text,
              amount: amount,
              date: DateTime.now(),
              isExpense: isExpense,
              wallet: selectedWallet);
          showProgressLoader(context);
          await updateInWallet(amount, null);
          //Save expense to database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          //close progress indicator
          Navigator.of(context).pop();
          resetActions();
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
          var amount = amountController.text.isNotEmpty
              ? convertStringToDouble(amountController.text)
              : expense.amount;
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            isExpense: isExpense,
            amount: amount,
            date: DateTime.now(),
            wallet: expense.wallet,
          );

          int existingId = expense.id;
          //Update expense to database
          showProgressLoader(context);
          await updateInWallet(amount, expense);
          Navigator.pop(context);
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          resetActions();
          refreshData();
        }
      },
      child: Text("Update"),
    );
  }

  Widget _deleteExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        resetActions();
        Navigator.pop(context);
        Wallet? edittedWallet;
        edittedWallet = await Wallet.getWalletById(expense.wallet!);
        expense.isExpense
            ? edittedWallet!.amount += expense.amount
            : edittedWallet!.amount -= expense.amount;
        await context
            .read<WalletDatabase>()
            .updateWallet(edittedWallet.id, edittedWallet);
        await context.read<ExpenseDatabase>().deleteExpense(expense.id);
        refreshData();
      },
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Future<void> updateInWallet(double amount, Expense? previousExpense) async {
    Wallet? edittedWallet;
    edittedWallet = await Wallet.getWalletById(selectedWallet);
    if (previousExpense != null) {
      //Seletected wallet is now the orignal wallet of it
      // edittedWallet = await Wallet.getWalletById(previousExpense.wallet!);
      //Recreate the orignal amount
      previousExpense.isExpense
          ? edittedWallet!.amount += previousExpense.amount
          : edittedWallet!.amount -= previousExpense.amount;
      //Perform the updated transaction
      isExpense
          ? edittedWallet.amount -= amount
          : edittedWallet.amount += amount;
    } else {
      isExpense
          ? edittedWallet!.amount -= amount
          : edittedWallet!.amount += amount;
    }

    await context
        .read<WalletDatabase>()
        .updateWallet(edittedWallet.id, edittedWallet);
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        resetActions();
        Navigator.pop(context);
      },
      child: Text("Cancel"),
    );
  }

  void resetActions() {
    nameController.clear();
    amountController.clear();
    selectedWallet = 1;
  }
}
