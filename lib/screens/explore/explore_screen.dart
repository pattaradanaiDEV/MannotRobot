import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/job_detail_screen.dart';

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
  String searchQuery = "";

  // ข้อมูลหมวดหมู่สมมติ (คุณสามารถเพิ่มใน Firestore ได้ภายหลัง)
  final List<Map<String, String>> categories = [
    {'name': 'Mains', 'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80'},
    {'name': 'Pastry', 'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=500&q=80'},
    {'name': 'Drinks', 'image': 'https://images.unsplash.com/photo-1544145945-f904253d0c7b?w=500&q=80'},
    {'name': 'Vegan', 'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80'},
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isRecipeMode ? const Color(0xFFF97316) : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(primaryColor),

              _buildSectionTitle('Explore by Category'),
              _buildCategoryGrid(),

              _buildSectionTitle('Recent Opportunities'),
              _buildRecentOpportunities(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        'Discover',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search recipes, jobs, or chefs...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: const Icon(Icons.tune, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterChips(Color primaryColor) {
    final List<String> labels = ['All', 'Recipes', 'Jobs', 'Chefs'];
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(labels[index]),
              selected: isSelected,
              onSelected: (val) {
                setState(() => selectedFilterIndex = index);
                if (index == 1) widget.onModeChanged(true);
                if (index == 2) widget.onModeChanged(false);
              },
              selectedColor: const Color(0xFF2D3142),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))),
    );
  }

  // Grid หมวดหมู่ตามรูปตัวอย่าง
  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: NetworkImage(categories[index]['image']!), fit: BoxFit.cover),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                categories[index]['name']!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }

  // ดึงข้อมูล Recent Opportunities จาก Firestore
  Widget _buildRecentOpportunities() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(data['logoUrl'] ?? data['imageUrl']), backgroundColor: Colors.grey.shade200),
              title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['companyName'] ?? ''),
              trailing: const Text('Apply', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(jobData: data), // ส่ง data ไปที่ Constructor
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}