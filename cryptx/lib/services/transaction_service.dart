import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet/models/transaction_model.dart';

class TransactionService {
  final String baseUrl = 'http://127.0.0.1:5000';  
  final http.Client client;

  TransactionService({http.Client? client}) : client = client ?? http.Client();

  Future<void> createTransaction(TransactionModel transaction) async {
    final url = Uri.parse('$baseUrl/transactions');
    
    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'from': transaction.from?.address,
          'to': transaction.to?.address,
          'amount': transaction.amount,
          'date': transaction.date,
          'tokenSymbol': transaction.tokenSymbol, // Thêm tokenSymbol vào payload
        }),
      );

      if (response.statusCode == 201) {
        print('Transaction created');
      } else {
        print('Failed to create transaction: ${response.body}');
      }
    } catch (e) {
      print('Error creating transaction: $e');
    }
  }

  Future<List<TransactionModel>> getTransactionsBySender(String sender) async {
    final url = Uri.parse('$baseUrl/transactions/sender/$sender');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<List<TransactionModel>> getTransactionsByRecipient(String recipient) async {
    final url = Uri.parse('$baseUrl/transactions/recipient/$recipient');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<List<TransactionModel>> getTransactionsByAddress(String address) async {
    final url = Uri.parse('$baseUrl/transactions/address/$address');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }
}
