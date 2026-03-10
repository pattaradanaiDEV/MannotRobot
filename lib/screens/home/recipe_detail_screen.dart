import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<bool> ingredientChecked = [];
  List<dynamic> ingredients = [];
  List<String> instructions = [];

  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // 1. เช็กว่า User คนนี้เคยไลก์สูตรนี้หรือยัง
    List<dynamic> likesList = widget.recipeData['likes'] ?? [];
    if (user != null) {
      isFavorite = likesList.contains(user!.uid);
    }

    // 2. ดึงข้อมูลส่วนผสม และสร้างสถานะ Checkbox (ติ๊กถูก) ให้เท่ากับจำนวนส่วนผสม
    ingredients = widget.recipeData['ingredients'] ?? [];
    ingredientChecked = List<bool>.filled(ingredients.length, false);

    // 3. ดึงข้อความวิธีทำ แล้วแยกบรรทัด (\n) เป็นข้อๆ
    String rawInstructions = widget.recipeData['instructions'] ?? '';
    instructions = rawInstructions
        .split('\n')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  // ฟังก์ชันกดหัวใจ (อัปเดต Firebase ด้วย)
  void _toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")));
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    // เรียกฟังก์ชันอัปเดตข้อมูลบน Firestore
    await _firestoreService.toggleRecipeLike(
      widget.recipeId,
      user!.uid,
      isFavorite,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลพื้นฐานจาก recipeData เพื่อนำมาแสดงผล
    String title = widget.recipeData['title'] ?? 'Unknown Recipe';
    String author = widget.recipeData['authorName'] ?? 'Unknown Chef';
    String imageUrl =
        widget.recipeData['imageUrl'] ??
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80';
    String time = '${widget.recipeData['timeMins'] ?? 0} min';
    String rating = (widget.recipeData['rating'] ?? 0.0).toString();
    String difficulty = widget.recipeData['difficulty'] ?? 'Medium';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ส่วนภาพปกด้านบน
          SliverAppBar(
            expandedHeight: 300.0,
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

          // ส่วนเนื้อหาด้านล่าง
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -24.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2B4C),
                              height: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFFF97316),
                            size: 28,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ข้อมูลเชฟ
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5',
                          ),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
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
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF97316),
                            side: const BorderSide(color: Color(0xFFF97316)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Follow'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // สถิติ (เวลา, เรตติ้ง, ความยาก)
                    Row(
                      children: [
                        _buildStatCard(Icons.access_time, time),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          Icons.star_border,
                          rating,
                          iconColor: const Color(0xFFF97316),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(Icons.bar_chart, difficulty),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ส่วนผสม (Ingredients) ดึงจากฐานข้อมูล
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (ingredients.isEmpty)
                      const Text(
                        "ไม่มีข้อมูลส่วนผสม",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...ingredients.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> ingMap =
                          entry.value as Map<String, dynamic>;
                      return _buildIngredientItem(
                        idx,
                        ingMap['qty'] ?? '',
                        ingMap['name'] ?? '',
                      );
                    }),

                    const SizedBox(height: 32),

                    // วิธีทำ (Instructions)
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientItem(int index, String amount, String name) {
    bool isChecked = ingredientChecked[index];
    return InkWell(
      onTap: () =>
          setState(() => ingredientChecked[index] = !ingredientChecked[index]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? const Color(0xFFF97316) : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFFF97316)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: isChecked ? Colors.grey : Colors.black87,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                  ),
                  children: [
                    TextSpan(
                      text: '$amount ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: name),
                  ],
                ),
              ),
            ),
          ],
        ),
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
                width: 30,
                height: 30,
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
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
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
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
