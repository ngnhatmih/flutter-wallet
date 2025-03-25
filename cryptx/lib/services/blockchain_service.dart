import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;


class EthereumService {
  final String rpcUrl;
  final int chainId;
  final http.Client httpClient;
  late Web3Client ethClient;
  late String abi;

  EthereumService(this.rpcUrl, this.chainId, this.httpClient) {
    ethClient = Web3Client(rpcUrl, httpClient);
  }

  Future<void> loadABI() async {
    abi = await rootBundle.loadString('assets/abi.json');
  }

  Future<DeployedContract> loadContract(EthereumAddress tokenAddress) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "ERC20"),
      tokenAddress,
    );
    return contract;
  }

  Future<String> getTokenSymbol(EthereumAddress tokenAddress) async {
    final contract = await loadContract(tokenAddress);
    final symbolFunction = contract.function("symbol");
    final result = await ethClient.call(contract: contract, function: symbolFunction, params: []);
    return result.first.toString();
  }

  Future<int> getTokenDecimals(EthereumAddress tokenAddress) async {
    final contract = await loadContract(tokenAddress);
    final decimalsFunction = contract.function("decimals");
    final result = await ethClient.call(contract: contract, function: decimalsFunction, params: []);
    return result.first.toInt();
  }

  Future<EtherAmount> getAmount(EthereumAddress tokenAddress, EthereumAddress owner) async {
    final contract = await loadContract(tokenAddress);
    final balanceFunction = contract.function("balanceOf");
    final result = await ethClient.call(contract: contract, function: balanceFunction, params: [owner]);
    return EtherAmount.inWei(result.first);
  }

  Future<String> transferToken(Credentials credentials, EthereumAddress tokenAddress, EthereumAddress receiver, EtherAmount amount) async {
    final contract = await loadContract(tokenAddress);
    final transferFunction = contract.function("transfer");
    final response = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: transferFunction,
        parameters: [receiver, amount.getInWei],
      ),
      chainId: chainId,
    );
    return response;
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
