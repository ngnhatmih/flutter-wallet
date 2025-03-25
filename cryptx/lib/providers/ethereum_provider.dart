import 'dart:async';
import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/services.dart' show rootBundle;
import 'package:wallet/services/blockchain_service.dart';
import 'package:wallet/services/coingecko_service.dart';
import 'package:flutter/material.dart';
import 'package:wallet/services/transaction_service.dart';
import 'package:wallet/utils/seed.dart';
import 'package:wallet/widgets/token_card.dart';
import 'package:web3dart/web3dart.dart';
import 'package:wallet/models/wallet_model.dart';
import 'package:wallet/models/token_model.dart';
import 'package:http/http.dart';
import 'package:wallet/models/transaction_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js_interop';

@JS('getPassword')
external String? getPassword();

@JS('saveToSecureStorage')
external void saveToSecureStorage(String key, String value, String password);

@JS('getFromSecureStorage')
external  JSPromise<JSString?> getFromSecureStorage(String key, String password);

class EthereumProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TokenModel> _tokens = [];
  List<WalletModel> _wallets = [
    WalletModel(
        privateKey: dotenv.env['DEFAULT_WALLET_PRIVATE_KEY'] ?? 'unknown'),
    WalletModel(
        privateKey: dotenv.env['DEFAULT_WALLET_PRIVATE_KEY2'] ?? 'unknown'),
  ];

  late WalletModel _walletModel;
  late EthereumService _ethereumService;
  final CoinGeckoService _coinGeckoService = CoinGeckoService(Client());

  double _gasFee = 0.0;
  bool _isLoading = false;
  double? _priceChange = 0.0;
  Timer? _timer;

  List<Map<String, dynamic>> networks = [];
  Map<String, dynamic>? _currentNetwork;

  EthereumProvider() {
    _walletModel = _wallets[0];
    loadNetworks();
    final String? password = getPassword();
    if (password != null) {
      loadVault().then((wl) {
        _wallets = wl;
        _walletModel = _wallets[0];
        saveVault(_wallets);
      });
    }
  }

  Future<List<WalletModel>> loadVault() async {
    final pw = getPassword()!;
    List<WalletModel> wl = [];
    var a = await getFromSecureStorage("vault", pw).toDart;
    if (a != null) {
      final List<dynamic> data = jsonDecode(a.toString());
      wl = data.map((wallet) => WalletModel.fromJson(wallet)).toList().cast<WalletModel>();
    } else {
      var e = await generateSeed();
      var w = WalletModel.fromJson(e);
      wl.add(w);
    }

    return wl;
  }

  void saveVault(List<WalletModel> wls) async {
    final pw = getPassword()!;
    for (WalletModel wl in wls) {
      print(wl.getAddress);
    }
    final wljson = jsonEncode(wls.map((e) => e.toJson()).toList());
    saveToSecureStorage("vault", wljson, pw);
  }

  WalletModel? get walletModel => _walletModel;
  bool get isLoading => _isLoading;
  double get gasFee => _gasFee;
  double? get priceChange => _priceChange;
  double? get balanceChange => _priceChange != null ? _walletModel.getBalance * _priceChange! / 100.0 : 0.0;
  List<TransactionModel> get transactions => _transactions;
  List<WalletModel> get wallets => _wallets;
  List<TokenModel> get tokens => _tokens;
  Map<String, dynamic>? get currentNetwork => _currentNetwork;
  List<String> get networkNames => networks.map((n) => n['name'] as String).toList();

  Future<void> loadNetworks() async {
    final String response = await rootBundle.loadString('assets/networks.json');  
    final data = await json.decode(response);
    networks = List<Map<String, dynamic>>.from(data['networks']);
    _currentNetwork ??= networks.first;
    _ethereumService = EthereumService(_currentNetwork!['rpcUrl'], _currentNetwork!['chainId'], Client());
    await _ethereumService.loadABI();
    notifyListeners();
  }

  Future<void> switchNetwork(String networkName) async {
    _currentNetwork = networks.firstWhere((network) => network['name'] == networkName);
    _ethereumService = EthereumService(_currentNetwork!['rpcUrl'], _currentNetwork!['chainId'], Client());
    await _ethereumService.loadABI();
    await fetchBalance();
    await loadTransactions();
    notifyListeners();
  }

  void switchWallet(int index) {
    if (index >= 0 && index < _wallets.length) {
      _walletModel = _wallets[index];
      notifyListeners();
    }
  }

  void addWallet(WalletModel wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }

  void removeWallet(int index) {
    if (index >= 0 && index < _wallets.length) {
      _wallets.removeAt(index);
      if (_wallets.isNotEmpty) {
        _walletModel = _wallets[0];
      }
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _timer?.cancel();
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

  Future<void> sendTransaction(String receiver, double ethAmount, {String tokenSymbol = 'ETH'}) async {
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

      // Gửi giao dịch
      var txHash = await _ethereumService.sendTransaction(
        creds,
        sender,
        toAddress,
        EtherAmount.inWei(amount),
      );
      print('txHash: $txHash');

      // Tạo giao dịch mới với thông tin token
      await _transactionService.createTransaction(TransactionModel(
        from: _walletModel,
        to: WalletModel(publicKey: receiver),
        amount: ethAmount,
        tokenSymbol: tokenSymbol, // Truyền tokenSymbol
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

      double? price =
          await _coinGeckoService.getCryptoPrice(currentNetwork?['currencySymbol'] ?? '', 'usd');

      _walletModel.setEtherAmount = ether.getValueInUnit(EtherUnit.ether);
      var sum =
          price != null ? _walletModel.getEtherAmount * price : 0;

      for (TokenModel token in _tokens) {
        EtherAmount balance = await _ethereumService.getAmount(
            EthereumAddress.fromHex(token.address),
            EthereumAddress.fromHex(_walletModel.getAddress));
        token.balance = balance.getValueInUnit(EtherUnit.ether);
        var decimal = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(token.address));
        var price = await _coinGeckoService.getCryptoPrice(token.symbol, 'usd') ?? 0.0;
        sum += balance.getValueInUnit(EtherUnit.wei) / BigInt.from(10).pow(decimal).toDouble() * price;
      }

      _walletModel.setBalance = sum.toDouble();

      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> fetchPriceChange() async {
    try {
      double? priceChange =
          await _coinGeckoService.getCryptoPriceChange(currentNetwork?['currencySymbol'] ?? '', 'usd');
      _priceChange = priceChange;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> fetchCryptoIcon(String symbol) async {
    try {
      return await _coinGeckoService.getCryptoIcon(symbol);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> importToken(String address) async {
    try {
      final EthereumAddress tokenAddress = EthereumAddress.fromHex(address);
      final String symbol = await _ethereumService.getTokenSymbol(tokenAddress);
      final int decimals = await _ethereumService.getTokenDecimals(tokenAddress);
      final EtherAmount balance = await _ethereumService.getAmount(tokenAddress, EthereumAddress.fromHex(_walletModel.getAddress));
      final TokenModel token = TokenModel(
        chainId: _currentNetwork!['chainId'].toString(),
        symbol: symbol,
        decimals: decimals,
        balance: balance.getValueInUnit(EtherUnit.ether),
        address: address,
      );
      _tokens.add(token);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TokenCard>> getTokens(String chainId) async {
    List<TokenCard> tokenCards = [];
    for (TokenModel token in _tokens) {
      if (token.chainId == chainId) {
        var symbol = token.symbol;
        var balance = token.balance;
        var price = await _coinGeckoService.getCryptoPrice(symbol, 'usd') ?? 0.0;
        tokenCards.add(TokenCard(
          tokenName: symbol,
          balance: balance.toStringAsFixed(3),
          price: price.toStringAsFixed(3),
        ));
      }
    }

    return tokenCards;
  }

  void startAutoUpdateBalance() async {
    _timer = Timer.periodic(Duration(seconds: 600), (timer) async {
      await fetchBalance();
    });
  }

  Future<Map<String, String>> generateSeed() async {
    final mnemonic = bip39.generateMnemonic();
    final seed = bip39.mnemonicToSeed(mnemonic);
    final wallet = EthPrivateKey.fromHex(seedToPrivateKey(seed));
    final address = wallet.address;
    var data = {
      'mnemonic': mnemonic,
      'privkey': seedToPrivateKey(seed),
      'address': address.hex,
    };

    return data;
  }
  
}
