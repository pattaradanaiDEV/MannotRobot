import 'package:flutter/material.dart';

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
              backgroundColor: Colors.grey,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
    // TODO: รับข้อมูลจาก Firebase
    List<dynamic> trendingItems = [];

    if (trendingItems.isEmpty) {
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
    return SizedBox(
      height: 160,
      child: ListView.builder(
        itemCount: trendingItems.length,
        itemBuilder: (context, index) => const SizedBox(),
      ),
    );
  }

  Widget _buildRecipeFeed(BuildContext context) {
    // TODO: รับข้อมูลจาก Firebase
    List<dynamic> recipes = [];

    if (recipes.isEmpty) {
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
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) => const SizedBox(),
    );
  }

  Widget _buildJobFeed(BuildContext context) {
    // TODO: รับข้อมูลจาก Firebase
    List<dynamic> jobs = [];

    if (jobs.isEmpty) {
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
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, index) => const SizedBox(),
    );
  }
}
