import 'package:flutter/material.dart';

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
  // ข้อมูลจำลองสำหรับสูตรอาหารที่บันทึกไว้
  final List<Map<String, dynamic>> savedRecipes = [
    {
      'title': 'Avocado Salad Bowl',
      'author': 'Elena Chef',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
      'isSaved': true,
    },
    {
      'title': 'Artisan Pizza',
      'author': 'Marco Rossi',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80',
      'isSaved': true,
    },
    {
      'title': 'Morning Toast',
      'author': 'Sarah Lee',
      'rating': '5.0',
      'image':
          'https://images.unsplash.com/photo-1484723091791-009f52f451f8?w=500&q=80',
      'isSaved': true,
    },
    {
      'title': 'Spicy Ramen',
      'author': 'Kenji O.',
      'rating': '4.7',
      'image':
          'https://images.unsplash.com/photo-1552611052-33e04de081de?w=500&q=80',
      'isSaved': true,
    },
  ];

  // ข้อมูลจำลองสำหรับงานที่บันทึกไว้ (อิงตามภาพ UI ล่าสุด)
  final List<Map<String, dynamic>> savedJobs = [
    {
      'title': 'Executive Chef',
      'company': 'Le Bistro Moderne',
      'location': 'San Francisco, CA',
      'salary': '\$85k - \$110k',
      'color': const Color(0xFFF3B896),
      'icon': Icons.restaurant_menu,
      'isSaved': true,
    },
    {
      'title': 'Sous Chef',
      'company': 'Green Kitchen Stories',
      'location': 'Austin, TX',
      'salary': '\$55k - \$65k',
      'color': const Color(0xFF4A6B3A),
      'icon': Icons.eco_outlined,
      'isSaved': true,
    },
    {
      'title': 'Pastry Chef',
      'company': 'Farm & Table',
      'location': 'Portland, OR',
      'salary': '\$50k - \$60k',
      'color': const Color(0xFF2C5C4D),
      'icon': Icons.cake_outlined,
      'isSaved': true,
    },
    {
      'title': 'Head Line Cook',
      'company': 'Ocean Seafood',
      'location': 'Seattle, WA',
      'salary': '\$22/hr',
      'color': const Color(0xFF0C6B69),
      'icon': Icons.set_meal_outlined,
      'isSaved': true,
    },
    {
      'title': 'Restaurant Manager',
      'company': 'Zen Eats',
      'location': 'Chicago, IL',
      'salary': '\$65k - \$75k',
      'color': const Color(0xFFA5B978),
      'icon': Icons.storefront_outlined,
      'isSaved': true,
    },
  ];

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
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF1A2B4C),
            ), // ไอคอนฟิลเตอร์มุมขวาบน
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. แท็บสลับ Recipes / Jobs
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
                    onTap: () => widget.onModeChanged(
                      true,
                    ), // กดแล้วบอก MainLayout ให้เปลี่ยนเป็นโหมด Recipe
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: widget.isRecipeMode
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
                    onTap: () => widget.onModeChanged(
                      false,
                    ), // กดแล้วบอก MainLayout ให้เปลี่ยนเป็นโหมด Job
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !widget.isRecipeMode
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
                            color: !widget.isRecipeMode
                                ? Colors.green.shade700
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

          // 2. เนื้อหาตามแท็บที่เลือก (Recipes Grid หรือ Jobs List)
          Expanded(
            child: widget.isRecipeMode
                ? _buildSavedRecipesGrid()
                : _buildSavedJobsList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: ส่วนแสดงผล Recipes (Grid View)
  // ==========================================
  Widget _buildSavedRecipesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        80,
      ), // เผื่อระยะด้านล่างให้ Navbar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: savedRecipes.length,
      itemBuilder: (context, index) {
        final item = savedRecipes[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
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
                        item['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['rating'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                      item['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'by ${item['author']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => savedRecipes[index]['isSaved'] =
                                !savedRecipes[index]['isSaved'],
                          ),
                          child: Icon(
                            item['isSaved']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item['isSaved']
                                ? const Color(0xFFF97316)
                                : Colors.grey.shade400,
                            size: 20,
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
      },
    );
  }

  // ==========================================
  // WIDGET: ส่วนแสดงผล Jobs (List View แบบในภาพล่าสุด)
  // ==========================================
  Widget _buildSavedJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        80,
      ), // เผื่อระยะด้านล่างให้ Navbar
      itemCount: savedJobs.length,
      itemBuilder: (context, index) {
        final job = savedJobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. โลโก้สี่เหลี่ยมด้านซ้าย
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: job['color'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    job['icon'],
                    color: Colors.white.withOpacity(0.8),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 2. ข้อมูลตรงกลาง (Title, Company, Location, Salary)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B4C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['company'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ),
                        Text(
                          job['salary'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. ไอคอนหัวใจสีเขียวด้านขวา
              GestureDetector(
                onTap: () {
                  setState(
                    () => savedJobs[index]['isSaved'] =
                        !savedJobs[index]['isSaved'],
                  );
                },
                child: Icon(
                  job['isSaved'] ? Icons.favorite : Icons.favorite_border,
                  color: job['isSaved']
                      ? Colors.green.shade700
                      : Colors.grey.shade400,
                  size: 26,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
