import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/models/wallet_model.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/utils/format.dart';
import 'package:wallet/screens/nav/_nav.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EthereumProvider ethereumProvider;
  int _currentIndex = 0;
  String? network;

  final List<Widget> _pages = [
    HomeScreen(),
    CollectionScreen(),
    HistoryScreen(),
    LastScreen()
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ethereumProvider = Provider.of<EthereumProvider>(context, listen: true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ethereumProvider.loadNetworks();
      setState(() {
        network = ethereumProvider.currentNetwork?['name'].toString();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var address = ethereumProvider.walletModel!.getAddress;
    List<ListTile> wallets = [];
    for (var i = 0; i < ethereumProvider.wallets.length; i++) {
      wallets.add(
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange[100],
            child: Icon(Icons.account_balance_wallet, color: Colors.orange),
          ),
          title: Text('Wallet ${i + 1}'),
          subtitle: Text(AddressFormat.formatAddress(ethereumProvider.wallets[i].address ?? '0x123...789')),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (ethereumProvider.wallets.length > 1) {
                setState(() {
                  ethereumProvider.wallets.removeAt(i);
                });
                ethereumProvider.saveVault(ethereumProvider.wallets); 
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Wallet ${i + 1} xóa thành công!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể xóa ví')),
                );
              }
            },
          ),
          onTap: () {
            ethereumProvider.switchWallet(i);
            Navigator.pop(context);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 280, // Set a fixed height for the modal
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    ...wallets,
                                  ],
                                ),
                              ),
                              Divider(), 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(icon: Icon(Icons.add, color: Colors.green),
                                      onPressed: () async {
                                        final newWalletData = await ethereumProvider.generateSeed();
                                        final newWallet = WalletModel.fromJson(newWalletData);

                                        setState(() {
                                          ethereumProvider.wallets.add(newWallet);
                                        });

                                        ethereumProvider.saveVault(ethereumProvider.wallets);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.download, color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            TextEditingController privateKeyController = TextEditingController();
                                            return AlertDialog(
                                              title: Text('Import Wallet'),
                                              content: TextField(
                                                controller: privateKeyController,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Private Key',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Close the dialog
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final privateKey = privateKeyController.text.trim();
                                                    if (privateKey.isNotEmpty) {
                                                      try {
                                                        // Create a new wallet using the private key
                                                        final newWallet = WalletModel(privateKey: privateKey);

                                                        setState(() {
                                                          ethereumProvider.wallets.add(newWallet);
                                                          ethereumProvider.switchWallet(ethereumProvider.wallets.length - 1);
                                                        });

                                                        ethereumProvider.saveVault(ethereumProvider.wallets);

                                                        Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Wallet imported successfully!')),
                                                        );
                                                      } catch (e) {
                                                        // Handle invalid private key
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Invalid private key!')),
                                                        );
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Private key cannot be empty!')),
                                                      );
                                                    }
                                                  },
                                                  child: Text('Import'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text('MW', style: TextStyle(color: Colors.orange)),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ví của tôi',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      AddressFormat.formatAddress(address),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton<String>(
                  value: network,
                  items: ethereumProvider.networkNames.map((String choice) {
                    return DropdownMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      setState(() {
                        network = newValue;
                      });
                      await ethereumProvider.switchNetwork(newValue);
                    }
                  },
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiveScreen(),
                      ),
                    );
                  },
                ),
                PopupMenuButton(
                  icon: Icon(Icons.settings),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Đăng xuất'),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Bộ sưu tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.network_check),
            label: 'Mạng lưới',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
