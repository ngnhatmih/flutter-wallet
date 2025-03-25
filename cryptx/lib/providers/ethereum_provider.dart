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

      loadTokens().then((tl) {
        _tokens = tl;
        saveTokens(_tokens);
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

  Future<List<TokenModel>> loadTokens() async {
    final pw = getPassword()!;
    List<TokenModel> tl = [];
    var a = await getFromSecureStorage("tokens", pw).toDart;
    if (a != null) {
      final List<dynamic> data = jsonDecode(a.toString());
      print(data);
      tl = data.map((token) => TokenModel.fromJson(token)).toList().cast<TokenModel>();
    }

    return tl;
  }

  void saveTokens(List<TokenModel> tls) async {
    final pw = getPassword()!;
    final tljson = jsonEncode(tls.map((e) => e.toJson()).toList());
    
    saveToSecureStorage("tokens", tljson, pw);
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
  
  List<TokenModel> get tokensByChainId => _tokens.where((token) => token.chainId == _currentNetwork?['chainId'].toString()).toList();

  Future<void> loadNetworks() async {
    final String response = await rootBundle.loadString('assets/networks.json');  
    final data = await json.decode(response);
    networks = List<Map<String, dynamic>>.from(data['networks']);
    _currentNetwork ??= networks.first;
    _ethereumService = EthereumService(_currentNetwork!['rpcUrl'], _currentNetwork!['chainId'], Client());
    await _ethereumService.loadABI();
    await _ethereumService.loadUniswapABI();

    notifyListeners();
  }

  Future<void> switchNetwork(String networkName) async {
    _currentNetwork = networks.firstWhere((network) => network['name'] == networkName);
    _ethereumService = EthereumService(_currentNetwork!['rpcUrl'], _currentNetwork!['chainId'], Client());
    await _ethereumService.loadABI();
    await _ethereumService.loadUniswapABI();
    await fetchBalance();
    await loadTransactions();
    notifyListeners();
  }

  void switchWallet(int index) async {
    if (index >= 0 && index < _wallets.length) {
      _walletModel = _wallets[index];
      await fetchBalance();
      await fetchPriceChange();

      saveTokens(_tokens);
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
      if (tokenSymbol != _currentNetwork?['currencySymbol']) {
        var tkaddress = _tokens.firstWhere((token) => token.symbol == tokenSymbol).address;
        await sendTokenTransaction(receiver, ethAmount, tkaddress, tokenSymbol);
        return;
      }

      var decimal = BigInt.from(10).pow(18);
      var amount = BigInt.from(decimal.toDouble() * ethAmount);
      var creds = EthPrivateKey.fromHex(_walletModel.getPrivateKey);
      var sender = EthereumAddress.fromHex(_walletModel.getAddress);
      var toAddress = EthereumAddress.fromHex(receiver);

      var txHash = await _ethereumService.sendTransaction(
        creds,
        sender,
        toAddress,
        EtherAmount.inWei(amount),
      );
      print('txHash: $txHash');

      await _transactionService.createTransaction(TransactionModel(
        from: _walletModel,
        to: WalletModel(publicKey: receiver),
        amount: ethAmount,
        tokenSymbol: tokenSymbol,
        type: 'transfer',
      ));

      await fetchBalance();

      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> sendTokenTransaction(
    String receiver,
    double tokenAmount,
    String tokenAddress,
    String tokenSymbol
) async {
  try {
    if (!_isLoading) {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
    }
    final decimals = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(tokenAddress));
    final amount = BigInt.from(tokenAmount * BigInt.from(10).pow(decimals).toDouble());
    final creds = EthPrivateKey.fromHex(_walletModel.getPrivateKey);
    final toAddress = EthereumAddress.fromHex(receiver);
    final tokenContractAddress = EthereumAddress.fromHex(tokenAddress);

    await _ethereumService.transferToken(
      creds,
      tokenContractAddress,
      toAddress,
      amount,
    );

    await _transactionService.createTransaction(TransactionModel(
      from: _walletModel,
      to: WalletModel(publicKey: receiver),
      amount: tokenAmount,
      tokenSymbol: tokenSymbol,
      type: 'transfer',
    ));

    await fetchBalance();

    _isLoading = false;
    Future.microtask(() => notifyListeners());
  } catch (e) {
    print('Error sending token transaction: $e');
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

        
        var decimal = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(token.address));
        token.balance = balance.getValueInUnit(EtherUnit.wei) / BigInt.from(10).pow(decimal).toDouble();
        var price = await _coinGeckoService.getCryptoPrice(token.symbol, 'usd') ?? 0.0;
        
        sum += token.balance * price;
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
      saveTokens(_tokens);
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
          price: (price * balance).toStringAsFixed(3),
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
  
  Future<void> swapTokens({
    required String tokenInAddress,
    required String tokenOutAddress,
    required double amountIn,
    required double amountOutMin,
    required String recipientAddress,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      bool isTokenInPrimary = tokenInAddress == "primary";
      bool isTokenOutPrimary = tokenOutAddress == "primary";

      final wrappedTokenAddress = _currentNetwork?['wrappedTokenAddress'];
      final tokenIn = isTokenInPrimary ? wrappedTokenAddress.toLowerCase() : tokenInAddress.toLowerCase();
      final tokenOut = isTokenOutPrimary ? wrappedTokenAddress.toLowerCase() : tokenOutAddress.toLowerCase();

      final decimalsIn = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(tokenIn));
      final decimalsOut = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(tokenOut));
      final amountInWei = BigInt.from(amountIn * BigInt.from(10).pow(decimalsIn).toDouble());
      final amountOutMinWei = BigInt.from(amountOutMin * BigInt.from(10).pow(decimalsOut).toDouble());

      final path = isTokenInPrimary
          ? [
              EthereumAddress.fromHex(wrappedTokenAddress),
              EthereumAddress.fromHex(tokenOut),
            ]
          : isTokenOutPrimary
              ? [
                  EthereumAddress.fromHex(tokenIn),
                  EthereumAddress.fromHex(wrappedTokenAddress),
                ]
              : [
                  EthereumAddress.fromHex(tokenIn),
                  EthereumAddress.fromHex(tokenOut),
                ];

      final deadline = BigInt.from(DateTime.now().millisecondsSinceEpoch ~/ 1000 + 600);
      final recipient = EthereumAddress.fromHex(recipientAddress);

      final uniswapContractAddress = EthereumAddress.fromHex(_currentNetwork?['uniswap_ca']);

      String txHash;
      if (isTokenInPrimary) {
        txHash = await _ethereumService.swapExactETHForTokens(
          credentials: EthPrivateKey.fromHex(_walletModel.getPrivateKey),
          amountOutMin: amountOutMinWei,
          path: path,
          to: recipient,
          deadline: deadline,
          uniswapContractAddress: uniswapContractAddress,
          value: amountInWei,
        );
      } else if (isTokenOutPrimary) {
        txHash = await _ethereumService.swapExactTokensForETH(
          credentials: EthPrivateKey.fromHex(_walletModel.getPrivateKey),
          amountIn: amountInWei,
          amountOutMin: amountOutMinWei,
          path: path,
          to: recipient,
          deadline: deadline,
          uniswapContractAddress: uniswapContractAddress,
        );
      } else {
        txHash = await _ethereumService.swapTokens(
          credentials: EthPrivateKey.fromHex(_walletModel.getPrivateKey),
          amountIn: amountInWei,
          amountOutMin: amountOutMinWei,
          path: path,
          to: recipient,
          deadline: deadline,
          uniswapContractAddress: uniswapContractAddress,
        );
      }
      final symbolIn = isTokenInPrimary ? _currentNetwork!['currencySymbol'] : tokenInAddress;
      final symbolOut = isTokenOutPrimary ? _currentNetwork!['currencySymbol'] : tokenOutAddress;

      await _transactionService.createTransaction(TransactionModel(
        from: _walletModel,
        to: WalletModel(publicKey: recipientAddress),
        amount: amountIn,
        tokenSymbol: "$symbolIn -> $symbolOut",
        type: 'swap',
      ));

      print("Swap Transaction Hash: $txHash");

      await fetchBalance();
    } catch (e) {
      print("Error during token swap: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> calculateAmountOut({
    required double amountIn,
    required String tokenInAddress,
    required String tokenOutAddress,
  }) async {
    bool isTokenInPrimary = tokenInAddress == "primary";
    bool isTokenOutPrimary = tokenOutAddress == "primary";

    final wrappedTokenAddress = _currentNetwork?['wrappedTokenAddress'];
    final tokenIn = isTokenInPrimary ? wrappedTokenAddress : tokenInAddress;
    final tokenOut = isTokenOutPrimary ? wrappedTokenAddress : tokenOutAddress;

    final decimalsIn = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(tokenIn.toLowerCase()));
    final amountInWei = BigInt.from(amountIn * BigInt.from(10).pow(decimalsIn).toDouble());
    final path = [
      EthereumAddress.fromHex(tokenIn.toLowerCase()),
      EthereumAddress.fromHex(tokenOut.toLowerCase()),
    ];

    final uniswapContractAddress = EthereumAddress.fromHex(_currentNetwork?['uniswap_ca']);
    final decimalsOut = await _ethereumService.getTokenDecimals(EthereumAddress.fromHex(tokenOut.toLowerCase()));
    final rs = await _ethereumService.getAmountOut(
      amountIn: amountInWei,
      path: path,
      uniswapContractAddress: uniswapContractAddress,
    );

    return rs.toDouble() / BigInt.from(10).pow(decimalsOut).toDouble();
  }
}
