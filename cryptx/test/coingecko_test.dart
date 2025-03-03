import 'package:wallet/services/coingecko_service.dart';

void main() async {
  final coinGeckoService = CoinGeckoService();
  final market = await coinGeckoService.getCryptoPrice("ethereum", "usd");
  print(market);
}