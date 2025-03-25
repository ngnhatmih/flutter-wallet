import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:wallet/screens/login_screen.dart';


@JS('savePassword')
external void savePassword(String password);

class PassScreen extends StatefulWidget {
  @override
  _PassScreenState createState() => _PassScreenState();
}

class _PassScreenState extends State<PassScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _savePassword(String password) async {
    try {
      if (kIsWeb) {
        await _savePasswordToWeb(password);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/password.json');
        final passwordData = jsonEncode({"password": password});
        await file.writeAsString(passwordData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      
    } catch (e) {
      print('Error saving password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save password: $e')),
      );
    }
  }

  Future<void> _savePasswordToWeb(String password) async {
    try {
      savePassword(password);
    } catch (e) {
      print('Error saving password to web: $e');
    }
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tạo mật khẩu mới",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true, // Hide the password input
              decoration: InputDecoration(
                labelText: 'Nhập mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true, // Hide the password input
              decoration: InputDecoration(
                labelText: 'Nhập lại mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Mật khẩu phải có ít nhất 8 ký tự.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final password = _passwordController.text;
                final confirmPassword = _confirmPasswordController.text;

                if (!_isPasswordValid(password)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu phải có ít nhất 8 ký tự.')),
                  );
                  return;
                }

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mật khẩu không khớp.')),
                  );
                  return;
                }

                _savePassword(password);

              },
              child: Text('Tạo mật khẩu'),
            ),
          ],
        ),
      ),
    ));
  }
}
