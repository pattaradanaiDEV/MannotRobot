import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import หน้า Detail เพื่อให้พอกดแล้วเข้าไปดูรายละเอียดได้ (เช็ก Path ให้ตรงกับโปรเจกต์คุณ)
import '../home/recipe_detail_screen.dart';
import '../home/job_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const SavedScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // ดึงข้อมูล User ปัจจุบัน
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: Color(0xFF1A2B4C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF1A2B4C)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // แท็บสลับ Recipes / Jobs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onModeChanged(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Recipes',
                          style: TextStyle(
                            color: widget.isRecipeMode
                                ? Colors.black87
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onModeChanged(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Jobs',
                          style: TextStyle(
                            color: !widget.isRecipeMode
                                ? Colors.blue.shade700
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // เนื้อหา
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: widget.isRecipeMode
                  ? _buildSavedRecipesGrid()
                  : _buildSavedJobsGrid(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: ดึงข้อมูลสูตรอาหารที่กดเซฟไว้
  // ==========================================
  Widget _buildSavedRecipesGrid() {
    if (user == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      // ค้นหาสูตรอาหารที่มี UID ของเราอยู่ใน Array 'likes'
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('likes', arrayContains: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "ยังไม่มีสูตรอาหารที่บันทึกไว้",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // ปรับสัดส่วนการ์ดให้สวยงาม
          ),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;

            return _buildItemCard(
              title: data['title'] ?? 'No Title',
              subtitle: 'By ${data['authorName'] ?? 'Unknown'}',
              imageUrl:
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
              iconColor: const Color(0xFFF97316),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailScreen(recipeId: docId, recipeData: data),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================
  // WIDGET: ดึงข้อมูลงานที่กดเซฟไว้
  // ==========================================
  Widget _buildSavedJobsGrid() {
    if (user == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      // ค้นหางานที่มี UID ของเราอยู่ใน Array 'likes'
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('likes', arrayContains: user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "ยังไม่มีงานที่บันทึกไว้",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return GridView.builder(
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String docId = docs[index].id;

            return _buildItemCard(
              title: data['title'] ?? 'Job Title',
              subtitle: data['companyName'] ?? 'Company',
              imageUrl:
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=500&q=80',
              iconColor: Colors.blue.shade600,
              isJob: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobDetailScreen(jobId: docId, jobData: data),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ==========================================
  // WIDGET: การ์ดแสดงผล (ใช้ร่วมกันทั้งเมนูอาหารและงาน)
  // ==========================================
  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required Color iconColor,
    required VoidCallback onTap,
    bool isJob = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      // ไอคอนตามโหมด: อาหารเป็นหัวใจ, งานเป็น Bookmark
                      child: Icon(
                        isJob ? Icons.bookmark : Icons.favorite,
                        size: 16,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A2B4C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
