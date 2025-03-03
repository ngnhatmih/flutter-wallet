import 'package:web3dart/web3dart.dart';

class WalletModel {
  final String? privateKey;
  late String? address;
  double balance = 0.0;
  double etherAmount = 0.0;
  
  WalletModel({this.privateKey, String? publicKey}) {
    if (privateKey != null) {
      final credentials = EthPrivateKey.fromHex(privateKey!);
      address = credentials.address.hex;
    } else if (publicKey != null) {
      address = publicKey;
    } else {
      throw Exception('PrivateKey or publicKey must be provided');
    }
  }

  double get getBalance => balance;
  set setBalance(double value) => balance = value;

  double get getEtherAmount => etherAmount;
  set setEtherAmount(double value) => etherAmount = value;

  String get getAddress => address ?? 'unknown';
  String get getPrivateKey => privateKey ?? 'unknown';
}