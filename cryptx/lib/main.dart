import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'package:http/http.dart' as http;

void main() async {
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EthereumProvider(
              dotenv.env['RPC_URL'] ?? 'http://127.0.0.1:7545', http.Client(), http.Client()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: LoginScreen(),
    );
  }
}
