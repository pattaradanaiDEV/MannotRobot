/*
 * File: main_layout.dart
 * Description: กำหนดหน้าจอโครงสร้างหลักของแอปพลิเคชัน รวมถึง Bottom Navigation bar
 * Responsibilities:
 * - จัดการการสลับหน้าจอระหว่าง Home, Explore, Saved และ Profile
 * - ควบคุมและจัดเก็บสถานะโหมดการทำงานหลัก (Recipe / Job)
 * Author: Pattaradanai Chaitan, Purich Saenasang
 */

import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../saved/saved_screen.dart';
import '../profile/profile_screen.dart';
import '../post/post_modal.dart';

/// วิดเจ็ตหลักที่ทำหน้าที่เป็นโครงสร้างพื้นฐานของแอปพลิเคชัน.
///
/// คลาสนี้จัดการสถานะของแถบนำทาง (Bottom Navigation Bar) และเก็บสถานะโหมดการทำงาน
/// เพื่อส่งค่าไปยังหน้าจอย่อยต่างๆ ภายในแอปพลิเคชัน.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  /// Index ของหน้าจอที่แสดงผลปัจจุบัน.
  int _currentIndex = 0;

  /// สถานะโหมดการแสดงผลปัจจุบัน โดย `true` หมายถึงโหมด Recipe และ `false` หมายถึงโหมด Job.
  bool isRecipeMode = true;

  /// อัปเดตโหมดการทำงานของแอปพลิเคชัน.
  ///
  /// รับค่า [isRecipe] เป็น `true` เพื่อสลับไปยังโหมด Recipe
  /// หรือ `false` เพื่อสลับไปยังโหมด Job พร้อมกับรีเฟรชหน้าจอ.
  void _handleModeChange(bool isRecipe) {
    setState(() {
      isRecipeMode = isRecipe;
    });
  }

  /// สร้างโครงสร้าง UI หลักของแอปพลิเคชัน.
  ///
  /// ประกอบด้วยหน้าจอย่อย Floating Action Button และแถบนำทางด้านล่าง.
  @override
  Widget build(BuildContext context) {
    // กำหนดสีธีมหลักตามโหมดการแสดงผล (สีส้มสำหรับ Recipe, สีฟ้าสำหรับ Job)
    final Color activeThemeColor = isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    // รายการหน้าจอย่อยทั้งหมดที่เชื่อมกับแถบนำทางด้านล่าง
    // มีการส่ง isRecipeMode และ _handleModeChange ไปให้ทุกหน้าเพื่อใช้งานด้วยกัน
    final List<Widget> pages = [
      HomeScreen(isRecipeMode: isRecipeMode, onModeChanged: _handleModeChange),
      ExploreScreen(
        isRecipeMode: isRecipeMode,
        onModeChanged: _handleModeChange,
      ),

      const SizedBox(), // ช่องว่างเว้นไว้สำหรับปุ่ม Floating Action Button ตรงกลาง

      SavedScreen(isRecipeMode: isRecipeMode, onModeChanged: _handleModeChange),
      ProfileScreen(
        isRecipeMode: isRecipeMode,
        onModeChanged: _handleModeChange,
      ),
    ];

    return Scaffold(
      // ป้องกันไม่ให้ UI โดนดันขึ้นเมื่อคีย์บอร์ดเด้งขึ้นมา
      resizeToAvoidBottomInset: false,

      // แสดงหน้าจอย่อยตาม Index
      body: pages[_currentIndex],

      // ส่วนของ Floating Action Button สำหรับ Post
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          backgroundColor: activeThemeColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const PostModal(),
            );
          },
          child: const Icon(Icons.edit, color: Colors.white, size: 28),
        ),
      ),

      // กำหนดตำแหน่งปุ่มลอยให้อยู่ตรงกลางของ Navigation bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ส่วนของแถบนำทางด้านล่าง Bottom Navigation Bar
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

  /// สร้างปุ่มเมนูนำทาง Navigation Item แต่ละรายการบน Bottom Navigation Bar.
  ///
  /// รับค่าพารามิเตอร์เพื่อกำหนด UI ของปุ่ม ได้แก่:
  /// - [unselectedIcon]: ไอคอนที่จะแสดงเมื่อไม่ได้ถูกเลือก
  /// - [selectedIcon]: ไอคอนที่จะแสดงเมื่อถูกเลือก
  /// - [label]: ข้อความชื่อเมนู
  /// - [index]: ดัชนีตำแหน่งของเมนูนั้นๆ
  /// - [activeThemeColor]: สีธีมหลักที่ใช้งานอยู่ตามโหมดปัจจุบัน
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
      // เมื่อกดปุ่ม ให้อัปเดตสถานะ Index ไปที่ค่า Index ของปุ่มนั้น
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
