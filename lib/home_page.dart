import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // ปรับให้เป็นมาตรฐานใหม่ของ Flutter

  @override
  State<HomePage> createState() => _HomePageState(); // เปลี่ยนจาก throw เป็นการเรียก State
}

class _HomePageState extends State<HomePage> {
  bool isJobMode = true; // ตัวแปรสลับโหมด Job/Recipe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MannotRobot'), centerTitle: true),
      body: Column(
        children: [
          // ส่วน Toggle ด้านบน
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isJobMode
                          ? Colors.deepPurple
                          : Colors.grey[300],
                      foregroundColor: isJobMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => setState(() => isJobMode = true),
                    child: const Text('Job Search'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isJobMode
                          ? Colors.green
                          : Colors.grey[300],
                      foregroundColor: !isJobMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => setState(() => isJobMode = false),
                    child: const Text('Recipes'),
                  ),
                ),
              ],
            ),
          ),
          // ส่วนแสดงรายการ Card
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(isJobMode ? Icons.work : Icons.restaurant),
                  ),
                  title: Text(
                    isJobMode ? 'Job Title $index' : 'Recipe Name $index',
                  ),
                  subtitle: const Text('Click to see more data...'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
