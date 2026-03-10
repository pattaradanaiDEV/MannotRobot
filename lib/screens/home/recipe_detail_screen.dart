import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final Map<String, dynamic> recipeData;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.recipeData,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isFavorite = false;
  List<dynamic> ingredients = [];
  List<String> instructions = [];

  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  // สำหรับระบบ Rating
  double _userRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 1. เช็กว่า User คนนี้เคยไลก์สูตรนี้หรือยัง
    List<dynamic> likesList = widget.recipeData['likes'] ?? [];
    if (user != null) {
      isFavorite = likesList.contains(user!.uid);
    }

    // 2. ดึงข้อมูลส่วนผสม
    ingredients = widget.recipeData['ingredients'] ?? [];

    // 3. ดึงข้อความวิธีทำ แล้วแยกบรรทัด (\n) เป็นข้อๆ
    String rawInstructions = widget.recipeData['instructions'] ?? '';
    instructions = rawInstructions
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  // ฟังก์ชันกดหัวใจ
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

  // ฟังก์ชันกดส่งรีวิว
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

  // หน้าต่าง (Modal) สำหรับเขียนรีวิว
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

    return Scaffold(
      backgroundColor: const Color(0xFF1A2B4C),
      body: CustomScrollView(
        slivers: [
          // 1. ภาพปก
          SliverAppBar(
            expandedHeight:
                300.0, // เพิ่มความสูงให้เห็นภาพชัดขึ้นได้ถ้ายากให้ภาพเต็มตา
            pinned: true,
            backgroundColor: const Color(0xFF1A2B4C),
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
          ),

          // 2. เนื้อหาหลัก
          SliverToBoxAdapter(
            child: Container(
              // 🔴 ปรับระยะยกตัวขึ้นมา -32 เพื่อให้ขอบโค้งกินพื้นที่ภาพมากขึ้น
              transform: Matrix4.translationValues(0.0, -32.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                // 🔴 ปรับขอบให้มนมากๆ แบบภาพ UI ของคุณ
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Padding(
                // 🔴 เพิ่มระยะห่างระหว่างตัวหนังสือและขอบให้กว้างและสบายตาขึ้น (Top 32, ข้าง 24)
                padding: const EdgeInsets.only(
                  top: 32.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อสูตร และ ปุ่มกดหัวใจ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize:
                                  26, // 🔴 ปรับให้ใหญ่ขึ้นนิดนึงให้เด่นชัด
                              fontWeight:
                                  FontWeight.w900, // หนาขึ้นเพื่อความคล้าย UI
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
                            size: 32, // 🔴 หัวใจใหญ่ขึ้นนิดนึง
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ข้อมูลผู้โพสต์
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
                    const SizedBox(height: 24),

                    // สถิติ
                    Row(
                      children: [
                        _buildStatCard(Icons.access_time, time),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          Icons
                              .local_fire_department_outlined, // 🔴 ใช้ไอคอนไฟให้คล้าย UI (Kcal)
                          rating, // ถ้าคุณมีฟิลด์แคลอรี่สามารถเปลี่ยนตัวแปรตรงนี้ได้
                          iconColor: const Color(0xFFF97316),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.bar_chart, difficulty),
                      ],
                    ),
                    const SizedBox(
                      height: 36,
                    ), // เพิ่มระยะห่างก่อนขึ้น Section ใหม่
                    // ส่วนผสม (Ingredients)
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
                        "ไม่มีข้อมูลส่วนผสม",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...ingredients.map((ingMap) {
                      // 🔴 ส่ง name และ qty แยกกัน เพื่อจัด layout แบบซ้าย-ขวา
                      return _buildBulletItem(
                        name: ingMap['name'] ?? '',
                        qty: ingMap['qty'] ?? '',
                      );
                    }),
                    const SizedBox(height: 36),

                    // วิธีทำ (Instructions)
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

                    // ส่วนของ Reviews
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
                            Icon(
                              Icons.star,
                              color: Colors.orange.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
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

  // =========================================
  // WIDGET HELPERS
  // =========================================

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

  // 🔴 ปรับปรุง Ingredients: ให้ Qty ไปชิดขวามือ
  Widget _buildBulletItem({required String name, required String qty}) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16.0,
      ), // ห่างกันมากขึ้นนิดนึงให้ดูคลีน
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // จัดให้อยู่กึ่งกลางแนวนอน
        children: [
          // จุดไข่ปลา
          Text(
            '•',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 24,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          // ชื่อส่วนผสม (Name) จะอยู่ชิดซ้าย
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
                fontWeight: FontWeight.w500, // หนาขึ้นนิดนึง
              ),
            ),
          ),
          // จำนวน (Qty) จะถูกดันไปชิดขวาสุดอัตโนมัติด้วย Expanded ด้านบน
          if (qty.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text(
              qty,
              style: TextStyle(
                color: Colors.grey.shade500, // สีเทาอ่อนๆ เหมือน UI ต้นฉบับ
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
            padding: const EdgeInsets.all(16),
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
}
