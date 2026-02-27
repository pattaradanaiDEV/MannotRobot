import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const ProfileScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 12),
          const Text('Name', style: TextStyle(fontSize: 18)),
          const Text('(Details)', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // แท็บสลับ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeChanged(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: isRecipeMode
                          ? Colors.grey.shade400
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'My recipes',
                          style: TextStyle(
                            color: isRecipeMode
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: Colors.grey.shade500),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onModeChanged(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: !isRecipeMode
                          ? Colors.grey.shade400
                          : Colors.transparent,
                      child: Center(
                        child: Text(
                          'My applications',
                          style: TextStyle(
                            color: !isRecipeMode
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // รายการผลงาน
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 80,
                        color: Colors.grey.shade600,
                        child: Icon(
                          isRecipeMode ? Icons.fastfood : Icons.work,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRecipeMode ? 'FoodName' : 'Job Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade500,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
