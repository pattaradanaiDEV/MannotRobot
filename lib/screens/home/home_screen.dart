/*
 * File: home_screen.dart
 * Description: หน้าจอหลักของแอปพลิเคชัน แสดงฟีด Recipes และ Job
 * Responsibilities:
 * - แสดงผลฟีดข้อมูล (Feed) ที่อัปเดตล่าสุดจากฐานข้อมูลแบบเรียลไทม์
 * - แสดงส่วน "Trending Now" สำหรับรายการที่ได้รับความนิยมสูงสุด
 * - จัดการการสลับโหมดการแสดงผลระหว่างสูตรอาหาร (Recipes) และงาน (Jobs)
 * Author: 
 * - Pattaradanai Chaitan (รับผิดชอบส่วนของระบบสูตรอาหารทั้งหมด และระบบ Trending ของสูตรอาหาร)
 * - Purich Saenasang (รับผิดชอบปุ่มสลับโหมดการโชว์ Job/Recipe, ระบบของประกาศรับสมัครงานทั้งหมด และ UI โครงสร้างหลัก)
 * Notes: UI ของรูปโปรไฟล์บริเวณ AppBar ถูกออกแบบและพัฒนาร่วมกัน
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

import 'recipe_detail_screen.dart';
import 'job_detail_screen.dart';

/// วิดเจ็ตหน้าจอหลักของแอปพลิเคชัน.
///
/// คลาสนี้จะทำหน้าที่แสดงรายการเนื้อหาหลัก โดยจะเปลี่ยนข้อมูลและ UI ไปตาม
/// [isRecipeMode] ว่าผู้ใช้กำลังเลือกดูสูตรอาหารหรืองานอยู่.
class HomeScreen extends StatelessWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  final FirestoreService _firestoreService = FirestoreService();

  /// สร้าง [HomeScreen] วิดเจ็ต.
  HomeScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  /// สร้างโครงสร้าง UI ของหน้าจอหลัก.
  ///
  /// ประกอบด้วยแถบด้านบนที่มีรูปโปรไฟล์, แถบสลับโหมด,
  /// ส่วนแสดงรายการยอดนิยม, และส่วนฟีดข้อมูลหลัก.
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    // ดึง User ปัจจุบันเพื่อเอาไว้แสดงรูปโปรไฟล์มุมขวาบน
    final user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;
    final String displayName = user?.displayName ?? user?.email ?? '?';
    final String initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor:
                  primaryColor, // ใช้สีพื้นหลังตามโหมด (ส้ม/ฟ้า) เมื่อไม่มีรูป
              radius: 18,
              // แสดงรูปภาพถ้ามี URL รูป
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                  ? NetworkImage(photoUrl)
                  : null,
              // แสดงตัวอักษรตัวแรกถ้าไม่มีรูปภาพ
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : null,
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
                    isRecipeMode ? 'Trending Now' : 'Recent Jobs',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4C),
                    ),
                  ),
                ],
              ),
            ),
            // ส่วนแสดงรายการ Trend
            _buildTrendingSection(primaryColor),

            const SizedBox(height: 16),

            isRecipeMode ? _buildRecipeFeed(context) : _buildJobFeed(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// สร้างแถบเมนูสำหรับสลับระหว่างโหมด Recipes และ Jobs.
  ///
  /// ผู้ใช้สามารถแตะที่ปุ่มเพื่อใช้ฟังก์ชัน [onModeChanged]
  /// และเปลี่ยนการแสดงผลเนื้อหาของทั้งหน้าจอได้.
  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(20),
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

  /// สร้างส่วนแสดงผลรายการที่กำลังติด Treand.
  ///
  /// ดึงข้อมูลจาก Firestore แบบเรียลไทม์ผ่าน Stream. หากอยู่ในโหมดสูตรอาหาร จะดึง
  /// ข้อมูลสูตรอาหารที่ได้ Rating สูงสุด 5 อันดับแรกมาแสดง.
  Widget _buildTrendingSection(Color tagColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: isRecipeMode
          ? _firestoreService.getTrendingRecipes()
          : _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 160,
            child: Center(
              child: Text(
                "ยังไม่มีข้อมูล Trending",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

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

  /// สร้างการ์ดแสดงผลรายการ Trend แต่ละใบ.
  ///
  /// รับค่าชื่อ [title], คำอธิบายรอง [subtitle], ลิงก์รูปภาพ [imageUrl],
  /// และสีป้ายกำกับ [tagColor]. หากเป็นรายการแรกสุด (Top 1) จะแสดงป้ายกำกับ
  /// คำว่า "Hot" กำกับไว้ที่การ์ดด้วยเงื่อนไข [isHot].
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

  /// สร้างและแสดงรายการ Recipes.
  ///
  /// ดึงข้อมูลสูตรอาหารจากฐานข้อมูล Firebase แบบเรียลไทม์ และสร้าง [ListView]
  /// จัดเรียงตามลำดับเพื่อแสดงเป็นเนื้อหาหลักในหน้าจอ.
  Widget _buildRecipeFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "ยังไม่มีสูตรอาหาร",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final doc = docs[index];
            var data = doc.data() as Map<String, dynamic>;
            return _buildRecipeCard(context, doc.id, data);
          },
        );
      },
    );
  }

  /// สร้างการ์ดแสดงผลสูตรอาหารแบบละเอียดแต่ละใบ.
  ///
  /// ดึงข้อมูลจาก [data] มาแสดงภาพปก ชื่อสูตรอาหาร ผู้เขียน และคะแนนรีวิว.
  /// มีปุ่มหัวใจสำหรับให้ผู้ใช้สามารถแตะเพื่อทำการกดถูกใจได้.
  Widget _buildRecipeCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String title = data['title'] ?? 'Unknown Recipe';
    String author = data['authorName'] ?? 'Unknown Chef';
    String authorPic = data['authorProfileUrl'] ?? ''; // ดึงรูปโปรไฟล์คนโพสต์
    String imageUrl =
        data['imageUrl'] ??
        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80';
    String instructionSnippet = 'No instructions provided.';
    var rawInstructions = data['instructions'];

    if (rawInstructions is List && rawInstructions.isNotEmpty) {
      instructionSnippet = rawInstructions.first.toString();
    } else if (rawInstructions is String) {
      instructionSnippet = rawInstructions;
    }
    String rating = (data['rating'] ?? 0.0).toString();

    final user = FirebaseAuth.instance.currentUser;
    final List<dynamic> likesList = data['likes'] ?? [];
    final bool isLiked = user != null && likesList.contains(user.uid);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RecipeDetailScreen(recipeId: docId, recipeData: data),
          ),
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
                        color: isLiked ? Colors.red : Colors.grey.shade600,
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
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            radius: 12,
                            // เช็กว่ามีรูปโปรไฟล์หรือไม่
                            backgroundImage: authorPic.isNotEmpty
                                ? NetworkImage(authorPic)
                                : null,
                            child: authorPic.isEmpty
                                ? Text(
                                    author.isNotEmpty
                                        ? author[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade800,
                                    ),
                                  )
                                : null,
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
                            "$rating (${data['reviewCount'] ?? 0} Reviews)",
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

  /// สร้างและแสดงรายการ Job.
  ///
  /// ดึงข้อมูลประกาศงานจากฐานข้อมูล Firebase แบบเรียลไทม์ผ่าน Stream
  /// และแสดงผลการ์ดงานเรียงต่อกันเป็นลิสต์ทางแนวตั้ง.
  Widget _buildJobFeed(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "ยังไม่มีประกาศรับสมัครงาน",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

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

  // สร้างการ์ดแสดงผลรายละเอียดประกาศรับสมัครงานแต่ละใบ.
  ///
  /// นำข้อมูล [data] มาแสดงรูปภาพประกอบ ชื่องาน ชื่อบริษัท สถานที่ รูปแบบงาน
  /// และจำนวนเงินเดือน รวมถึงปุ่มสำหรับการบันทึกงานที่สนใจ.
  Widget _buildJobCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    String title = data['title'] ?? 'Job Title';
    String company = data['companyName'] ?? 'Company';
    String companyLogo = data['logoUrl'] ?? '';
    String location = data['location'] ?? 'Location';
    String salary = data['salaryRange'] ?? 'N/A';
    String type = data['jobType'] ?? 'FULL-TIME';
    String imageUrl =
        data['imageUrl'] ??
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80';

    final user = FirebaseAuth.instance.currentUser;
    final List<dynamic> likesList = data['likes'] ?? [];
    final bool isSaved = user != null && likesList.contains(user.uid);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(jobId: docId, jobData: data),
          ),
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      if (user == null) return;
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
                        color: Colors.blue.shade600,
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
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            radius: 12,
                            // เช็กว่าบริษัทมีโลโก้หรือไม่
                            backgroundImage: companyLogo.isNotEmpty
                                ? NetworkImage(companyLogo)
                                : null,
                            child: companyLogo.isEmpty
                                ? Text(
                                    company.isNotEmpty
                                        ? company[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            company,
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
