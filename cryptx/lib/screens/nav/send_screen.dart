import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/utils/format.dart';

class SendScreen extends StatefulWidget {
  @override
  SendScreenState createState() => SendScreenState();
}

class SendScreenState extends State<SendScreen> {
  late List<String> tokens;
  late String selectedToken;

  TextEditingController amountController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  double transactionFee = 0.0;

  bool isValidInput() {
    if (amountController.text.isEmpty || addressController.text.isEmpty) {
      return false;
    }

    if (double.tryParse(amountController.text) == null) {
      return false;
    }

    return true;
  }

  late EthereumProvider ethereumProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ethereumProvider = Provider.of<EthereumProvider>(context, listen: false);
    ethereumProvider.fetchBalance();
    ethereumProvider.fetchPriceChange();
    ethereumProvider.startAutoUpdateBalance();

    tokens = [ethereumProvider.currentNetwork?['currencySymbol'], "USDT"];
    selectedToken = tokens.first;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gửi tiền mã hóa"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<EthereumProvider>(
          builder: (context, ethereumProvider, child) {
            if (ethereumProvider.currentNetwork == null) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Số dư: ${ethereumProvider.walletModel?.getEtherAmount} ${ethereumProvider.currentNetwork?['currencySymbol'] ?? ''}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Chọn loại tiền",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedToken,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                    underline: SizedBox(),
                    items: tokens.map((String token) {
                      return DropdownMenuItem<String>(
                        value: token,
                        child: Text(token),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedToken = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Địa chỉ ví nhận",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: "Nhập địa chỉ ví hoặc quét mã QR",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (_) {
                          if (isValidInput()) {
                            ethereumProvider.fetchGasFee(addressController.text.toLowerCase(),
                                double.parse(amountController.text));
                            setState(() {
                              transactionFee = ethereumProvider.gasFee;
                            });
                          } else {
                            setState(() {
                              transactionFee = 0.0;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner, color: Colors.orange),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  "Số lượng gửi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Nhập số lượng tiền mã hóa",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) {
                    if (isValidInput()) {
                      ethereumProvider.fetchGasFee(addressController.text,
                          double.parse(amountController.text));
                      setState(() {
                        transactionFee = ethereumProvider.gasFee;
                      });
                    } else {
                      setState(() {
                        transactionFee = 0.0;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Chi phí giao dịch: $transactionFee ${ethereumProvider.currentNetwork?['symbol'] ?? ''}",
                  style: TextStyle(color: Colors.grey),
                ),
                Divider(),
                SizedBox(height: 16),
                Text(
                  "Chi tiết giao dịch",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loại tiền: $selectedToken",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Ví nhận: ${addressController.text.isEmpty ? 'Chưa nhập' : AddressFormat.formatAddress(addressController.text)}",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Số lượng: ${amountController.text.isEmpty ? 'Chưa nhập' : amountController.text} $selectedToken",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Chi phí giao dịch: $transactionFee ${ethereumProvider.currentNetwork?['symbol'] ?? ''}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (isValidInput()) {
                      ethereumProvider.sendTransaction(
                        addressController.text.toLowerCase(),
                        double.parse(amountController.text),
                        tokenSymbol: selectedToken, // Truyền tokenSymbol
                      );
                      amountController.clear();
                      addressController.clear();
                      setState(() {
                        transactionFee = 0.0;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Giao dịch thành công"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Gửi ngay",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
