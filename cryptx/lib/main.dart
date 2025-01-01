import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WalletProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HomePage with two options: Create New Wallet and Import Wallet
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Options'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                walletProvider.generateMnemonic();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewWalletPage(),
                  ),
                );
              },
              child: const Text('Create New Wallet'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Import Wallet page (not implemented yet)
              },
              child: const Text('Import Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}

// Page to display mnemonic with GridView and options
class NewWalletPage extends StatelessWidget {
  const NewWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final mnemonicWords = walletProvider.mnemonic?.split(' ') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Wallet'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: mnemonicWords.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mnemonicWords[index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '⚠ WARNING: Store this mnemonic securely. Anyone with this phrase can access your wallet.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle continue action (e.g., save wallet or navigate further)
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// WalletProvider to manage state
class WalletProvider extends ChangeNotifier {
  String? mnemonic;

  void generateMnemonic() {
    mnemonic = bip39.generateMnemonic();
    notifyListeners();
  }
}
