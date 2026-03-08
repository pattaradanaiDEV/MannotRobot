import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const ExploreScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Color(0xFF1A2B4C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(0, 'All', primaryColor),
                  _buildFilterChip(1, 'Recipes', primaryColor),
                  _buildFilterChip(2, 'Jobs', primaryColor),
                  _buildFilterChip(3, 'Chefs', primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryGrid(),

            const SizedBox(height: 100), // เว้นที่ให้ Navbar
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, Color primaryColor) {
    final bool isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilterIndex = index);
        if (index == 1) widget.onModeChanged(true);
        if (index == 2) widget.onModeChanged(false);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3142) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D3142) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    List<dynamic> categories = []; // รอข้อมูลจริง

    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("ไม่มีหมวดหมู่", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return const SizedBox();
  }
}
