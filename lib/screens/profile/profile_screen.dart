import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post_modal.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    // ใช้ displayName จาก Firebase หรือถ้าไม่มีให้แสดงเป็นชื่อ Default
    final String displayName = user?.displayName ?? 'Pattaradanai';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // *** ลบ IconSettings (ฟันเฟือง) ออกเรียบร้อยแล้ว ***
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(displayName),
            const SizedBox(height: 24),

            // สถิติแสดงผลตาม userId ของคนปัจจุบัน
            _buildStatsRow(user?.uid),
            const SizedBox(height: 24),

            _buildTabToggle(),
            const SizedBox(height: 20),

            // แสดงรายการที่โพสต์โดย userId ปัจจุบันเท่านั้น
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isRecipeMode
                  ? _buildRecipesGrid(context, user?.uid)
                  : _buildJobsGrid(context, user?.uid),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: ส่วนหัว (รูปภาพ, ชื่อ, เรตติ้ง)
  // ==========================================
  Widget _buildProfileHeader(String name) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=11', // เปลี่ยนเป็นรูปโปรไฟล์ตัวอย่างที่ดูสะอาดขึ้น
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3142),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4C),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            SizedBox(width: 4),
            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('•', style: TextStyle(color: Colors.grey)),
            ),
            Text('Culinary Specialist', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET: สถิติ (ดึงจำนวนโพสต์จริงของผู้ใช้คนนี้)
  // ==========================================
  Widget _buildStatsRow(String? userId) {
    if (userId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(isRecipeMode ? 'recipes' : 'jobs')
          .where('userId', isEqualTo: userId) // กรองเฉพาะของผู้ใช้ปัจจุบัน
          .snapshots(),
      builder: (context, snapshot) {
        String postCount = snapshot.hasData ? snapshot.data!.docs.length.toString() : '0';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(postCount, isRecipeMode ? 'Recipes' : 'Jobs'),
            _buildStatItem('125', 'Followers'), // Static สำหรับตัวอย่าง UI
            _buildStatItem('84', 'Following'),  // Static สำหรับตัวอย่าง UI
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _buildToggleItem('My Recipes', isRecipeMode, () => onModeChanged(true)),
          _buildToggleItem('My Jobs', !isRecipeMode, () => onModeChanged(false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1A2B4C) : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: Grid สำหรับแสดงโพสต์ (กรองเฉพาะของตัวเอง)
  // ==========================================
  Widget _buildRecipesGrid(BuildContext context, String? userId) {
    return _buildStreamGrid(context, 'recipes', userId, 'New Recipe');
  }

  Widget _buildJobsGrid(BuildContext context, String? userId) {
    return _buildStreamGrid(context, 'jobs', userId, 'New Job');
  }

  Widget _buildStreamGrid(BuildContext context, String collection, String? userId, String addLabel) {
    if (userId == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('userId', isEqualTo: userId) // *** กรองเฉพาะโพสต์ของตัวเอง ***
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == docs.length) return _buildAddNewCard(context, addLabel);

            var data = docs[index].data() as Map<String, dynamic>;
            return _buildItemCard(
              title: data['title'] ?? 'No Title',
              subTitle: collection == 'recipes' ? '${data['timeMins'] ?? 0}m' : (data['jobType'] ?? 'Full-time'),
              imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard({required String title, required String subTitle, required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 14, color: Color(0xFF1A2B4C)),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subTitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCard(BuildContext context, String label) {
    return GestureDetector(
      onTap: () => showDialog(context: context, builder: (context) => const PostModal()),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Color(0xFF1A2B4C), size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Color(0xFF1A2B4C), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}