import 'package:flutter/services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wallet/main.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/screens/home_page.dart';
import 'package:wallet/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wallet/screens/nav/_nav.dart';

Future<void> returnToHomeScreen(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  expect(find.byType(HomeScreen), findsOneWidget);
}

Future<void> login(WidgetTester tester) async {
  final mockHttpClient = MockClient((request) async {
    return http.Response('{}', 200);
  });

  final mockCoinGeckoClient = MockClient((request) async {
    return http.Response('{}', 200);
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EthereumProvider(
              dotenv.env['RPC_URL'] ?? 'http://127.0.0.1:7545', mockHttpClient, mockCoinGeckoClient),
        ),
      ],
      child: MyApp(),
    ),
  );

  await tester.enterText(find.byType(TextField).first, 'admin123');
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    dotenv.testLoad(fileInput: '''
      RPC_URL=HTTP://127.0.0.1:7545
      COINGECKO_API_KEY=
      MONGO_DB_CONNECTION_STRING=mongodb+srv://ngn:123@cluster0.ilq9j.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
      DEFAULT_WALLET_PRIVATE_KEY=0xdfeffa270874bdf6509fcf6ef8c67d5ec5bdf152de43d6a9533b9cb500ff0381
      DEFAULT_WALLET_PRIVATE_KEY2=0x58b171b308473410fffbfa598c4856751d1974c0a87d37e7f016db8eb285f7e8
    ''');
  });

  group('MyApp Tests', () {
    testWidgets('MyApp starts and displays LoginScreen', (WidgetTester tester) async {
      // Mock HttpClient
      final mockHttpClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final mockCoinGeckoClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => EthereumProvider(
                  dotenv.env['RPC_URL'] ?? 'http://127.0.0.1:7545', mockHttpClient, mockCoinGeckoClient),
            ),
          ],
          child: MyApp(),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Đăng nhập'), findsNWidgets(1));
    });

    testWidgets('Login', (WidgetTester tester) async {
      await login(tester);

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Nav', (WidgetTester tester) async {
      await login(tester);

      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiveScreen), findsOneWidget);

      await returnToHomeScreen(tester);

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(find.byType(SendScreen), findsOneWidget);

      await returnToHomeScreen(tester);

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();

      expect(find.byType(SwapScreen), findsOneWidget);

      await returnToHomeScreen(tester);

      expect(find.byType(HomeScreen), findsOneWidget);

      List<IconData> icons = [Icons.home, Icons.grid_view, Icons.history, Icons.network_check];
      List<Type> screens = [HomeScreen, CollectionScreen, HistoryScreen, LastScreen];

      for (var i = 0; i < icons.length; i++) {
        await tester.tap(find.byIcon(icons[i]));
        await tester.pumpAndSettle();

        expect(find.byType(screens[i]), findsOneWidget);
      }

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      await tester.tap(find.text("MW"));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Ví 2"));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_downward));
      await tester.pumpAndSettle();

      expect(find.byType(ReceiveScreen), findsOneWidget);

      await tester.tap(find.text("Sao chép địa chỉ"));
      await tester.pumpAndSettle();
    });
  });
}