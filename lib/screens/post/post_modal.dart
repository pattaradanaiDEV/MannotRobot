/*
 * File: post_modal.dart
 * Description: Modal สำหรับเลือกประเภทเนื้อหาที่ต้องการโพสต์
 * Responsibilities:
 * - แสดงตัวเลือกให้ผู้ใช้เลือกว่าจะโพสต์ Recipe หรือ Job
 * - นำทางผู้ใช้ไปยังหน้าจอสร้างเนื้อหาที่เกี่ยวข้องเมื่อกดเลือก
 * Author: Pattaradanai Chaitan และ Purich Saenasang (ร่วมกันคิดและออกแบบฟีเจอร์นี้)
 */

import 'package:flutter/material.dart';
import 'create_recipe_screen.dart';
import 'create_job_screen.dart';

/// Dialog สำหรับให้ผู้ใช้เลือกว่าต้องการสร้างโพสต์ประเภทใด.
///
/// จะแสดงเป็นป๊อปอัปขึ้นมากลางหน้าจอ ประกอบด้วยตัวเลือกหลัก 2 อย่างคือ
/// 'Share a recipe'และ 'Hire'.
class PostModal extends StatelessWidget {
  const PostModal({super.key});

  /// สร้างโครงสร้าง UI ของหน้าต่าง Modal.
  ///
  /// ประกอบด้วยข้อความหัวข้อ และจัดเรียงปุ่มตัวเลือก 2 ปุ่มในแนวนอน.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'What would you like to post?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4C),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  context,
                  icon: Icons.restaurant_menu,
                  label: 'Share a recipe',
                  color: Colors.orange.shade50,
                  iconColor: const Color(0xFFF97316),
                  onTap: () {
                    Navigator.pop(context); // ปิด Modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRecipeScreen(),
                      ),
                    );
                  },
                ),
                _buildOption(
                  context,
                  icon: Icons.work_outline,
                  label: 'Hire',
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(context); // ปิด Modal
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateJobScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Option Button แต่ละรายการภายใน Modal.
  ///
  /// รับค่าพารามิเตอร์เพื่อกำหนดลักษณะของปุ่ม:
  /// - [icon]: ไอคอนที่จะแสดงตรงกลาง
  /// - [label]: ข้อความอธิบายใต้ไอคอน
  /// - [color]: สีพื้นหลังของกรอบไอคอน
  /// - [iconColor]: สีของตัวไอคอน
  /// - [onTap]: ฟังก์ชันที่จะทำงานเมื่อผู้ใช้กดปุ่ม
  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 40, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
