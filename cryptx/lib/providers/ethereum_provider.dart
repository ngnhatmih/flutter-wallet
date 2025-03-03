import 'dart:async';

import 'package:wallet/services/blockchain_service.dart';
import 'package:wallet/services/coingecko_service.dart';
import 'package:flutter/material.dart';
import 'package:wallet/services/transaction_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/models/wallet_model.dart';
import 'package:http/http.dart';
import 'package:wallet/models/transaction_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EthereumProvider extends ChangeNotifier {
  final EthereumService _ethereumService;
  final CoinGeckoService _coinGeckoService = CoinGeckoService();
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];

  List<WalletModel> _wallets = [
    WalletModel(
        privateKey: dotenv.env['DEFAULT_WALLET_PRIVATE_KEY'] ?? 'unknown'),
    WalletModel(
        privateKey: dotenv.env['DEFAULT_WALLET_PRIVATE_KEY2'] ?? 'unknown'),
  ];

  late WalletModel _walletModel;

  double _gasFee = 0.0;
  bool _isLoading = false;
  double? _priceChange = 0.0;
  Timer? _timer;

  EthereumProvider(String rpcUrl, Client httpClient)
      : _ethereumService = EthereumService(rpcUrl, httpClient) {
    _walletModel = _wallets[0];
  }

  WalletModel? get walletModel => _walletModel;
  bool get isLoading => _isLoading;
  double get gasFee => _gasFee;
  double? get priceChange => _priceChange;
  double? get balanceChange => _priceChange != null ? _walletModel.getBalance * _priceChange! / 100.0 : 0.0;
  List<TransactionModel> get transactions => _transactions;
  List<WalletModel> get wallets => _wallets;

  @override
  Future<void> dispose() async {
    super.dispose();
    _timer?.cancel();
  }

  Future<void> switchWallet(int index) async {
    _walletModel = _wallets[index];
    await fetchBalance();
    await loadTransactions();
    if (!isLoading) {
      notifyListeners();
    }
  }

  void fetchGasFee(String receiver, double ethAmount) async {
    try {
      var decimal = BigInt.from(10).pow(18);
      var amount = BigInt.from(decimal.toDouble() * ethAmount);
      var sender = EthereumAddress.fromHex(_walletModel.getAddress);
      var toAddress = EthereumAddress.fromHex(receiver);

      EtherAmount tmpGasFee = await _ethereumService.estimateGasFee(
          sender, toAddress, EtherAmount.inWei(amount));
      _gasFee = tmpGasFee.getValueInUnit(EtherUnit.ether);
      notifyListeners();
    } catch (e) {
      _gasFee = 0.0;
      notifyListeners();
    }
  }

  Future<void> sendTransaction(String receiver, double ethAmount) async {
    try {
      if (!_isLoading) {
        _isLoading = true;
        Future.microtask(() => notifyListeners());
      }

      var decimal = BigInt.from(10).pow(18);
      var amount = BigInt.from(decimal.toDouble() * ethAmount);
      var creds = EthPrivateKey.fromHex(_walletModel.getPrivateKey);
      var sender = EthereumAddress.fromHex(_walletModel.getAddress);
      var toAddress = EthereumAddress.fromHex(receiver);
      // var txHash =
      await _ethereumService.sendTransaction(
          creds, sender, toAddress, EtherAmount.inWei(amount));
      await _transactionService.createTransaction(TransactionModel(
        from: _walletModel,
        to: WalletModel(publicKey: receiver),
        amount: ethAmount,
      ));

      await fetchBalance();

      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> loadTransactions() async {
    _transactions = await _transactionService
        .getTransactionsByAddress(_walletModel.getAddress);
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    try {
      if (!_isLoading) {
        _isLoading = true;
        Future.microtask(() => notifyListeners());
      }

      EtherAmount ether = await _ethereumService
          .getBalance(EthereumAddress.fromHex(_walletModel.getAddress));
      double? priceEth =
          await _coinGeckoService.getCryptoPrice('ethereum', 'usd');

      _walletModel.setEtherAmount = ether.getValueInUnit(EtherUnit.ether);
      _walletModel.setBalance =
          priceEth != null ? _walletModel.getEtherAmount * priceEth : 0;

      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      rethrow;
    }
  }

  Future<void> fetchPriceChange() async {
    try {
      double? priceChange =
          await _coinGeckoService.getCryptoPriceChange('ethereum', 'usd');
      _priceChange = priceChange;
    } catch (e) {
      rethrow;
    }
  }

  void startAutoUpdateBalance() async {
    _timer = Timer.periodic(Duration(seconds: 600), (timer) async {
      await fetchBalance();
    });
  }

}
