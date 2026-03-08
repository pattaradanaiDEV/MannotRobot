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
    // ดึงชื่อผู้ใช้จาก Firebase
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Pattaradanai';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1A2B4C)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(displayName),
            const SizedBox(height: 24),

            // สถิติแบบดึงจำนวนโพสต์จริง
            _buildStatsRow(user?.uid),
            const SizedBox(height: 24),

            _buildTabToggle(),
            const SizedBox(height: 20),

            // ส่ง context ไปให้ฟังก์ชันสร้าง Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: isRecipeMode
                  ? _buildRecipesGrid(context, user?.uid)
                  : _buildJobsGrid(context, user?.uid),
            ),

            const SizedBox(height: 100), // เว้นระยะด้านล่าง
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
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=500&q=80',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3142),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 14,
              ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            const Text(
              '4.8',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('•', style: TextStyle(color: Colors.grey)),
            ),
            Text(
              '(120 Reviews)',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET: สถิติ (ใช้ StreamBuilder นับจำนวนโพสต์ของตัวเอง)
  // ==========================================
  Widget _buildStatsRow(String? userId) {
    if (userId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(isRecipeMode ? 'recipes' : 'jobs')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        String postCount = '0';
        if (snapshot.hasData) {
          postCount = snapshot.data!.docs.length.toString();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(postCount, isRecipeMode ? 'Recipes' : 'Jobs'),
            _buildStatItem('1.2k', 'Followers'),
            _buildStatItem('280', 'Following'),
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET: แท็บสลับ
  // ==========================================
  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isRecipeMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isRecipeMode
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
                    'My Recipes',
                    style: TextStyle(
                      color: isRecipeMode
                          ? const Color(0xFF1A2B4C)
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
              onTap: () => onModeChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isRecipeMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !isRecipeMode
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
                    'My Jobs',
                    style: TextStyle(
                      color: !isRecipeMode
                          ? const Color(0xFF1A2B4C)
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
    );
  }

  // ==========================================
  // WIDGET: Grid สำหรับ Recipes (ดึงจาก Firebase ของผู้ใช้คนนี้)
  // ==========================================
  Widget _buildRecipesGrid(BuildContext context, String? userId) {
    if (userId == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      // ดึงข้อมูลใน collection 'recipes' ที่ตรงกับ userId ของผู้ใช้ปัจจุบัน
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('userId', isEqualTo: userId)
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
          itemCount: docs.length + 1, // +1 สำหรับปุ่ม New Recipe
          itemBuilder: (context, index) {
            if (index == docs.length)
              return _buildAddNewCard(context, 'New Recipe');

            var data = docs[index].data() as Map<String, dynamic>;
            return _buildItemCard(
              title: data['title'] ?? 'No Title',
              rating: '4.8', // ค่าคะแนนชั่วคราว
              time: '${data['timeMins'] ?? 0}m',
              imageUrl:
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
            );
          },
        );
      },
    );
  }

  // ==========================================
  // WIDGET: Grid สำหรับ Jobs (ดึงจาก Firebase ของผู้ใช้คนนี้)
  // ==========================================
  Widget _buildJobsGrid(BuildContext context, String? userId) {
    if (userId == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      // ดึงข้อมูลใน collection 'jobs' ที่ตรงกับ userId ของผู้ใช้ปัจจุบัน
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('userId', isEqualTo: userId)
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
          itemCount: docs.length + 1, // +1 สำหรับปุ่ม New Job
          itemBuilder: (context, index) {
            if (index == docs.length)
              return _buildAddNewCard(context, 'New Job');

            var data = docs[index].data() as Map<String, dynamic>;
            return _buildItemCard(
              title: data['title'] ?? 'No Title',
              rating: 'New',
              time: data['jobType'] ?? 'Full-time',
              imageUrl:
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=500&q=80',
            );
          },
        );
      },
    );
  }

  // ==========================================
  // WIDGET: การ์ดแสดงผลงาน 1 ชิ้น
  // ==========================================
  Widget _buildItemCard({
    required String title,
    required String rating,
    required String time,
    required String imageUrl,
  }) {
    return Container(
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
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF1A2B4C),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: การ์ดสำหรับกดเพิ่มโพสต์ใหม่
  // ==========================================
  Widget _buildAddNewCard(BuildContext context, String label) {
    return GestureDetector(
      onTap: () {
        // เมื่อกดที่การ์ดนี้ ให้เด้ง Modal แบบเดียวกับปุ่ม + ตรงกลาง
        showDialog(context: context, builder: (context) => const PostModal());
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Color(0xFF1A2B4C), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A2B4C),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
