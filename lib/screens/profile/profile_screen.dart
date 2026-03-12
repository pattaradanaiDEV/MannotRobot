import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../post/post_modal.dart';
import '/login.dart';
import '/screens/home/job_detail_screen.dart';
import '/screens/home/recipe_detail_screen.dart';

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
    final String displayName = user?.displayName ?? user?.email ?? 'User';
    final String photoUrl = user?.photoURL ?? '';
    final String initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1A2B4C)),
            onPressed: () => _showSettingsModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(displayName, photoUrl, initial, user?.uid),
            const SizedBox(height: 24),

            _buildStatsRow(user?.uid),
            const SizedBox(height: 24),

            _buildTabToggle(),
            const SizedBox(height: 20),

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

  // --- Header Section ---
  Widget _buildProfileHeader(
    String name,
    String photoUrl,
    String initial,
    String? userId,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: isRecipeMode
                  ? Colors.orange.shade100
                  : Colors.blue.shade100,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? Text(
                      initial,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isRecipeMode
                            ? Colors.orange.shade800
                            : Colors.blue.shade800,
                      ),
                    )
                  : null,
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
        if (isRecipeMode)
          _buildUserRating(userId)
        else
          const Text(
            'Culinary Professional',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildUserRating(String? userId) {
    if (userId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 20);

        final docs = snapshot.data!.docs;
        double totalRating = 0;
        int totalReviews = 0;
        int ratedRecipeCount = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          double rating = (data['rating'] ?? 0.0).toDouble();
          int reviewCount = data['reviewCount'] ?? 0;

          if (rating > 0) {
            totalRating += rating;
            ratedRecipeCount++;
          }
          totalReviews += reviewCount;
        }

        double averageRating = ratedRecipeCount > 0
            ? (totalRating / ratedRecipeCount)
            : 0.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.orange.shade400, size: 18),
            const SizedBox(width: 4),
            Text(
              averageRating > 0 ? averageRating.toStringAsFixed(1) : "0.0",
              style: TextStyle(
                color: Colors.orange.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              '($totalReviews Reviews)',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        );
      },
    );
  }

  // --- Stats Section ---
  Widget _buildStatsRow(String? userId) {
    if (userId == null) return const SizedBox();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(isRecipeMode ? 'recipes' : 'jobs')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        String postCount = snapshot.hasData
            ? snapshot.data!.docs.length.toString()
            : '0';
        return Center(
          child: Column(
            children: [
              Text(
                postCount,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isRecipeMode ? 'Total Recipes' : 'Total Jobs Posted',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Grid Sections ---
  Widget _buildRecipesGrid(BuildContext context, String? userId) {
    return _buildStreamGrid(context, 'recipes', userId, 'New Recipe');
  }

  Widget _buildJobsGrid(BuildContext context, String? userId) {
    return _buildStreamGrid(context, 'jobs', userId, 'New Job');
  }

  Widget _buildStreamGrid(
    BuildContext context,
    String collection,
    String? userId,
    String addLabel,
  ) {
    if (userId == null) return const Center(child: Text("กรุณาเข้าสู่ระบบ"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
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
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == docs.length)
              return _buildAddNewCard(context, addLabel);

            var data = docs[index].data() as Map<String, dynamic>;
            var docId = docs[index].id;

            return GestureDetector(
              onTap: () {
                if (collection == 'jobs') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JobDetailScreen(jobData: data, jobId: docId),
                    ),
                  );
                } else if (collection == 'recipes') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeDetailScreen(recipeData: data, recipeId: docId),
                    ),
                  );
                }
              },
              child: _buildItemCard(
                title: data['title'] ?? 'No Title',
                subTitle: collection == 'recipes'
                    ? '${data['timeMins'] ?? 0}m'
                    : (data['jobType'] ?? 'Full-time'),
                imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
                rating: collection == 'recipes'
                    ? (data['rating'] ?? 0.0).toDouble()
                    : null,
                // 🔴 ส่งค่า reviewCount เพิ่มเข้าไปด้วย
                reviewCount: collection == 'recipes'
                    ? (data['reviewCount'] ?? 0)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  // --- UI Components ---
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
          _buildToggleItem(
            'My Recipes',
            isRecipeMode,
            () => onModeChanged(true),
          ),
          _buildToggleItem(
            'My Jobs',
            !isRecipeMode,
            () => onModeChanged(false),
          ),
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
            boxShadow: isActive
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
                color: isActive
                    ? const Color(0xFF1A2B4C)
                    : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subTitle,
    required String imageUrl,
    double? rating,
    int? reviewCount,
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
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔴 ถ้ามีการส่งค่า rating มา (แสดงว่าเป็นโหมด Recipe)
                    if (rating != null) ...[
                      // 1. ฝั่งซ้าย: คะแนนรีวิว
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange.shade400,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${rating > 0 ? rating.toStringAsFixed(1) : "0.0"} (${reviewCount ?? 0} Reviews)",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      // 2. ฝั่งขวา: ไอคอนนาฬิกา + เวลาทำอาหาร
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade500,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subTitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ]
                    // 🔴 ถ้าไม่มีค่า rating (แสดงว่าเป็นโหมด Job) ให้โชว์ชิดซ้ายปกติ
                    else ...[
                      Text(
                        subTitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCard(BuildContext context, String label) {
    return GestureDetector(
      onTap: () =>
          showDialog(context: context, builder: (context) => const PostModal()),
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

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4C),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
