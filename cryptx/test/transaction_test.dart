import 'package:wallet/models/transaction_model.dart';
import 'package:wallet/services/transaction_service.dart';

void main() async {
  final transactionService = TransactionService();

  final transaction = TransactionModel.fromString(
    '0x123abc', 
    '0x456def', 
    100.0, 
  );

  await transactionService.createTransaction(transaction);

  try {
    List<TransactionModel> senderTransactions = await transactionService.getTransactionsBySender('0x123abc');
    print('Sender Transactions:');
    for (var tx in senderTransactions) {
      print('From: ${tx.from}, To: ${tx.to}, Amount: ${tx.amount}');
    }
  } catch (e) {
    print('Error fetching sender transactions: $e');
  }

  try {
    List<TransactionModel> recipientTransactions = await transactionService.getTransactionsByRecipient('0x456def');
    print(recipientTransactions);
    print('Recipient Transactions:');
    for (var tx in recipientTransactions) {
      print('From: ${tx.from}, To: ${tx.to}, Amount: ${tx.amount}');
    }
  } catch (e) {
    print('Error fetching recipient transactions: $e');
  }

  try {
    List<TransactionModel> addressTransactions = await transactionService.getTransactionsByAddress('0x123abc');
    print('Address Transactions:');
    for (var tx in addressTransactions) {
      print('From: ${tx.from}, To: ${tx.to}, Amount: ${tx.amount}');
    }
  } catch (e) {
    print('Error fetching address transactions: $e');
  }
}
