import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'recipe_detail_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  // กำหนด User ID สมมติให้ตรงกับใน Firebase ( likes: ["u101"] )
  final String myId = 'u101';

  final FirestoreService _firestoreService = FirestoreService();

  HomeScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  // ==========================================
  // FUNCTION: Toggle Like (อัปเดตลง Firebase)
  // ==========================================
  Future<void> _toggleLike(String jobId, List<String> currentLikes) async {
    DocumentReference jobRef = FirebaseFirestore.instance.collection('jobs').doc(jobId);

    try {
      if (currentLikes.contains(myId)) {
        await jobRef.update({
          'likes': FieldValue.arrayRemove([myId])
        });
        print("Unlike success for: $jobId");
      } else {
        await jobRef.update({
          'likes': FieldValue.arrayUnion([myId])
        });
        print("Like success for: $jobId");
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

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
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF1A2B4C)),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomTabBar(),
            _buildSectionHeader(isRecipeMode ? 'Trending Now' : 'Featured Jobs', primaryColor),
            _buildTrendingSection(primaryColor),
            const SizedBox(height: 16),
            isRecipeMode ? _buildRecipeFeed(context) : _buildJobFeed(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))),
          Text('View all', style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: Job Feed (ใช้ StreamBuilder ดึงจาก Firebase)
  // ==========================================
  Widget _buildJobFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("ยังไม่มีประกาศรับสมัครงาน", style: TextStyle(color: Colors.grey))));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            var doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            // ใช้ doc.id (Document ID จาก Firebase) เพื่อความแม่นยำในการ Like
            return _buildJobCard(context, data, doc.id);
          },
        );
      },
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> data, String jobId) {
    String title = data['title'] ?? 'Job Title';
    String company = data['companyName'] ?? 'Company';
    String location = data['location'] ?? 'Location';
    String salary = data['salaryRange'] ?? 'N/A';
    String type = data['jobType'] ?? 'FULL-TIME';
    String imageUrl = data['imageUrl'] ?? 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80';

    List<String> currentLikes = List<String>.from(data['likes'] ?? []);
    bool isLiked = currentLikes.contains(myId);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(jobData: data)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, spreadRadius: 2)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                // ปุ่ม Like (GestureDetector อันเดียว ไม่ซ้อนทับ)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleLike(jobId, currentLikes),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      radius: 16,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isLiked ? Colors.red : Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(8)),
                    child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))),
                  const SizedBox(height: 6),
                  _buildIconLabel(Icons.business, company),
                  const SizedBox(height: 4),
                  _buildIconLabel(Icons.location_on, location),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'), radius: 12),
                          const SizedBox(width: 8),
                          Text('Recruiter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        ],
                      ),
                      Text(salary, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade700)),
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

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  // ... (ฟังก์ชัน _buildCustomTabBar, _buildTrendingSection, _buildRecipeFeed เหมือนเดิมที่เคยเขียนไว้) ...
  // หมายเหตุ: อย่าลืมใส่ฟังก์ชัน TabBar และ Trending กลับมาด้วยนะครับ โค้ดด้านบนเน้นแก้ส่วน Job ที่พัง

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTabItem('Recipes', isRecipeMode, () => onModeChanged(true)),
          _buildTabItem('Jobs', !isRecipeMode, () => onModeChanged(false)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(child: Text(label, style: TextStyle(color: isActive ? (label == 'Recipes' ? const Color(0xFFF97316) : Colors.blue.shade600) : Colors.grey.shade600, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildTrendingSection(Color tagColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: isRecipeMode ? _firestoreService.getRecipes() : _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox(height: 160);
        final docs = snapshot.data!.docs;
        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: docs.length > 5 ? 5 : docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildTrendingCard(data['title'] ?? '', isRecipeMode ? data['authorName'] : data['companyName'], data['imageUrl'], tagColor, isHot: index == 0),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrendingCard(String title, String? subtitle, String? imageUrl, Color tagColor, {bool isHot = false}) {
    return Container(
      width: 260,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage(imageUrl ?? ''), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isHot) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(6)), child: const Text('Hot', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getRecipes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("ยังไม่มีสูตรอาหาร"));
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) => _buildRecipeCard(context, snapshot.data!.docs[index].data() as Map<String, dynamic>),
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> data) {
    String title = data['title'] ?? 'Unknown Recipe';
    String author = data['authorName'] ?? 'Unknown Chef';
    String imageUrl = data['imageUrl'] ?? 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80';
    String instructionSnippet = data['instructions'] ?? 'No instructions provided.';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecipeDetailScreen()),
        );
      },
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    radius: 16,
                    child: const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(instructionSnippet, style: TextStyle(color: Colors.grey.shade600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), radius: 12),
                          const SizedBox(width: 8),
                          Text(author, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange.shade400, size: 16),
                          const SizedBox(width: 4),
                          const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
}