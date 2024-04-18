import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketbudget/Components/custom_list_tile.dart';
import 'package:pocketbudget/Components/progress_loader.dart';
import 'package:pocketbudget/Database/expense_database.dart';
import 'package:pocketbudget/Database/wallet_datebase.dart';
import 'package:pocketbudget/Helper/helper_functions.dart';
import 'package:pocketbudget/Models/expense.dart';
import 'package:pocketbudget/Models/wallet.dart';
import 'package:provider/provider.dart';

class WalletDetailsPage extends StatefulWidget {
  const WalletDetailsPage({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletDetailsPage> createState() => _WalletDetailsPageState();
}

class _WalletDetailsPageState extends State<WalletDetailsPage> {
  String filter = "All";

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  int selectedWallet = 1;
  bool isExpense = true;

  Future<double>? _calculateWalletTotalExpenses;

  Future<double>? _calculateWalletTotalIncome;

  Future<Wallet?>? localWallet;

  @override
  void initState() {
    //Future to refresh the bar graph data
    refreshData();
    selectedWallet = widget.wallet.id;

    super.initState();
  }

  void refreshData() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    _calculateWalletTotalExpenses =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateWalletTotalExpenses(widget.wallet.id);
    localWallet = Wallet.getWalletById(widget.wallet.id);
    _calculateWalletTotalIncome =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateWalletTotalIncome(widget.wallet.id);
  }

  //Create Expense Box
  void openExpenseBox() {
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
      List<Expense> expenseToDisplay = value.allExpenses.where((expense) {
        if (expense.wallet! == widget.wallet.id) {
          switch (filter) {
            case "Income":
              return !expense.isExpense;
            case "Expense":
              return expense.isExpense;
            default:
              return true;
          }
        }
        return false;
      }).toList();
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.wallet.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FutureBuilder(
                    future: localWallet,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text(
                            convertAmountToCurreny(snapshot.data!.amount));
                      } else {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      }
                    }),
              ],
            ),
          ),
          body: Column(
            children: [
              //Display the Card telling total inbound and outbound expenses
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(12.0),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      Theme.of(context).colorScheme.surface.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    FutureBuilder(
                        future: _calculateWalletTotalExpenses,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.red,
                                  size: 15,
                                ),
                                Text(" Total Wallet Expense"),
                                const Spacer(),
                                Text(convertAmountToCurreny(snapshot.data ?? 0))
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text("Loading..."),
                            );
                          }
                        }),
                    FutureBuilder(
                        future: _calculateWalletTotalIncome,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Row(
                              children: [
                                const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.green,
                                  size: 15,
                                ),
                                Text(" Total Wallet Income"),
                                const Spacer(),
                                Text(convertAmountToCurreny(snapshot.data ?? 0))
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text("Loading..."),
                            );
                          }
                        }),
                  ],
                ),
              ),
              //Three tab buttons to switch between all, incoming and out going expenses

              _tabButtons(),

              //Expanded box to display the expenses
              Expanded(
                child: expenseToDisplay.isNotEmpty
                    ? ListView.builder(
                        itemCount: expenseToDisplay.length,
                        itemBuilder: (context, index) {
                          //latest to the first
                          int reverseIndex =
                              expenseToDisplay.length - 1 - index;
                          // get the expense
                          Expense individualExpense =
                              expenseToDisplay[reverseIndex];
                          return CustomListTile(
                            leading: individualExpense.isExpense
                                ? const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red,
                                    size: 15,
                                  )
                                : const Icon(
                                    Icons.arrow_downward,
                                    color: Colors.green,
                                    size: 15,
                                  ),
                            title: individualExpense.name,
                            trailing: convertAmountToCurreny(
                                individualExpense.amount),
                            onEditPressed: (context) =>
                                editExpenseBox(expense: individualExpense),
                            onDeletePressed: (context) =>
                                deleteExpenseBox(expense: individualExpense),
                          );
                        })
                    : const Center(child: Text("No Record Found")),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                filter = "All";
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: filter == "All"
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                "All",
                style: TextStyle(
                  color: filter == "All"
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                filter = "Income";
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: filter == "Income"
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                "Income",
                style: TextStyle(
                  color: filter == "Income"
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                filter = "Expense";
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: filter == "Expense"
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                "Expense",
                style: TextStyle(
                  color: filter == "Expense"
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
}
