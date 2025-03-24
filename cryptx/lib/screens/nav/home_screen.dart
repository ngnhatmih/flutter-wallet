import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/screens/nav/_nav.dart';
import 'package:wallet/widgets/token_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late EthereumProvider ethereumProvider;
  late List<TokenCard> tokenCards;
  TextEditingController tokenAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ethereumProvider.fetchBalance();
      ethereumProvider.fetchPriceChange();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ethereumProvider = Provider.of<EthereumProvider>(context);
  }

  @override
  void dispose() {
    tokenAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ethereumProvider.isLoading
                  ? CircularProgressIndicator()
                  : ethereumProvider.walletModel?.getBalance != null
                      ? Text(
                          '\$${ethereumProvider.walletModel?.getBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )
                      : Text('NaN'),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ethereumProvider.balanceChange?.toStringAsFixed(2) ?? "NaN",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '(${ethereumProvider.priceChange?.toStringAsFixed(2) ?? "NaN"}%)',
                    style: TextStyle(
                      fontSize: 16,
                      color: (ethereumProvider.priceChange ?? 0.0) > 0
                          ? const Color.fromARGB(255, 0, 200, 0)
                          : const Color.fromARGB(255, 200, 0, 0),
                      backgroundColor: const Color.fromARGB(255, 215, 215, 215),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút Nhận
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReceiveScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          padding:
                              EdgeInsets.all(12), // Kích thước padding cân bằng
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.orange,
                            size: 24, // Kích thước icon nhỏ hơn
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nhận',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // Nút Gửi
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SendScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gửi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // Nút Đổi
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SwapScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.swap_horiz,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Đổi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  // Nút Mua
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BuyAndSellScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8, // Set the width of the dialog
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Import Token',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: tokenAddressController,
                                    decoration: InputDecoration(
                                      labelText: 'Token Address',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: CircularProgressIndicator(),
                                              );
                                            },
                                          );
                                          await ethereumProvider.importToken(tokenAddressController.text);
                                          setState(() {}); // Trigger a rebuild to show the imported token
                                          Navigator.of(context).pop(); // Close the loading dialog
                                          Navigator.of(context).pop(); // Close the import token dialog
                                        },
                                        child: Text('Import'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Import Token'),
                  ),
                ),
                SizedBox(height: 16),
                TokenCard(
                  tokenName: ethereumProvider.currentNetwork?['currencySymbol'] ?? 'ETH',
                  balance: "${ethereumProvider.walletModel?.getEtherAmount.toStringAsFixed(3)}",
                  price: "${ethereumProvider.walletModel?.getBalance.toStringAsFixed(3)}",
                ),
                FutureBuilder<List<TokenCard>>(
                  future: ethereumProvider.getTokens(ethereumProvider.currentNetwork?['chainId'].toString() ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Column(
                        children: snapshot.data!,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
