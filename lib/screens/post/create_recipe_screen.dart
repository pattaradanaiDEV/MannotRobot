import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/recipe.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // State variables
  int difficultyIndex = 0; // 0: Easy, 1: Medium, 2: Hard

  // Services & Controllers
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  // Dynamic Controllers for Ingredients
  final List<TextEditingController> _qtyControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    // ล้างข้อมูลเพื่อประหยัด Memory เมื่อปิดหน้าจอ
    _titleController.dispose();
    _timeController.dispose();
    _instructionController.dispose();
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ฟังก์ชันสำหรับส่งข้อมูลขึ้น Firebase
  Future<void> _handlePostRecipe() async {
    final user = FirebaseAuth.instance.currentUser;

    // ตรวจสอบว่ามีการล็อกอินและกรอกชื่อสูตรหรือไม่
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนโพสต์")),
      );
      return;
    }
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณากรอกชื่อสูตรอาหาร")));
      return;
    }

    // รวบรวมรายชื่อวัตถุดิบจาก Dynamic Controllers
    List<Map<String, String>> ingredientList = [];
    for (int i = 0; i < _qtyControllers.length; i++) {
      if (_nameControllers[i].text.isNotEmpty) {
        ingredientList.add({
          'qty': _qtyControllers[i].text,
          'name': _nameControllers[i].text,
        });
      }
    }

    // สร้างก้อนข้อมูล Recipe Object
    Recipe newRecipe = Recipe(
      userId: user.uid,
      authorName: user.displayName ?? "Anonymous Chef",
      title: _titleController.text,
      difficulty: difficultyIndex == 0
          ? "Easy"
          : difficultyIndex == 1
          ? "Medium"
          : "Hard",
      timeMins: int.tryParse(_timeController.text) ?? 0,
      tags: ["Thai", "Dinner"], // ส่วนนี้สามารถพัฒนาต่อให้เลือก Tag ได้จริง
      ingredients: ingredientList,
      instructions: _instructionController.text,
      imageUrl:
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd", // Mockup URL
      likes: [],
    );

    try {
      // เรียกใช้ Service เพื่อบันทึกลง Firestore
      await _firestoreService.addRecipe(newRecipe);
      if (mounted) {
        Navigator.pop(context); // โพสต์สำเร็จให้ปิดหน้าจอนี้
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("โพสต์สูตรอาหารสำเร็จ!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Recipe',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: ElevatedButton(
              onPressed:
                  _handlePostRecipe, // เชื่อมต่อฟังก์ชัน Post ที่เขียนไว้ด้านบน
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            const Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=5',
                  ),
                  radius: 24,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Jenkins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Posting publicly',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipe Name Input
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Recipe Name',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
            ),

            // Tags (Static for now)
            Row(
              children: [
                _buildTag('Thai', true),
                _buildTag('Dinner', false),
                _buildTag('+', false, isAdd: true),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('DIFFICULTY LEVEL'),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildDiffButton('Easy', 0),
                  _buildDiffButton('Medium', 1),
                  _buildDiffButton('Hard', 2),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('TIME REQUIRED'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    '0',
                    icon: Icons.timer_outlined,
                    controller: _timeController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('Mins')),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Ingredients', isBold: true),
            // รายการวัตถุดิบแบบ Dynamic
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _qtyControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          'Qty',
                          controller: _qtyControllers[index],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          'Ingredient Name',
                          controller: _nameControllers[index],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _qtyControllers.add(TextEditingController());
                    _nameControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFF97316),
                ),
                label: const Text(
                  'Add ingredient',
                  style: TextStyle(color: Color(0xFFF97316)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade100),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Instructions', isBold: true),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _instructionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText:
                      'Share the step-by-step details of your delicious recipe here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Photos', isBold: true),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.grey.shade600,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to upload photos',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helpers UI Components ---

  Widget _buildSectionTitle(String title, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isBold ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: isBold ? const Color(0xFF1A2B4C) : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildTag(String label, bool isSelected, {bool isAdd = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdd ? Colors.grey.shade400 : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFFF97316) : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDiffButton(String label, int index) {
    bool isSelected = difficultyIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => difficultyIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFF97316)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    IconData? icon,
    TextEditingController? controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [
            value,
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
