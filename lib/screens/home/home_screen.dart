import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // เพิ่มการ import นี้เพื่อดึง user ปัจจุบัน
import '../../services/firestore_service.dart';

import 'recipe_detail_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  final FirestoreService _firestoreService = FirestoreService();

  HomeScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;
    final user =
        FirebaseAuth.instance.currentUser; // ดึง User เพื่อเอาไว้แสดงรูปโปรไฟล์

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color(0xFF1A2B4C),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // ลบปุ่มกระดิ่งออก และเหลือแค่รูปโปรไฟล์
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 18,
              backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://i.pravatar.cc/150?img=11',
              ), // ดึงรูปจริงถ้ามี
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomTabBar(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRecipeMode ? 'Trending Now' : 'Featured Jobs',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4C),
                    ),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            _buildTrendingSection(primaryColor),

            const SizedBox(height: 16),

            isRecipeMode ? _buildRecipeFeed(context) : _buildJobFeed(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // (โค้ดส่วน _buildCustomTabBar และ _buildTrendingSection เหมือนเดิม ไม่มีการเปลี่ยนแปลง)
  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(8),
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
                    'Recipes',
                    style: TextStyle(
                      color: isRecipeMode
                          ? const Color(0xFFF97316)
                          : Colors.grey.shade600,
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
                  borderRadius: BorderRadius.circular(8),
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
                    'Jobs',
                    style: TextStyle(
                      color: !isRecipeMode
                          ? Colors.blue.shade600
                          : Colors.grey.shade600,
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

  Widget _buildTrendingSection(Color tagColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: isRecipeMode
          ? _firestoreService.getRecipes()
          : _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                "ยังไม่มีข้อมูล Trending",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );

        final docs = snapshot.data!.docs;
        final int itemCount = docs.length > 5 ? 5 : docs.length;

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String title = data['title'] ?? 'No Title';
              String subtitle = isRecipeMode
                  ? 'By ${data['authorName'] ?? 'Unknown'}'
                  : (data['companyName'] ?? 'Company');
              String imageUrl =
                  data['imageUrl'] ??
                  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80';
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildTrendingCard(
                  title,
                  subtitle,
                  imageUrl,
                  tagColor,
                  isHot: index == 0,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingCard(
    String title,
    String subtitle,
    String imageUrl,
    Color tagColor, {
    bool isHot = false,
  }) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHot)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Hot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: Recipe Feed (เพิ่มระบบกดหัวใจ)
  // ==========================================
  Widget _buildRecipeFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "ยังไม่มีสูตรอาหาร",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return _buildRecipeCard(
              context,
              doc.id,
              data,
            ); // ส่ง Document ID ไปด้วย
          },
        );
      },
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String title = data['title'] ?? 'Unknown Recipe';
    String author = data['authorName'] ?? 'Unknown Chef';
    String imageUrl =
        data['imageUrl'] ??
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80';
    String instructionSnippet =
        data['instructions'] ?? 'No instructions provided.';
    String rating = (data['rating'] ?? 0.0).toString();

    // ดึง User ปัจจุบัน และเช็กว่า User คนนี้เคยกด Like โพสต์นี้ไปหรือยัง
    final user = FirebaseAuth.instance.currentUser;
    final List<dynamic> likesList = data['likes'] ?? [];
    final bool isLiked = user != null && likesList.contains(user.uid);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecipeDetailScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // 🔴 อัปเดต: เปลี่ยนไอคอนหัวใจเป็นปุ่มที่กดได้
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("กรุณาเข้าสู่ระบบก่อนกดถูกใจ"),
                          ),
                        );
                        return;
                      }
                      // เรียกฟังก์ชันใน FirestoreService สลับสถานะ Like
                      _firestoreService.toggleRecipeLike(
                        docId,
                        user.uid,
                        !isLiked,
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 18,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isLiked
                            ? Colors.red
                            : Colors.grey.shade600, // ถ้ากดแล้วให้เป็นสีแดง
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instructionSnippet,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=12',
                            ),
                            radius: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            author,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: Job Feed (เพิ่มระบบกดเซฟงาน - ใช้หลักการเดียวกับ Like)
  // ==========================================
  Widget _buildJobFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "ยังไม่มีประกาศรับสมัครงาน",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return _buildJobCard(context, doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String title = data['title'] ?? 'Job Title';
    String company = data['companyName'] ?? 'Company';
    String location = data['location'] ?? 'Location';
    String salary = data['salaryRange'] ?? 'N/A';
    String type = data['jobType'] ?? 'FULL-TIME';
    String imageUrl =
        data['imageUrl'] ??
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80';

    // เช็กสถานะการเซฟงาน (Favorite/Like)
    final user = FirebaseAuth.instance.currentUser;
    final List<dynamic> likesList = data['likes'] ?? [];
    final bool isSaved = user != null && likesList.contains(user.uid);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JobDetailScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // 🔴 อัปเดต: เปลี่ยนไอคอนเซฟงานเป็นปุ่มที่กดได้
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      if (user == null) return;
                      // อนุโลมใช้ฟังก์ชัน toggle Like เดิม (คุณต้องไปเขียน toggleJobLike เพิ่มในอนาคตถ้าอยากแยกชัดเจน)
                      // ในตอนนี้เราใช้ update ตรงๆ เลยเพื่อให้จบในไฟล์เดียว
                      DocumentReference docRef = FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(docId);
                      if (isSaved) {
                        await docRef.update({
                          'likes': FieldValue.arrayRemove([user.uid]),
                        });
                      } else {
                        await docRef.update({
                          'likes': FieldValue.arrayUnion([user.uid]),
                        });
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 18,
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: Colors
                            .blue
                            .shade600, // โหมดงานใช้ไอคอน Bookmark สีฟ้า
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        company,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=33',
                            ),
                            radius: 12,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recruiter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        salary,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
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
