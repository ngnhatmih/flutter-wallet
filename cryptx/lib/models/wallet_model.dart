import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/web3dart.dart';
import 'package:wallet/utils/seed.dart';

class WalletModel {
  late String? privateKey;
  late String? address;
  double balance = 0.0;
  double etherAmount = 0.0;
  
  WalletModel({this.privateKey,  String? publicKey}) {
    if (privateKey != null) {
      final credentials = EthPrivateKey.fromHex(privateKey!);
      address = credentials.address.hex; 
    } else if (publicKey != null) {
      address = publicKey;
    } else {
      throw Exception('PrivateKey or publicKey must be provided');
    }
  }

  factory WalletModel.fromMnemonic(String mnemonic) {
    var seed = bip39.mnemonicToSeed(mnemonic);
    var priv = seedToPrivateKey(seed);
    var creds = EthPrivateKey.fromHex(priv);
    return WalletModel(privateKey: priv, publicKey: creds.address.hex);
  }

  factory WalletModel.fromSeed(Uint8List seed) {
    var priv = seedToPrivateKey(seed);
    var creds = EthPrivateKey.fromHex(priv);
    return WalletModel(privateKey: priv, publicKey: creds.address.hex);
  }

  Map<String, dynamic> toJson() {
    return {
      'privkey': privateKey,
      'address': address,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      privateKey: json['privkey'],
      publicKey: json['address'],
    );
  }

  double get getBalance => balance;
  set setBalance(double value) => balance = value;

  double get getEtherAmount => etherAmount;
  set setEtherAmount(double value) => etherAmount = value;

  String get getAddress => address ?? 'unknown';
  String get getPrivateKey => privateKey ?? 'unknown';
}