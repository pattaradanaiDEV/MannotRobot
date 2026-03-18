/*
 * File: create_recipe_screen.dart
 * Description: หน้าจอสำหรับสร้างและโพสต์สูตรอาหารใหม่
 * Responsibilities:
 * - รับข้อมูลรายละเอียดสูตรอาหาร (ชื่อ, เวลา, ป้ายกำกับ, ความยาก)
 * - จัดการฟอร์มแบบไดนามิกสำหรับการเพิ่ม/ลบ วัตถุดิบและวิธีทำ
 * - อัปโหลดรูปภาพภาพปกสูตรอาหาร และบันทึกข้อมูลทั้งหมดลงฐานข้อมูล
 * Author: Pattaradanai Chaitan
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firestore_service.dart';
import '../../models/recipe.dart';

/// วิดเจ็ตหน้าจอสำหรับให้ผู้ใช้สร้างโพสต์สูตรอาหารใหม่.
///
/// ภายในประกอบด้วยฟอร์มรับข้อมูลที่ผู้ใช้สามารถเพิ่ม/ลดจำนวนวัตถุดิบและขั้นตอนได้
/// รวมถึงรองรับการอัปโหลดรูปภาพหน้าปกเพื่อบันทึกลงระบบ.
class CreateRecipeScreen extends StatefulWidget {
  /// สร้าง [CreateRecipeScreen] วิดเจ็ต.
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

/// จัดการสถานะของหน้าจอสร้างสูตรอาหาร.
class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // State variables
  int difficultyIndex = 0; // 0: Easy, 1: Medium, 2: Hard

  String _selectedTimeUnit = 'Mins'; // ค่าเริ่มต้นเป็น Mins

  // Services & Controllers
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Dynamic Controllers for Ingredients
  final List<TextEditingController> _qtyControllers = [TextEditingController()];
  final List<TextEditingController> _nameControllers = [
    TextEditingController(),
  ];

  final List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];

  // รายการ Tags อาหารทั้งหมดในโลก
  final List<String> _availableTags = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Dessert",
    "Snack",
    "Beverage",
    "Thai",
    "Japanese",
    "Italian",
    "Mexican",
    "Chinese",
    "Indian",
    "Korean",
    "Vegan",
    "Vegetarian",
    "Keto",
    "Gluten-Free",
    "Low-Carb",
    "High-Protein",
    "Healthy",
    "Fast Food",
    "Street Food",
    "Seafood",
    "Chicken",
    "Beef",
    "Pork",
    "Spicy",
    "Sweet",
    "Savory",
    "Baking",
    "Grilling",
    "Fried",
    "Soup",
    "Salad",
  ];

  // เก็บ Tags ที่ผู้ใช้กดเลือก
  final List<String> _selectedTags = [];

  // ตัวแปรเก็บไฟล์รูปภาพที่เลือกจากเครื่อง
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// ทำความสะอาดหน่วยความจำ.
  ///
  /// ล้างค่า Controller ทั้งหมดเพื่อป้องกัน Memory Leak.
  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// ลบช่องกรอกข้อมูลวัตถุดิบออกจากฟอร์มหน้าจอตาม [index].
  void _removeIngredient(int index) {
    setState(() {
      _qtyControllers[index].dispose();
      _nameControllers[index].dispose();
      _qtyControllers.removeAt(index);
      _nameControllers.removeAt(index);
    });
  }

  /// ลบช่องกรอกข้อมูลวิธีทำออกจากฟอร์มหน้าจอตาม [index].
  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  /// เปิดแกลเลอรีรูปภาพเพื่อให้ผู้ใช้เลือกภาพหน้าปกสูตรอาหาร.
  ///
  /// ฟังก์ชันนี้ทำงานแบบ Async โดยจะรอให้ผู้ใช้เลือกภาพจากแกลเลอรี
  /// หากเลือกสำเร็จจะอัปเดตสถานะของ [_imageFile].
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// รวบรวมข้อมูล อัปโหลดรูปภาพ และบันทึกสูตรอาหารลง Database.
  ///
  /// ฟังก์ชันนี้เป็นแบบ Async จะแสดงหน้าต่าง Loading ขณะรอดำเนินการ
  /// หากมีข้อมูลที่จำเป็นไม่ครบจะระงับการทำงานและแสดงข้อความแจ้งเตือน.
  Future<void> _handlePostRecipe() async {
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

    // โชว์ Loading ระหว่างเซฟ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // รวบรวมข้อมูลวัตถุดิบที่ผู้ใช้กรอก
    List<Map<String, String>> ingredientList = [];
    for (int i = 0; i < _qtyControllers.length; i++) {
      if (_nameControllers[i].text.trim().isNotEmpty) {
        ingredientList.add({
          'qty': _qtyControllers[i].text.trim(),
          'name': _nameControllers[i].text.trim(),
        });
      }
    }

    List<String> instructionList = [];
    for (var controller in _instructionControllers) {
      if (controller.text.trim().isNotEmpty) {
        instructionList.add(controller.text.trim());
      }
    }

    int inputTime = int.tryParse(_timeController.text.trim()) ?? 0;
    int totalMins = _selectedTimeUnit == 'Hours' ? inputTime * 60 : inputTime;

    // รูปเริ่มต้นถ้าผู้ใช้ไม่ได้เลือกรูป
    String finalImageUrl =
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80";

    if (_imageFile != null) {
      String? uploadedUrl = await _firestoreService.uploadImage(_imageFile!);
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl; // เปลี่ยนไปใช้ URL ที่อัปโหลดสำเร็จ
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("อัปโหลดรูปไม่สำเร็จ ใช้รูปเริ่มต้นแทน"),
            ),
          );
        }
      }
    }
    // สร้างออบเจกต์ Recipe เพื่อเตรียมบันทึกลง Database
    Recipe newRecipe = Recipe(
      userId: user!.uid,
      authorName: user!.displayName ?? "Anonymous Chef",
      title: _titleController.text.trim(),
      difficulty: difficultyIndex == 0
          ? "Easy"
          : difficultyIndex == 1
          ? "Medium"
          : "Hard",
      timeMins: totalMins,
      tags: _selectedTags,
      ingredients: ingredientList,
      instructions: instructionList,
      imageUrl: finalImageUrl,
      likes: [],
    );

    try {
      await _firestoreService.addRecipe(newRecipe);
      if (mounted) {
        Navigator.pop(context); // ปิด Loading
        Navigator.pop(context); // ปิดหน้า Post
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("โพสต์สูตรอาหารสำเร็จ!")));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // ปิด Loading ก่อนโชว์ Error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  /// สร้างโครงสร้างหน้าจอและฟอร์มสำหรับกรอกข้อมูล.
  @override
  Widget build(BuildContext context) {
    final String displayName = user?.displayName ?? user?.email ?? 'Chef';
    final String photoUrl = user?.photoURL ?? '';
    final String initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

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
              onPressed: _handlePostRecipe,
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  radius: 24,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Posting publicly',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 16),

            _buildSectionTitle('Select Tags'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFF97316),
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
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
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedTimeUnit,
                    items: ['Mins', 'Hours'],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTimeUnit = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Ingredients', isBold: true),
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
                        flex: 2,
                        child: _buildTextField(
                          'Qty',
                          controller: _qtyControllers[index],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: _buildTextField(
                          'Ingredient Name',
                          controller: _nameControllers[index],
                        ),
                      ),
                      if (_qtyControllers.length > 1)
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red.shade300,
                          ),
                          onPressed: () => _removeIngredient(index),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                );
              },
            ),
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
            const SizedBox(height: 32),

            _buildSectionTitle('Instructions', isBold: true),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _instructionControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _instructionControllers[index],
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Describe step ${index + 1}...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      if (_instructionControllers.length > 1)
                        IconButton(
                          padding: const EdgeInsets.only(top: 12, left: 8),
                          alignment: Alignment.topCenter,
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red.shade300,
                          ),
                          onPressed: () => _removeInstruction(index),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                );
              },
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _instructionControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFF97316),
                ),
                label: const Text(
                  'Add step',
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
            const SizedBox(height: 32),

            _buildSectionTitle('Photos', isBold: true),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey.shade500,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to upload photos',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _imageFile = null),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// สร้างวิดเจ็ตหัวข้อสำหรับแต่ละหมวดหมู่ในหน้าแบบฟอร์ม.
  ///
  /// สามารถกำหนดความหนาของตัวอักษรได้ผ่านค่า [isBold].
  Widget _buildSectionTitle(String title, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isBold ? 18 : 14,
          fontWeight: FontWeight.bold,
          color: isBold ? const Color(0xFF1A2B4C) : Colors.grey.shade600,
        ),
      ),
    );
  }

  /// สร้างปุ่มตัวเลือกสำหรับระดับความยาก.
  ///
  /// การแสดงผลสีจะเปลี่ยนไปเมื่อค่า [index] ตรงกับตัวแปร state.
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

  /// สร้าง TextField สำหรับรับข้อมูลทั่วไป.
  ///
  /// รับค่า [hint] สำหรับข้อความแนะนำ และสามารถส่ง [controller] เพื่อผูกข้อมูลได้.
  Widget _buildTextField(
    String hint, {
    IconData? icon,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ), // ดันบนล่างให้สมดุล
          // ควบคุมขนาดไอคอนให้ไม่ไปดันข้อความให้เบี้ยว
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: icon != null
              ? Icon(icon, color: Colors.grey, size: 22)
              : null,
        ),
      ),
    );
  }

  /// สร้างเมนู Dropdown Menu.
  ///
  /// รับค่าปัจจุบัน [value] รายการตัวเลือก [items] และฟังก์ชันเปลี่ยนค่า [onChanged].
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
          items: items
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
