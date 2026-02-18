import 'package:flutter/material.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการที่ถูกใจจจจจจจ'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.favorite, size: 100.0, color: Colors.red[200]),
            const SizedBox(height: 20.0),
            const Text(
              'หางานหรืออาหารที่ถูกใจไว้หรอ? คำตอบคือไม่มีีีีีีีีีีีี',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
