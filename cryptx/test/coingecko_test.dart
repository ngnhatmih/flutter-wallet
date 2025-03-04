import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallet/services/coingecko_service.dart';
import 'dart:math';

void main() async {
  group('CoinGeckoService Tests', () {
    test('getPrice should return response with status 200 (return double)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"ethereum": {"usd": 3000}}', 200);
      });

      final coingeckoService = CoinGeckoService(mockClient);
      final rs = await coingeckoService.getCryptoPrice('ethereum', 'usd');

      expect(rs, isA<double>());
    });

    test('Performance test: API response time should be within limit', () async {
      final mockClient = MockClient((request) async {
        await Future.delayed(Duration(milliseconds: Random().nextInt(100))); // Giả lập độ trễ
        return http.Response('{"ethereum": {"usd": 3000}}', 200);
      });

      final coingeckoService = CoinGeckoService(mockClient);

      final stopwatch = Stopwatch()..start();
      await coingeckoService.getCryptoPrice('ethereum', 'usd');
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(200), reason: 'slow');
    });
  });
}
