import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  int difficultyIndex = 0; // 0: Easy, 1: Medium, 2: Hard
  List<int> ingredientsCount = [1, 2]; // จำนวนช่องวัตถุดิบจำลอง

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316), // สีส้ม
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
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=5',
                  ),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sarah Jenkins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Posting publicly',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipe Name
            TextField(
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

            // Tags
            Row(
              children: [
                _buildTag('Thai', true),
                _buildTag('Dinner', false),
                _buildTag('+', false, isAdd: true),
              ],
            ),
            const SizedBox(height: 24),

            // Difficulty Level
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

            // Time Required
            _buildSectionTitle('TIME REQUIRED'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('0', icon: Icons.timer_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('Mins')),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients
            _buildSectionTitle('Ingredients', isBold: true),
            ...ingredientsCount.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _buildTextField('Qty')),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: _buildTextField('Ingredient Name'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(
                  () => ingredientsCount.add(ingredientsCount.length + 1),
                ),
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

            // Instructions
            _buildSectionTitle('Instructions', isBold: true),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText:
                      'Share the step-by-step details of your delicious recipe here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Photos
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
                  Text(
                    'Tap to upload photos',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

  // --- Helpers สำหรับ UI หน้า Recipe ---
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
          style: isAdd ? BorderStyle.solid : BorderStyle.none,
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

  Widget _buildTextField(String hint, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
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
          items: [value]
              .map(
                (String val) => DropdownMenuItem(value: val, child: Text(val)),
              )
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
