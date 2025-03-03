import 'package:flutter/material.dart';

class SwapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swap tiền mã hóa"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Từ loại tiền",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: "ETH", child: Text("ETH")),
                DropdownMenuItem(value: "USDT", child: Text("USDT")),
                DropdownMenuItem(value: "BTC", child: Text("BTC")),
              ],
              onChanged: (value) {
                
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Chọn loại tiền",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Sang loại tiền",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: "ETH", child: Text("ETH")),
                DropdownMenuItem(value: "USDT", child: Text("USDT")),
                DropdownMenuItem(value: "BTC", child: Text("BTC")),
              ],
              onChanged: (value) {
                
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Chọn loại tiền",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số lượng cần swap",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                
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
    );
  }
}

class Sw extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swap tiền mã hóa"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Từ loại tiền",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: "ETH", child: Text("ETH")),
                DropdownMenuItem(value: "USDT", child: Text("USDT")),
                DropdownMenuItem(value: "BTC", child: Text("BTC")),
              ],
              onChanged: (value) {
                // Xử lý chọn loại tiền
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Chọn loại tiền",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Sang loại tiền",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(value: "ETH", child: Text("ETH")),
                DropdownMenuItem(value: "USDT", child: Text("USDT")),
                DropdownMenuItem(value: "BTC", child: Text("BTC")),
              ],
              onChanged: (value) {
                // Xử lý chọn loại tiền
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Chọn loại tiền",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Nhập số lượng cần swap",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Xử lý swap
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
    );
  }
}
