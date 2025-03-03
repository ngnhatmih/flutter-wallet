import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class EthereumService {
  final String rpcUrl;
  final http.Client httpClient;
  late Web3Client ethClient;
  int chainId = 1337;

  EthereumService(this.rpcUrl, this.httpClient) {
    ethClient = Web3Client(rpcUrl, httpClient);
  }

  Future<EtherAmount> getBalance(EthereumAddress address) async {
    return await ethClient.getBalance(address);
  }

  Future<EtherAmount> estimateGasFee(EthereumAddress sender, EthereumAddress receiver, EtherAmount amount) async {
    final gasPrice = await ethClient.getGasPrice();
    final gas = await ethClient.estimateGas(
      sender: sender,
      to: receiver,
      value: amount,
    );
    return EtherAmount.inWei(gas * gasPrice.getInWei);
  }

  Future<String> sendTransaction(Credentials credentials, EthereumAddress sender, EthereumAddress receiver, EtherAmount amount) async {
    final transaction = Transaction(
      from: sender,
      to: receiver,
      value: amount,
    );

    final response = await ethClient.sendTransaction(credentials, transaction, chainId: chainId);
    return response;
  }

  Future<TransactionInformation?> getTransaction(String txHash) async {
    return await ethClient.getTransactionByHash(txHash);
  }

  Future<BlockInformation> getLatestBlock() async {
    return await ethClient.getBlockInformation();
  }

  void close() {
    ethClient.dispose();
  }
}
