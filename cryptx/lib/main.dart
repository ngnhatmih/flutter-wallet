import 'dart:io';
import 'dart:js_interop';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/screens/pass_screen.dart';
import 'screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

@JS('getPassword')
external String? getPassword();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EthereumProvider(),
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
      title: 'CryptX',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: FutureBuilder<bool>(
        future: _checkPasswordExists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return LoginScreen();
          } else {
            return PassScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkPasswordExists() async {
    try {
      if (kIsWeb) {
        final password = await _readPasswordFromWeb();
        return password != null;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/password.json');
        return file.exists();
      }
    } catch (e) {
      print('Error checking password: $e');
      return false;
    }
  }

  Future<String?> _readPasswordFromWeb() async {
    try {
      final password = getPassword();
      if (password != null) {
        return password;
      }
    } catch (e) {
      print('Error reading password from web: $e');
    }
    return null;
  }
}
