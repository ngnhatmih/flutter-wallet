import 'package:flutter/material.dart';

class LastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Khám phá"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Tìm kiếm...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16), 

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildBox("Sites", Icons.web, Colors.red, height: double.infinity),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(child: _buildBox("Tokens", Icons.monetization_on, Colors.green)),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildBox("Collections", Icons.category, Colors.orange)),
                            SizedBox(width: 16),
                            Expanded(child: _buildBox("Learn", Icons.school, Colors.blue)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(child: _buildBox("Quest", Icons.explore, Colors.purple)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String title, IconData icon, Color color, {double? height}) {
    return Container(
      height: height ?? 100,
      decoration: BoxDecoration(
        color: color.withAlpha(95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
