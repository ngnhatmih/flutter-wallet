import 'package:flutter/material.dart';

class TokenCard extends StatelessWidget {
  final String tokenName;
  final String balance;
  final String price;

  TokenCard({required this.tokenName, required this.balance, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(tokenName[0]),
        ),
        title: Text(tokenName),
        subtitle: Text('$balance tokens'),
        trailing: Text('\$$price'),
        onTap: () {
          // Navigate to token detail screen
        },
      ),
    );
  }
}
