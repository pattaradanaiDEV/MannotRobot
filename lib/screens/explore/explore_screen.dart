import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/job_detail_screen.dart';
import '../home/recipe_detail_screen.dart';

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
  String searchQuery = "";
  String selectedTag = "All";

  // รายการ Tags สำหรับอาหาร (Copy มาจากหน้า Post ของคุณ)
  final List<String> recipeTags = [
    'All', "Breakfast", "Lunch", "Dinner", "Dessert", "Snack", "Beverage",
    "Thai", "Japanese", "Italian", "Mexican", "Chinese", "Indian", "Korean",
    "Vegan", "Vegetarian", "Keto", "Gluten-Free", "Low-Carb", "High-Protein",
    "Healthy", "Fast Food", "Street Food", "Seafood", "Chicken", "Beef",
    "Pork", "Spicy", "Sweet", "Savory", "Baking", "Grilling", "Fried", "Soup", "Salad"
  ];

  // รายการ Tags สำหรับงาน
  final List<String> jobTags = ['All', 'Full-time', 'Part-time', 'Contract', 'Internship'];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isRecipeMode ? const Color(0xFFF97316) : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวและปุ่มสลับโหมด
            _buildHeader(primaryColor),

            // ช่องค้นหา
            _buildSearchBar(),

            // แถบเลือก Tags (เลื่อนซ้าย-ขวาได้)
            _buildTagFilter(primaryColor),

            const SizedBox(height: 10),

            // รายการผลลัพธ์จาก Firestore
            Expanded(
              child: _buildResultsList(primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isRecipeMode ? 'Explore Recipes' : 'Explore Jobs',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
          ),
          // ปุ่มสลับโหมด
          ActionChip(
            label: Text(widget.isRecipeMode ? 'Jobs' : 'Recipes'),
            onPressed: () {
              widget.onModeChanged(!widget.isRecipeMode);
              setState(() => selectedTag = "All"); // รีเซ็ตตัวกรองเมื่อสลับโหมด
            },
            backgroundColor: primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            avatar: Icon(widget.isRecipeMode ? Icons.work_outline : Icons.restaurant_menu, size: 16, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: widget.isRecipeMode ? 'ค้นหาสูตรอาหารที่ต้องการ...' : 'ค้นหาตำแหน่งงาน...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTagFilter(Color primaryColor) {
    List<String> currentTags = widget.isRecipeMode ? recipeTags : jobTags;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: currentTags.length,
        itemBuilder: (context, index) {
          final tag = currentTags[index];
          bool isSelected = selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedTag = tag),
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              showCheckmark: false,
              elevation: 1,
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsList(Color primaryColor) {
    String collection = widget.isRecipeMode ? 'recipes' : 'jobs';
    Query query = FirebaseFirestore.instance.collection(collection);

    // กรองตาม Tag (ถ้าไม่ใช่ All)
    if (selectedTag != "All") {
      if (widget.isRecipeMode) {
        // กรองจากฟิลด์ 'tags' (Array) ในเอกสาร Recipe
        query = query.where('tags', arrayContains: selectedTag);
      } else {
        // กรองจากฟิลด์ 'jobType' ในเอกสาร Job
        query = query.where('jobType', isEqualTo: selectedTag);
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('ไม่พบข้อมูลที่ต้องการ'));
        }

        // กรองคำค้นหา (Search Query) ที่ Client
        var docs = snapshot.data!.docs.where((doc) {
          String title = (doc.data() as Map<String, dynamic>)['title']?.toString().toLowerCase() ?? "";
          return title.contains(searchQuery);
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('ไม่พบผลลัพธ์ที่ค้นหา'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String docId = docs[index].id;

            return GestureDetector(
              onTap: () {
                if (widget.isRecipeMode) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipeData: data, recipeId: docId),
                  ));
                } else {
                  // ฝั่ง Job ปกติจะกดได้เลยถ้าชื่อ Class ตรง
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => JobDetailScreen(jobData: data, jobId: docId),
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['imageUrl'] ?? 'https://via.placeholder.com/150',
                        width: 75, height: 75, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 75, height: 75, color: Colors.grey.shade100,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2B4C)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isRecipeMode ? "Chef ${data['authorName'] ?? ''}" : (data['companyName'] ?? ''),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          // Badge แสดงความยากหรืองาน
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              widget.isRecipeMode ? (data['difficulty'] ?? 'Easy') : (data['jobType'] ?? 'Full-time'),
                              style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}