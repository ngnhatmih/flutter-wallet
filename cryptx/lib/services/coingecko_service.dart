import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoinGeckoService {
  final http_client;
  late final String apiKey;
  late final String root;
  late final String baseUrl;
  late final headers;
  static const Map<String, String> cryptoMapping = {
    "ETH": "ethereum",
    "SepoliaETH": "ethereum",
    "BNB": "binancecoin",
    "MATIC": "matic-network",
    "SOL": "solana",
    "USD₮0": "tether",
    "USDT": "tether",
  };


  CoinGeckoService(this.http_client) {
    apiKey = dotenv.env['COINGECKO_API_KEY'] ?? '';
    root = apiKey.isEmpty ? "https://api.coingecko.com" : "https://pro-api.coingecko.com";
    baseUrl = "$root/api/v3";
    headers = {
      "X-Requested-With": "XMLHttpRequest",
      "x-cg-pro-api-key": apiKey,
    };
  }

  Future<double?> getCryptoPrice(String symbol, String currency) async {
    if (!cryptoMapping.containsKey(symbol)) {
      return 0.0;
    }

    final cryptoId = cryptoMapping[symbol.toUpperCase()];
    final url = Uri.parse("$baseUrl/simple/price?ids=$cryptoId&vs_currencies=$currency");

    try {
      final response = await http_client.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data[cryptoId]?[currency] as num?)?.toDouble();
      }
    } catch (e) {
      print("Failed to fetch crypto price: ${e.toString()}");
    }

    return 0.0;
  }

  Future<double?> getCryptoPriceChange(String symbol, String currency) async {
    if (!cryptoMapping.containsKey(symbol)) {
      return 0.0;
    }

    final cryptoId = cryptoMapping[symbol.toUpperCase()];
    final url = Uri.parse("$baseUrl/simple/price?ids=$cryptoId&vs_currencies=$currency&include_24hr_change=true");

    try {
      final response = await http_client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data[cryptoId]?["usd_24h_change"] as num?)?.toDouble();
      } 
    } catch (e) {
      print("Failed to fetch crypto price change: ${e.toString()}");
    }

    return 0.0;
  }

  Future<String> getCryptoIcon(String symbol) async {
    if (!cryptoMapping.containsKey(symbol)) {
      return "";
    }

    final cryptoId = cryptoMapping[symbol.toUpperCase()];
    final url = Uri.parse("$baseUrl/coins/$cryptoId");

    final response = await http_client.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["image"]["small"];
    } else {
      throw Exception("Failed to fetch crypto logo: ${response.statusCode}");
    }
  }
}
