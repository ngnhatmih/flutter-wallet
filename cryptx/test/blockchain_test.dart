import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/services/blockchain_service.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  late EthereumService ethereumService;
  late String rpcUrl;
  late http.Client httpClient;
  late EthereumAddress address;
  late EthPrivateKey creds;
  var transactionHash = '';
  late BigInt amount;
  final decimal = BigInt.from(10).pow(18);

  setUp(() {
    httpClient = http.Client();
    rpcUrl = 'http://127.0.0.1:7545';
    ethereumService = EthereumService(rpcUrl, 1337, httpClient);

    creds = EthPrivateKey.fromHex('0x094825cdc585aa3f12e6b1b5ebea562c20e57a3ea0c51b517f76d77f2441e681');
    address = creds.address;
    amount = BigInt.from(decimal.toDouble() * 0.001);
  });

  test('getBalance', () async {
    final balance = await ethereumService.getBalance(EthereumAddress.fromHex("0x889B5247ed15fD85fb160aEF624e8977336e3749"));
    print(balance.getInEther);
    // expect(balance.getInEther, BigInt.from(100));
  });

  test('gasFee', () async {
    final receiver = EthereumAddress.fromHex("0x6457738Ce3D36Cc18306a7d967b2687303677a12");
    final gasFee = await ethereumService.estimateGasFee(address, receiver,  EtherAmount.inWei(amount));
    print(gasFee.getValueInUnit(EtherUnit.ether));
    expect(gasFee.getInEther, BigInt.from(0));
  });

  test('sendTransaction', () async {
    final receiver = EthereumAddress.fromHex("0x6457738Ce3D36Cc18306a7d967b2687303677a12");
    transactionHash = await ethereumService.sendTransaction(creds, address, receiver,  EtherAmount.inWei(amount));
    print(transactionHash);
  });

  test("check transaction", () async {
    final tx = await ethereumService.getTransaction(transactionHash);
    final txInfo = {
      "blockHash": tx?.blockHash,
      "blockNumber": tx?.blockNumber,
      "from": tx?.from,
      "to": tx?.to,
      "value": tx?.value,
      "gasPrice": tx?.gasPrice,
      "gas": tx?.gas,
      "input": tx?.input,
      "nonce": tx?.nonce,
      "transactionIndex": tx?.transactionIndex,
      "v": tx?.v,
      "r": tx?.r,
      "s": tx?.s,
    };

    print(txInfo);
  });

  test("bigint", () {
    final test = BigInt.from(1.5);
    print(test);
  });
}