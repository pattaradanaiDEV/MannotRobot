import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const ExploreScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ควบคุมสถานะของ Chip ที่ถูกเลือก (0: All, 1: Recipes, 2: Jobs, 3: Chefs)
  int selectedFilterIndex = 0;

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // อัปเดต Chip อัตโนมัติเมื่อโหมดเปลี่ยนจากหน้าอื่น
    if (widget.isRecipeMode && selectedFilterIndex == 2) {
      selectedFilterIndex = 1;
    } else if (!widget.isRecipeMode && selectedFilterIndex == 1) {
      selectedFilterIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงสี Theme หลัก (ส้ม หรือ ฟ้า) มาใช้ตกแต่งจุดต่างๆ
    final Color primaryColor = widget.isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Color(0xFF1A2B4C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ช่อง Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search recipes, jobs, or chefs...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(
                    Icons.tune,
                    color: Colors.grey,
                  ), // ไอคอนฟิลเตอร์
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Filter Chips (All, Recipes, Jobs, Chefs)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(0, 'All', primaryColor),
                  _buildFilterChip(1, 'Recipes', primaryColor),
                  _buildFilterChip(2, 'Jobs', primaryColor),
                  _buildFilterChip(3, 'Chefs', primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Trending Now Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trending Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B4C),
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildTrendingHorizontalList(primaryColor),

            const SizedBox(height: 32),

            // 4. Explore by Category Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryGrid(),

            const SizedBox(height: 32),

            // 5. Recent Opportunities Section (งานล่าสุด)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recent Opportunities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2B4C),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentOpportunities(primaryColor),

            // เว้นที่ว่างด้านล่างให้ Navbar ไม่บังเนื้อหา
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // =========================================
  // WIDGET HELPERS
  // =========================================

  // สร้างปุ่ม Filter Chip แต่ละอัน
  Widget _buildFilterChip(int index, String label, Color primaryColor) {
    final bool isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilterIndex = index);
        // เชื่อมต่อ Logic: ถ้ากด Recipes ให้แอปเปลี่ยนเป็นสีส้ม, ถ้ากด Jobs ให้แอปเปลี่ยนเป็นสีฟ้า
        if (index == 1) widget.onModeChanged(true);
        if (index == 2) widget.onModeChanged(false);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2D3142)
              : Colors.white, // สีเทาเข้มเกือบดำตอนเลือก
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D3142) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // สร้างรายการ Trending Now (เลื่อนแนวนอน)
  Widget _buildTrendingHorizontalList(Color primaryColor) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // การ์ดสูตรอาหาร
          _buildTrendingCard(
            title: 'Hawaiian Poke Bowl',
            subtitle: 'by Chef Marco',
            imageUrl:
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80',
            tagLabel: 'Recipe',
            tagIcon: Icons.restaurant,
            bottomValue: '4.9',
            bottomIcon: Icons.star,
            bottomIconColor: Colors.amber,
          ),
          const SizedBox(width: 16),
          // การ์ดงาน
          _buildTrendingCard(
            title: 'Head Mixologist',
            subtitle: 'The Velvet Room',
            imageUrl:
                'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=500&q=80',
            tagLabel: 'Job',
            tagIcon: Icons.work,
            bottomValue: 'Full-time',
            bottomIcon: null,
            bottomIconColor: Colors.transparent,
            isValueChip: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required String tagLabel,
    required IconData tagIcon,
    required String bottomValue,
    IconData? bottomIcon,
    required Color bottomIconColor,
    bool isValueChip = false,
  }) {
    return Container(
      width: 240,
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
          // รูปภาพและป้าย Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(tagIcon, size: 12, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        tagLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ข้อมูลด้านล่างรูป
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A2B4C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isValueChip
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              bottomValue,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                bottomIcon,
                                size: 14,
                                color: bottomIconColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                bottomValue,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                    Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Colors.grey.shade400,
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

  // สร้าง Grid หมวดหมู่ (Mains, Pastry, Drinks, Vegan)
  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCategoryItem(
            'Mains',
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
          ),
          _buildCategoryItem(
            'Pastry',
            'https://images.unsplash.com/photo-1556281896-e26ee8234be1?w=500&q=80',
          ),
          _buildCategoryItem(
            'Drinks',
            'https://images.unsplash.com/photo-1536935338788-846bb9981813?w=500&q=80',
          ),
          _buildCategoryItem(
            'Vegan',
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(
            0.4,
          ), // ทำให้ภาพมืดลงเพื่อให้ตัวหนังสือเด่น
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // สร้าง List ของ Recent Opportunities (งาน)
  Widget _buildRecentOpportunities(Color primaryColor) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildOpportunityItem(
          icon: Icons.restaurant,
          title: 'Sous Chef',
          company: 'Bistro Lumière • Downtown',
          timeAgo: '2h ago',
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 12),
        _buildOpportunityItem(
          icon: Icons.local_cafe,
          title: 'Barista',
          company: 'Morning Brew Co. • Westside',
          timeAgo: '5h ago',
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildOpportunityItem({
    required IconData icon,
    required String title,
    required String company,
    required String timeAgo,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // ไอคอนสี่เหลี่ยมด้านซ้าย
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          // ข้อมูลงาน
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A2B4C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          // ปุ่ม Apply และเวลา
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeAgo,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
