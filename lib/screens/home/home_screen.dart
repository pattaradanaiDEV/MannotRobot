import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const HomeScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีหลักตามโหมดเพื่อนำไปใช้ในหน้าจอ
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
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF1A2B4C),
            ),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              radius: 18,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomTabBar(),

            // ส่วนหัวข้อ Trending (ข้อความเปลี่ยนตามโหมด)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
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

            // ส่วน Trending แบบเลื่อนแนวนอน
            _buildTrendingSection(primaryColor),

            const SizedBox(height: 16),

            // ส่วน Feed เนื้อหาหลัก
            isRecipeMode ? _buildRecipeFeed(context) : _buildJobFeed(context),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

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
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: isRecipeMode
            ? [
                // ข้อมูล Trending สำหรับ Recipe
                _buildTrendingCard(
                  'Neapolitan Pizza',
                  'Chef Mario',
                  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80',
                  tagColor,
                  isHot: true,
                ),
                const SizedBox(width: 16),
                _buildTrendingCard(
                  'Superfood Quinoa',
                  'Sarah Green',
                  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&q=80',
                  tagColor,
                  isHot: false,
                ),
              ]
            : [
                // ข้อมูล Trending สำหรับ Job
                _buildTrendingCard(
                  'Executive Chef',
                  'The Grand Hotel',
                  'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=500&q=80',
                  tagColor,
                  isHot: true,
                ),
                const SizedBox(width: 16),
                _buildTrendingCard(
                  'Head Baker',
                  'Morning Crust',
                  'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80',
                  tagColor,
                  isHot: false,
                ),
              ],
      ),
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
            ),
            Text(
              isRecipeMode ? 'By $subtitle' : subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ส่วน Feed ของ Recipe (โค้ดเดิม สีส้ม)
  // ==========================================
  Widget _buildRecipeFeed(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // เมื่อกดการ์ดงาน จะเลื่อนไปหน้า JobDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JobDetailScreen()),
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
                        'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        radius: 16,
                        child: const Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.grey,
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
                      const Text(
                        'Pan-Seared Scallops',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Perfectly seared scallops with a lemon butter glaze...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
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
                                'Chef Gordon',
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
                              const Text(
                                '4.8',
                                style: TextStyle(
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
      },
    );
  }

  // ==========================================
  // ส่วน Feed ของ Job (โครงสร้างเดิม แต่ตีมสีฟ้าและข้อมูลงาน)
  // ==========================================
  Widget _buildJobFeed(BuildContext context) {
    // ข้อมูลจำลองสำหรับงาน
    final List<Map<String, String>> jobMockData = [
      {
        'title': 'Head Mixologist',
        'company': 'The Velvet Lounge',
        'location': 'Chicago, IL',
        'salary': '\$60k - \$75k',
        'type': 'FULL-TIME',
        'image':
            'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80',
        'logo': 'https://i.pravatar.cc/150?img=33',
      },
      {
        'title': 'Pastry Chef de Partie',
        'company': 'Hearth & Grain Bakery',
        'location': 'Austin, TX',
        'salary': '\$22 - \$28 / hr',
        'type': 'PART-TIME',
        'image':
            'https://images.unsplash.com/photo-1556281896-e26ee8234be1?w=800&q=80',
        'logo': 'https://i.pravatar.cc/150?img=44',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobMockData.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final job = jobMockData[index];
        return GestureDetector(
          onTap: () {
            // โค้ดสำหรับกดไปหน้า Job Detail
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
                    // รูปภาพสถานที่ทำงาน (ใช้โครงสร้างเดียวกับอาหาร)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        job['image']!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // ป้ายประเภทงาน (เปลี่ยนจากเวลาเป็นประเภทงาน สีฟ้า)
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
                          job['type']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // ปุ่มหัวใจ (สีฟ้า)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        radius: 16,
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.blue.shade600,
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
                        job['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // รวมชื่อบริษัทและสถานที่
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job['company']!,
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
                            job['location']!,
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
                          // โลโก้และชื่อผู้โพสต์
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(job['logo']!),
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
                          // เงินเดือน (ใช้ตัวหนาสีฟ้าให้เด่นชัด)
                          Text(
                            job['salary']!,
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
      },
    );
  }
}
