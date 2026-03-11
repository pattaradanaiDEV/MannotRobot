import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobId;

  const JobDetailScreen({
    super.key,
    required this.jobData,
    required this.jobId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool isBookmarked = false;
  final user = FirebaseAuth.instance.currentUser;

  // Getter เช็กว่าเป็นเจ้าของโพสต์หรือไม่
  bool get isOwner {
    return user != null && widget.jobData['userId'] == user!.uid;
  }

  @override
  void initState() {
    super.initState();
    List<dynamic> likesList = widget.jobData['likes'] ?? [];
    if (user != null) {
      isBookmarked = likesList.contains(user!.uid);
    }
  }

  void _toggleBookmark() async {
    if (user == null) return;
    setState(() => isBookmarked = !isBookmarked);
    DocumentReference docRef = FirebaseFirestore.instance.collection('jobs').doc(widget.jobId);
    if (isBookmarked) {
      await docRef.update({'likes': FieldValue.arrayUnion([user!.uid])});
    } else {
      await docRef.update({'likes': FieldValue.arrayRemove([user!.uid])});
    }
  }

  // ฟังก์ชันลบโพสต์
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).delete();
              if (mounted) {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pop(context); // กลับหน้าหลัก
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.jobData;
    final String imageUrl = data['imageUrl'] ?? 'https://via.placeholder.com/400x300';
    const imageHeight = 320.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. ภาพ Header
          Positioned(
            top: 0, left: 0, right: 0, height: imageHeight,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),

          // 2. ส่วนเนื้อหาเลื่อนได้
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: imageHeight - 30),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Job Title',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['companyName'] ?? 'Company Name',
                          style: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildTag(data['jobType'] ?? 'Full-time', Colors.blue),
                            const SizedBox(width: 8),
                            _buildTag('Restaurant', Colors.green),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildInfoItem(Icons.location_on_outlined, 'Location', data['location'] ?? 'N/A')),
                            Expanded(child: _buildInfoItem(Icons.payments_outlined, 'Salary', data['salaryRange'] ?? 'N/A')),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text('Job Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          data['description'] ?? 'No description provided.',
                          style: TextStyle(color: Colors.grey.shade800, height: 1.6, fontSize: 15),
                        ),
                        const SizedBox(height: 32),
                        const Text('Requirements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...(data['requirements'] as List<dynamic>? ?? []).map((req) => _buildRequirementItem(req.toString())).toList(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. ปุ่มควบคุมด้านบน (Back, Delete, Bookmark)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(Icons.arrow_back, () => Navigator.pop(context)),
                Row(
                  children: [
                    // ถ้าเป็นเจ้าของโพสต์ ให้เห็นปุ่ม Delete (สีแดง)
                    // ปุ่ม Bookmark เห็นทุกคน
                    _buildCircularButton(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      _toggleBookmark,
                      color: isBookmarked ? Colors.blue : Colors.black,
                    ),
                    const SizedBox(width: 12),
                    if (isOwner) ...[
                      _buildCircularButton(Icons.delete_outline, _confirmDelete, color: Colors.red),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // ถ้าไม่ใช่เจ้าของ ถึงจะเห็นปุ่ม Apply Now
      bottomNavigationBar: !isOwner ? _buildBottomAction() : null,
    );
  }

  // --- Helper Widgets ---

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed, {Color color = Colors.black}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: const Text('Apply Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}