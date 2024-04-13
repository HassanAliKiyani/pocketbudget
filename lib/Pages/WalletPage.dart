import 'package:flutter/material.dart';
import 'package:pocketbudget/Database/wallet_datebase.dart';
import 'package:pocketbudget/Helper/helper_functions.dart';
import 'package:pocketbudget/Models/wallet.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<WalletDatabase>(context, listen: false).readWallets();

    super.initState();
  }

  //Create Wallet Box
  void openWalletBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("New Wallet"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Wallet Name"),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletDatabase>(builder: (context, value, child) {
      List<Wallet> _allWallets = value.allWallets;
      print("Getting from data base ${_allWallets.length}");

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("W A L L E T S"),
        ),
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.94,
              child: TextButton(
                onPressed: openWalletBox,
                child: const Text("Add Wallet"),
              ),
            ),
            Expanded(
                child: GridView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: _allWallets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.wallet,
                                  size: 50,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_allWallets.elementAt(index).name),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(convertAmountToCurreny(
                                    _allWallets.elementAt(index).amount)),
                              ),
                            ],
                          ),
                        ),
                      );
                    })),
          ],
        )),
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

          //Creating a new wallet for the database

          Wallet newWallet = Wallet(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              lastTransaction: DateTime.now());

          //Save expense to database
          await context.read<WalletDatabase>().createNewWallet(newWallet);
          nameController.clear();
          amountController.clear();
          // refreshData();
        }
      },
      child: Text("Save"),
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