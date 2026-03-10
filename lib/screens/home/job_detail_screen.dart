import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  final String jobId;

  // 2. รับค่าผ่าน Constructor
  const JobDetailScreen({
    super.key,
    required this.jobData,
    required this.jobId
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool isBookmarked = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // เช็กสถานะ Bookmark จากข้อมูล likes ใน Firebase
    List<dynamic> likesList = widget.jobData['likes'] ?? [];
    if (user != null) {
      isBookmarked = likesList.contains(user!.uid);
    }
  }

  void _toggleBookmark() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนบันทึกงาน")),
      );
      return;
    }

    setState(() {
      isBookmarked = !isBookmarked;
    });

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId); // เรียกใช้ widget.jobId ได้แล้ว

    if (isBookmarked) {
      await docRef.update({
        'likes': FieldValue.arrayUnion([user!.uid]),
      });
    } else {
      await docRef.update({
        'likes': FieldValue.arrayRemove([user!.uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.jobData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // 3. ใส่ปุ่ม Bookmark ไว้ที่ AppBar (หรือจะไว้ใน Card ก็ได้)
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.blue : Colors.black,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(data),
            const SizedBox(height: 24),
            const Text('Job Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? 'No description provided.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...(data['requirements'] as List<dynamic>? ?? []).map((req) {
              return _buildBulletList(req.toString());
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  // --- ส่วนประกอบ UI ย่อย ---

  Widget _buildHeaderCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(data['logoUrl'] ?? data['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'] ?? 'Job Title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(data['companyName'] ?? 'Company', style: const TextStyle(color: Colors.blue, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag(data['jobType'] ?? 'Full-time', Colors.blue),
              _buildTag('Restaurant', Colors.green),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: _buildIconText(Icons.location_on_outlined, 'Location', data['location'] ?? 'N/A')),
              Expanded(child: _buildIconText(Icons.payments_outlined, 'Salary', data['salaryRange'] ?? 'N/A')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ส่งใบสมัครงานเรียบร้อยแล้ว!")));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade500,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildIconText(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, color: Colors.blue)),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700, height: 1.4))),
        ],
      ),
    );
  }
}