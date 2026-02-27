import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart'; // สร้างไฟล์นี้ใหม่
import '../saved/saved_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_modal.dart'; // สร้างไฟล์นี้ใหม่

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool isRecipeMode = true; // true = อาหาร (สีส้ม), false = งาน (สีฟ้า)

  void _handleModeChange(bool isRecipe) {
    setState(() {
      isRecipeMode = isRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color activeThemeColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    // ส่ง isRecipeMode และ _handleModeChange ไปให้ทุกหน้า!
    final List<Widget> pages = [
      HomeScreen(isRecipeMode: isRecipeMode, onModeChanged: _handleModeChange),
      ExploreScreen(
        isRecipeMode: isRecipeMode,
        onModeChanged: _handleModeChange,
      ),
      const SizedBox(), // ช่องว่างสำหรับปุ่มลอยตรงกลาง
      SavedScreen(isRecipeMode: isRecipeMode, onModeChanged: _handleModeChange),
      ProfileScreen(
        isRecipeMode: isRecipeMode,
        onModeChanged: _handleModeChange,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          backgroundColor: activeThemeColor, // สีปุ่มเปลี่ยนตามโหมด
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: Colors.white, width: 4),
          ),
          onPressed: () {
            // เรียก Dialog หรือ Modal สำหรับโพสต์ขึ้นมา
            showDialog(
              context: context,
              builder: (context) => const PostModal(),
            );
          },
          child: const Icon(Icons.edit, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(
                    Icons.home_outlined,
                    Icons.home,
                    'Home',
                    0,
                    activeThemeColor,
                  ),
                  const SizedBox(width: 20),
                  _buildNavItem(
                    Icons.search_outlined,
                    Icons.search,
                    'Explore',
                    1,
                    activeThemeColor,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(
                    Icons.favorite_border,
                    Icons.favorite,
                    'Saved',
                    3,
                    activeThemeColor,
                  ),
                  const SizedBox(width: 20),
                  _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                    4,
                    activeThemeColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
    Color activeThemeColor,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? activeThemeColor : Colors.grey.shade600;
    return MaterialButton(
      minWidth: 40,
      onPressed: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
