/*
 * File: recipe_detail_screen.dart
 * Description: หน้าจอแสดงรายละเอียดของ Recipe
 * Responsibilities:
 * - แสดงภาพหน้าปก วัตถุดิบ และขั้นตอนการทำอาหารอย่างละเอียด
 * - จัดการระบบการกดถูกใจ (Like) และแสดงรายการรีวิว
 * - มีระบบให้ผู้ใช้งานประเมินคะแนน (Rating) และเขียนรีวิว (Review) สำหรับสูตรอาหาร
 * Author: Pattaradanai Chaitan
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

/// วิดเจ็ตสำหรับแสดงหน้ารายละเอียดสูตรอาหาร.
///
/// รับค่าข้อมูลสูตรอาหารเบื้องต้น เพื่อแสดงผลเนื้อหาฉบับเต็ม
/// รวมถึงดึงข้อมูลรีวิวเพิ่มเติมจาก Firestore.
class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  /// ข้อมูลสูตรอาหารที่ถูกส่งมาจากหน้าจอก่อนหน้า.
  final Map<String, dynamic> recipeData;

  /// สร้าง [RecipeDetailScreen] พร้อมกับข้อมูลสูตรอาหารที่ต้องการแสดง.
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.recipeData,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

/// จัดการสถานะ (State) ของหน้าจอรายละเอียดสูตรอาหาร.
class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  /// สถานะการกดถูกใจสูตรอาหารของผู้ใช้ปัจจุบัน.
  bool isFavorite = false;
  List<dynamic> ingredients = [];
  List<String> instructions = [];

  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  // สำหรับระบบ Rating
  double _userRating = 0;
  final TextEditingController _commentController = TextEditingController();

  /// เริ่มสถานะการทำงานและจัดเตรียมข้อมูลของหน้าจอ.
  ///
  /// ตรวจสอบการกดถูกใจของผู้ใช้ปัจจุบัน ดึงข้อมูลวัตถุดิบ
  /// และแปลงข้อความวิธีทำให้เป็นรูปแบบ List เพื่อนำไปสร้าง UI.
  @override
  void initState() {
    super.initState();

    List<dynamic> likesList = widget.recipeData['likes'] ?? [];
    if (user != null) {
      isFavorite = likesList.contains(user!.uid);
    }

    ingredients = widget.recipeData['ingredients'] ?? [];

    var rawInst = widget.recipeData['instructions'];
    if (rawInst is List) {
      instructions = List<String>.from(rawInst);
    } else if (rawInst is String) {
      instructions = rawInst
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .toList();
    } else {
      instructions = [];
    }
  }

  /// สลับสถานะการกดถูกใจ (Favorite) ของสูตรอาหารนี้.
  ///
  /// ฟังก์ชันนี้จะทำการเรียกใช้ Service เพื่ออัปเดตข้อมูลบน Firestore.
  /// หากผู้ใช้ยังไม่ได้เข้าสู่ระบบ จะแสดงข้อความแจ้งเตือน [SnackBar].
  void _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")));
      return;
    }
    setState(() => isFavorite = !isFavorite);
    await _firestoreService.toggleRecipeLike(
      widget.recipeId,
      user!.uid,
      isFavorite,
    );
  }

  /// บันทึกข้อมูลรีวิวและคะแนนดาวของผู้ใช้ลงใน Database.
  ///
  /// ฟังก์ชันนี้เป็นแบบ Async โดยจะทำการส่งข้อมูลผ่าน Network และแสดงหน้าต่าง Loading ระหว่างรอดำเนินการ.
  /// แสดงข้อความแจ้งเตือนสำเร็จเมื่อเสร็จสิ้น หรือแสดง Exception หากการอัปโหลดล้มเหลว.
  ///
  /// Side effects:
  /// - เพิ่มรีวิวใหม่ใน Collection ของสูตรอาหาร
  /// - ล้างค่าคะแนนดาว `_userRating` และเคลียร์ข้อความใน `_commentController` เมื่อทำงานสำเร็จ
  void _submitReview() async {
    if (_userRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาให้คะแนนดาวด้วยครับ")));
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _firestoreService.addRecipeReview(
        widget.recipeId,
        _userRating,
        _commentController.text,
      );

      if (context.mounted) {
        Navigator.pop(context); // ปิด Loading
        Navigator.pop(context); // ปิด Modal รีวิว
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ขอบคุณสำหรับรีวิวครับ!")));
        setState(() {
          _userRating = 0;
          _commentController.clear();
        });
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // ปิด Loading ก่อน
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  /// แสดงหน้าต่าง Pop-up สำหรับให้ผู้ใช้ให้คะแนนและเขียนรีวิว.
  ///
  /// ฟังก์ชันนี้จะตรวจสอบสถานะการล็อกอินก่อน หากยังไม่ล็อกอินจะแจ้งเตือนให้เข้าสู่ระบบ
  /// และหากผ่านเงื่อนไขจะแสดงแบบฟอร์มให้กรอกรีวิวได้.
  void _showReviewModal() {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนรีวิว")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              // ป้องกันคีย์บอร์ดบังฟอร์มด้วยการ
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate this recipe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.orange.shade400,
                          size: 40,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _userRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us what you think...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit Review',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// สร้างโครงสร้าง UI หน้าจอรายละเอียดสูตรอาหารหลัก.
  ///
  /// ใช้ [CustomScrollView] และ [SliverAppBar] เพื่อรองรับเอฟเฟกต์การเลื่อนหน้าจอที่ทำให้
  /// รูปหน้าปกด้านบนสามารถย่อและขยายได้ ประกอบด้วยส่วนข้อมูล วัตถุดิบ ขั้นตอน และส่วนของรีวิว.
  @override
  Widget build(BuildContext context) {
    String title = widget.recipeData['title'] ?? 'Unknown Recipe';
    String author = widget.recipeData['authorName'] ?? 'Unknown Chef';
    String authorPic = widget.recipeData['authorProfileUrl'] ?? '';
    String imageUrl =
        widget.recipeData['imageUrl'] ??
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80';
    String time = '${widget.recipeData['timeMins'] ?? 0} min';
    String rating = (widget.recipeData['rating'] ?? 0.0).toString();
    String difficulty = widget.recipeData['difficulty'] ?? 'Medium';

    List<String> tags =
        (widget.recipeData['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ส่วนหน้าปกสูตรอาหาร
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Container(
                  height: 30,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ส่วนเนื้อหาข้อมูลสูตรอาหาร
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ส่วนชื่อเมนูอาหารและปุ่ม Favorit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A2B4C),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: _toggleFavorite,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFFF97316),
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    //  ส่วนข้อมูลผู้เขียนสูตร
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          radius: 20,
                          backgroundImage: authorPic.isNotEmpty
                              ? NetworkImage(authorPic)
                              : null,
                          child: authorPic.isEmpty
                              ? Text(
                                  author.isNotEmpty
                                      ? author[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Chef',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: tags
                            .map((tag) => _buildDisplayTag(tag))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ส่วนข้อมูลสถิติ
                    Row(
                      children: [
                        _buildStatCard(Icons.access_time, time),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          Icons.star,
                          rating,
                          iconColor: const Color(0xFFF97316),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.bar_chart, difficulty),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // ส่วนวัตถุดิบ
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ingredients.isEmpty)
                      const Text(
                        "ไม่มีข้อมูลวัตถุดิบ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...ingredients.map((ingMap) {
                      return _buildBulletItem(
                        name: ingMap['name'] ?? '',
                        qty: ingMap['qty'] ?? '',
                      );
                    }),
                    const SizedBox(height: 36),

                    //ส่วนวิธ๊ทำอาหาร
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (instructions.isEmpty)
                      const Text(
                        "ไม่มีข้อมูลวิธีทำ",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...instructions.asMap().entries.map((entry) {
                      int step = entry.key + 1;
                      String desc = entry.value;
                      bool isLast = step == instructions.length;
                      return _buildInstructionStep(
                        step: step,
                        title: 'Step $step',
                        desc: desc,
                        isLast: isLast,
                      );
                    }),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 24),

                    // ส่วนรีวิว
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Reviews ($rating)',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                // แปลงคะแนนที่ดึงมาให้เป็นตัวเลข
                                double numRating =
                                    double.tryParse(rating) ?? 0.0;

                                if (index < numRating.floor()) {
                                  return Icon(
                                    Icons.star,
                                    color: Colors.orange.shade400,
                                    size: 20,
                                  );
                                } else if (index < numRating) {
                                  return Icon(
                                    Icons.star_half,
                                    color: Colors.orange.shade400,
                                    size: 20,
                                  );
                                } else {
                                  return Icon(
                                    Icons.star_border,
                                    color: Colors.orange.shade400,
                                    size: 20,
                                  );
                                }
                              }),
                            ),
                            Text(
                              "(${widget.recipeData['reviewCount'] ?? 0} Reviews)",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _showAllReviewsModal,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFFF7ED),
                            foregroundColor: const Color(0xFFF97316),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'See all',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // แสดง 5 รีวิว
                    _buildReviewsList(),

                    const SizedBox(height: 24),

                    // วิดเจ็ตรีวิว
                    _buildRateRecipeUI(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างวิดเจ็ตแสดง Tag หมวดหมู่ของอาหาร.
  ///
  /// รับค่า [label] เพื่อแสดงเป็นข้อความในปุ่ม.
  Widget _buildDisplayTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.orange.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// สร้างการ์ดแสดงข้อมูลสถิติแบบย่อ.
  ///
  /// รับไอคอน [icon] ข้อความแสดงค่า [value] และสามารถปรับแต่งสีไอคอน [iconColor] ได้
  /// เพื่อใช้แสดงข้อมูลเช่น เวลาที่ใช้, คะแนนดาว หรือระดับความยาก.
  Widget _buildStatCard(
    IconData icon,
    String value, {
    Color iconColor = const Color(0xFFF97316),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// สร้างรายการวัตถุดิบแบบ Bullet point.
  ///
  /// แสดงชื่อวัตถุดิบ [name] และปริมาณ [qty] จัดเรียงกระจายตามแนวนอน.
  Widget _buildBulletItem({required String name, required String qty}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '•',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 24,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (qty.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text(
              qty,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }

  /// สร้างรายการขั้นตอนการทำอาหาร.
  ///
  /// แสดงตัวเลขขั้นตอน [step] หัวข้อ [title] และข้อความอธิบายความกว้างยาว [desc]
  Widget _buildInstructionStep({
    required int step,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF97316), width: 2),
                  color: step == 1 ? const Color(0xFFF97316) : Colors.white,
                ),
                child: Center(
                  child: Text(
                    step.toString(),
                    style: TextStyle(
                      color: step == 1 ? Colors.white : const Color(0xFFF97316),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างรายการแสดงผลรีวิว 5 อันดับล่าสุด.
  ///
  /// ฟังก์ชันนี้จะดึงข้อมูลผ่านสตรีมแบบ Async เพื่อแสดงความคิดเห็นใหม่ๆ แบบเรียลไทม์.
  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('reviews')
          .orderBy('rating', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "ยังไม่มีรีวิวสำหรับสูตรนี้ เป็นคนแรกที่รีวิวสิ!",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index].data() as Map<String, dynamic>;
            return _buildReviewCard(review);
          },
        );
      },
    );
  }

  /// สร้างการ์ดแสดงผลข้อมูลรีวิวแต่ละรายการ.
  ///
  /// นำข้อมูล [review] มาจัดเรียงเพื่อแสดงภาพโปรไฟล์ ชื่อผู้ใช้ สัญลักษณ์ดาว (Rating) และเนื้อหาความคิดเห็น.
  Widget _buildReviewCard(Map<String, dynamic> review) {
    String name = review['userName'] ?? 'Anonymous';
    String photoUrl = review['userPhoto'] ?? '';
    double rating = (review['rating'] ?? 0).toDouble();
    String comment = review['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            radius: 20,
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : null,
            child: photoUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.grey),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange.shade400,
                      size: 14,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างส่วน UI สำหรับให้ผู้ใช้ทำการให้คะแนน.
  ///
  /// ดึงข้อมูลจาก Database เพื่อเช็กว่าผู้ใช้ปัจจุบันได้เขียนรีวิวเมนูนี้ไปแล้วหรือไม่.
  /// หากเคยเขียนไปแล้ว ระบบจะซ่อนปุ่มเขียนรีวิวและแสดงเป็นกล่องข้อความแจ้งเตือนแทน.
  Widget _buildRateRecipeUI() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('reviews')
          .where('userId', isEqualTo: user?.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'You have already reviewed this recipe.',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate this recipe',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star_border,
                      color: Colors.grey.shade300,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showReviewModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Write a Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  /// แสดงหน้าต่าง Bottom Sheet เพื่อดูรายการรีวิวของสูตรอาหารนี้ทั้งหมด.
  ///
  /// ดึงข้อมูลรีวิวทั้งหมดจาก Firestore
  /// และแสดงในรูปแบบรายการที่สามารถ Scroll ดูได้ภายในหน้าต่าง.
  void _showAllReviewsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // อนุญาตให้ยืดความสูงได้
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // ความสูงเริ่มต้น 80% ของจอ
          minChildSize: 0.5,
          maxChildSize: 0.95, // ยืดได้สูงสุด 95% ของจอ
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header ของ Modal
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // เนื้อหารีวิวทั้งหมด
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('recipes')
                        .doc(widget.recipeId)
                        .collection('reviews')
                        .orderBy('rating', descending: true)
                        // 🔴 เอา .limit(5) ออก เพื่อให้ดึงมาทั้งหมด
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "ยังไม่มีรีวิว",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final reviews = snapshot.data!.docs;

                      return ListView.builder(
                        controller:
                            scrollController, // ให้ Scroll ไปพร้อมกับ Modal ได้
                        padding: const EdgeInsets.all(20),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review =
                              reviews[index].data() as Map<String, dynamic>;
                          return _buildReviewCard(review);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
