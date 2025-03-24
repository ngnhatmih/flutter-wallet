import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

const String rpcUrl = "https://testnet-rpc.monad.xyz/";
final Web3Client client = Web3Client(rpcUrl, Client());

final EthereumAddress tokenAddress = EthereumAddress.fromHex("0xfe140e1dce99be9f4f15d657cd9b7bf622270c50"); // USDT

Future<DeployedContract> loadContract() async {
  String abi = await rootBundle.loadString('assets/abi.json');
  final contract = DeployedContract(
    ContractAbi.fromJson(abi, "ERC20"),
    tokenAddress,
  );
  return contract;
}

Future<String> getTokenSymbol() async {
  final contract = await loadContract();
  final symbolFunction = contract.function("symbol");
  final result = await client.call(contract: contract, function: symbolFunction, params: []);
  return result.first.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Get Token Symbol', () async {
    final symbol = await getTokenSymbol();
    print(symbol);
    expect(symbol.isNotEmpty, true); 
  });
}