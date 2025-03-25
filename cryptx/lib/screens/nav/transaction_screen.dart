import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/utils/format.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late EthereumProvider ethereumProvider;
  final List<Map<String, dynamic>> transactions = [];

  Future<void> loadTransactions() async {
    if (mounted) {
      await ethereumProvider.loadTransactions();

      for (var transaction in ethereumProvider.transactions) {
        if (transaction.type == "transfer") {
          transactions.add({
            "type": transaction.to!.getAddress ==
                    ethereumProvider.walletModel!.getAddress
                ? "Nhận"
                : "Gửi",
            "amount": transaction.amount,
            "address": AddressFormat.formatAddress(transaction.to!.getAddress),
            "date": transaction.date,
            "status": "Thành công",
          });
        } else if (transaction.type == "swap") {
          transactions.add({
            "type": "Swap",
            "amount": transaction.amount,
            "address": "Uniswap",
            "date": transaction.date,
            "status": "Thành công",
          });
        }
      }

      transactions.sort((a, b) => b["date"].compareTo(a["date"]));

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ethereumProvider = Provider.of<EthereumProvider>(context, listen: false);
    ethereumProvider.loadTransactions();
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        await ethereumProvider.loadTransactions();
        for (var transaction in ethereumProvider.transactions) {
          transactions.add({
            "type": transaction.to!.getAddress.toLowerCase() ==
                    ethereumProvider.walletModel!.getAddress.toLowerCase()
                ? "Nhận"
                : "Gửi",
            "amount": transaction.amount,
            "tokenSymbol": transaction.tokenSymbol,
            "address": AddressFormat.formatAddress(transaction.to!.getAddress),
            "date": transaction.date,
            "status": "Thành công",
          });
        }

        transactions.sort((a, b) => b["date"].compareTo(a["date"]));
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Lịch sử giao dịch"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: transactions.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: transaction["type"] == "Gửi"
                    ? Colors.orange[100]
                    : transaction["type"] == "Nhận"
                        ? Colors.green[100]
                        : transaction["type"] == "Swap"
                            ? Colors.purple[100]
                            : Colors.blue[100],
                child: Icon(
                  transaction["type"] == "Gửi"
                      ? Icons.arrow_upward
                      : transaction["type"] == "Nhận"
                          ? Icons.arrow_downward
                          : transaction["type"] == "Swap"
                              ? Icons.swap_horiz 
                              : Icons.help_outline, 
                  color: transaction["type"] == "Gửi"
                      ? Colors.orange
                      : transaction["type"] == "Nhận"
                          ? Colors.green
                          : transaction["type"] == "Swap"
                              ? Colors.purple // Add a new color for "Swap"
                              : Colors.blue,
                ),
              ),
              title: Text(
                "${transaction["type"]} ${transaction["amount"]} ${transaction["tokenSymbol"]}", // Display tokenSymbol
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Địa chỉ: ${transaction["address"]}\nNgày: ${transaction["date"]}",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Text(
                transaction["status"],
                style: TextStyle(
                  color: transaction["status"] == "Thành công"
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // Add handling when tapping on a transaction
              },
            );
          },
        ),
      ),
    );
  }
}
