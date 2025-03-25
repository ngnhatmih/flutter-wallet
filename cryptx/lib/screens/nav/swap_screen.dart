import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/providers/ethereum_provider.dart';

class SwapScreen extends StatefulWidget {
  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _tokenIn;
  String? _tokenOut;
  double? _amountIn;
  double? _amountOutMin;
  double _gasFee = 0.0;

  @override
  Widget build(BuildContext context) {
    final ethereumProvider = Provider.of<EthereumProvider>(context);

    double balanceIn() {
      if (_tokenIn == "primary") {
        return ethereumProvider.walletModel!.getBalance;
      } else {
        return ethereumProvider.tokens
            .firstWhere((element) => element.address == _tokenIn)
            .balance;
      }
    }

    double balanceOut() {
      if (_tokenOut == "primary") {
        return ethereumProvider.walletModel!.getBalance;
      } else {
        return ethereumProvider.tokens
            .firstWhere((element) => element.address == _tokenOut)
            .balance;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Swap tiền mã hóa"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Từ loại tiền
              Text(
                "Từ loại tiền",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                    value: "primary",
                    child: Text(
                        ethereumProvider.currentNetwork?['currencySymbol'] ??
                            "ETH"),
                  ),
                  ...ethereumProvider.
                      tokensByChainId
                      .map((token) => DropdownMenuItem(
                            value: token.address,
                            child: Text(token.symbol),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _tokenIn = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Chọn loại tiền",
                ),
                validator: (value) =>
                    value == null ? "Vui lòng chọn loại tiền" : null,
              ),
              if (_tokenIn != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Số dư: ${balanceIn().toStringAsFixed(6)} ${ethereumProvider.currentNetwork?['currencySymbol'] ?? ''}",
                  ),
                ),
              SizedBox(height: 16),

              Text(
                "Sang loại tiền",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                    value: "primary",
                    child: Text(
                        ethereumProvider.currentNetwork?['currencySymbol'] ??
                            "ETH"),
                  ),
                  ...ethereumProvider.tokensByChainId
                      .map((token) => DropdownMenuItem(
                            value: token.address,
                            child: Text(token.symbol),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _tokenOut = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: "Chọn loại tiền",
                ),
                validator: (value) =>
                    value == null ? "Vui lòng chọn loại tiền" : null,
              ),
              if (_tokenOut != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Số dư: ${balanceOut().toStringAsFixed(6)} ${ethereumProvider.currentNetwork?['currencySymbol'] ?? ''}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              SizedBox(height: 16),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Nhập số lượng cần swap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) async {
                  setState(() {
                    _amountIn = double.tryParse(value);
                  });

                  if (_amountIn != null &&
                      _tokenIn != null &&
                      _tokenOut != null) {
                    final amountOut = await ethereumProvider.calculateAmountOut(
                      amountIn: _amountIn!,
                      tokenInAddress: _tokenIn!,
                      tokenOutAddress: _tokenOut!,
                    );

                    setState(() {
                      _amountOutMin = amountOut;
                      print(_amountOutMin);
                    });
                  }
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Nhập số lượng tối thiểu nhận được",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _amountOutMin = double.tryParse(value);
                },
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? "Vui lòng nhập số lượng hợp lệ"
                        : null,
              ),
              SizedBox(height: 16),
              if (_amountOutMin != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Số lượng nhận được: ${_amountOutMin!.toStringAsFixed(6)}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              Divider(),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ethereumProvider.swapTokens(
                      tokenInAddress: _tokenIn!,
                      tokenOutAddress: _tokenOut!,
                      amountIn: _amountIn!,
                      amountOutMin: _amountOutMin!,
                      recipientAddress:
                          ethereumProvider.walletModel!.getAddress,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Swap thành công!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Swap ngay",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
