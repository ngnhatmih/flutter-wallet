import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wallet/providers/ethereum_provider.dart';
import 'package:wallet/utils/format.dart';

class ReceiveScreen extends StatefulWidget {
  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  @override
  Widget build(BuildContext context) {
    final ethereumProvider = Provider.of<EthereumProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Nhận tiền mã hóa"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text(
                "Quét mã QR để nhận tiền",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: 200,
                color: Colors.grey[200],
                child: Center(
                  child: QrImageView(
                    data: ethereumProvider.walletModel!.getAddress,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Địa chỉ ví của bạn:",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              SelectableText(
                AddressFormat.formatAddress(
                    ethereumProvider.walletModel!.getAddress),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Sao chép nội dung của SelectableText vào Clipboard
                  Clipboard.setData(ClipboardData(
                      text: ethereumProvider.walletModel!.getAddress));
                  // Hiển thị thông báo đã sao chép thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Địa chỉ đã được sao chép!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 20, horizontal: 40), // Tăng kích thước nút
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // Bo góc mềm mại hơn
                  ),
                  elevation: 5, // Hiệu ứng đổ bóng
                ),
                child: Text(
                  "Sao chép địa chỉ",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
