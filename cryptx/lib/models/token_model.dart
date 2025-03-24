class TokenModel {
  String chainId;
  String symbol;
  int decimals;
  double balance;
  String address;

  TokenModel({
    required this.chainId,
    required this.symbol,
    required this.decimals,
    required this.balance,
    required this.address,
  });

  String get getChainId => chainId;
  String get getSymbol => symbol;
  int get getDecimals => decimals;
  double get getBalance => balance;
  String get getAddress => address;
}