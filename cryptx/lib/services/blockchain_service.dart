import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class EthereumService {
  final String rpcUrl;
  final int chainId;
  final http.Client httpClient;
  late Web3Client ethClient;
  late String abi;
  late String uniswapAbi;

  EthereumService(this.rpcUrl, this.chainId, this.httpClient) {
    ethClient = Web3Client(rpcUrl, httpClient);
  }

  Future<void> loadABI() async {
    abi = await rootBundle.loadString('assets/abi.json');
  }

  Future<void> loadUniswapABI() async {
    uniswapAbi = await rootBundle.loadString('assets/uniswap_abi.json');
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

  Future<String> transferToken(
    Credentials credentials,
    EthereumAddress tokenAddress,
    EthereumAddress receiver,
    BigInt amount,
  ) async {
    final contract = await loadContract(tokenAddress);
    final transferFunction = contract.function("transfer");

    final transaction = Transaction.callContract(
      contract: contract,
      function: transferFunction,
      parameters: [receiver, amount],
    );

    final response = await ethClient.sendTransaction(
      credentials,
      transaction,
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

  Future<String> swapTokens({
    required Credentials credentials,
    required BigInt amountIn,
    required BigInt amountOutMin,
    required List<EthereumAddress> path,
    required EthereumAddress to,
    required BigInt deadline,
    required EthereumAddress uniswapContractAddress,
  }) async {
    if (uniswapAbi.isEmpty) {
      await loadUniswapABI();
    }

    final contract = DeployedContract(
      ContractAbi.fromJson(uniswapAbi, "UniswapV2Router"),
      uniswapContractAddress,
    );

    final swapFunction = contract.function("swapExactTokensForTokens");

    final transaction = Transaction.callContract(
      contract: contract,
      function: swapFunction,
      parameters: [
        amountIn,
        amountOutMin, 
        path,
        to, 
        deadline, 
      ],
    );

    final txHash = await ethClient.sendTransaction(
      credentials,
      transaction,
      chainId: chainId,
    );

    return txHash; 
  }

  Future<String> swapExactETHForTokens({
    required Credentials credentials,
    required BigInt amountOutMin,
    required List<EthereumAddress> path,
    required EthereumAddress to,
    required BigInt deadline,
    required EthereumAddress uniswapContractAddress,
    required BigInt value,
  }) async {
    if (uniswapAbi.isEmpty) {
      await loadUniswapABI();
    }

    final gasPrice = await ethClient.getGasPrice();

    final contract = DeployedContract(
      ContractAbi.fromJson(uniswapAbi, "UniswapV2Router"),
      uniswapContractAddress,
    );

    final swapFunction = contract.function("swapExactETHForTokens");

    final transaction = Transaction.callContract(
      contract: contract,
      function: swapFunction,
      parameters: [
        amountOutMin,
        path,
        to,
        deadline,
      ],
      value: EtherAmount.inWei(value),
      maxGas: (gasPrice.getInWei * BigInt.from(2)).toInt(),
      maxPriorityFeePerGas: EtherAmount.inWei(BigInt.from(1500000)),
    );

    final txHash = await ethClient.sendTransaction(
      credentials,
      transaction,
      chainId: chainId,
    );

    return txHash;
  }

  Future<String> swapExactTokensForETH({
    required Credentials credentials,
    required BigInt amountIn,
    required BigInt amountOutMin,
    required List<EthereumAddress> path,
    required EthereumAddress to,
    required BigInt deadline,
    required EthereumAddress uniswapContractAddress,
  }) async {
    if (uniswapAbi.isEmpty) {
      await loadUniswapABI();
    }

    final contract = DeployedContract(
      ContractAbi.fromJson(uniswapAbi, "UniswapV2Router"),
      uniswapContractAddress,
    );

    final swapFunction = contract.function("swapExactTokensForETH");

    final transaction = Transaction.callContract(
      contract: contract,
      function: swapFunction,
      parameters: [
        amountIn,
        amountOutMin,
        path,
        to,
        deadline,
      ],
    );

    final txHash = await ethClient.sendTransaction(
      credentials,
      transaction,
      chainId: chainId,
    );

    return txHash;
  }

  Future<BigInt> getAmountOut({
    required BigInt amountIn,
    required List<EthereumAddress> path,
    required EthereumAddress uniswapContractAddress,
  }) async {
    if (uniswapAbi.isEmpty) {
      await loadUniswapABI();
    }

    final contract = DeployedContract(
      ContractAbi.fromJson(uniswapAbi, "UniswapV2Router"),
      uniswapContractAddress,
    );

    final getAmountsOutFunction = contract.function("getAmountsOut");

    // Call the `getAmountsOut` function
    final result = await ethClient.call(
      contract: contract,
      function: getAmountsOutFunction,
      params: [amountIn, path],
    );

    // The last element in the result is the output amount
    final amounts = result.first as List<dynamic>;
    return amounts.last as BigInt;
  }

  void close() {
    ethClient.dispose();
  }
}
