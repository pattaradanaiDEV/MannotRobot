import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const JobDetailScreen({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool isBookmarked = false;
  List<dynamic> requirements = [];

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // 1. เช็กสถานะการเซฟงาน (Bookmark) ว่า User นี้เคยกดไว้หรือยัง
    List<dynamic> likesList = widget.jobData['likes'] ?? [];
    if (user != null) {
      isBookmarked = likesList.contains(user!.uid);
    }

    // 2. ดึงข้อมูล Requirements
    requirements = widget.jobData['requirements'] ?? [];
  }

  // ฟังก์ชันกดเซฟงาน (อัปเดต Firebase ทันที)
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

    // อัปเดตข้อมูลบน Firestore
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId);
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
    // ดึงข้อมูลพื้นฐานจาก jobData เพื่อนำมาแสดงผล
    String title = widget.jobData['title'] ?? 'Job Title';
    String company = widget.jobData['companyName'] ?? 'Company';
    String location = widget.jobData['location'] ?? 'Location';
    String salary = widget.jobData['salaryRange'] ?? 'N/A';
    String jobType = widget.jobData['jobType'] ?? 'FULL-TIME';
    String description =
        widget.jobData['description'] ?? 'No description provided.';

    // รูปโลโก้และรูปประกอบ
    String logoUrl =
        widget.jobData['logoUrl'] != null &&
            widget.jobData['logoUrl'].toString().isNotEmpty
        ? widget.jobData['logoUrl']
        : 'https://i.pravatar.cc/150?img=33'; // Default logo
    String imageUrl =
        widget.jobData['imageUrl'] ??
        'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80';

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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
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
            // 1. Header Card (รายละเอียดเบื้องต้น)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title & Company
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleBookmark,
                                  child: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? Colors.blue.shade600
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              company,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Recently posted',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Row(
                    children: [
                      _buildTag(jobType, Colors.blue),
                      _buildTag('Active Hiring', Colors.green),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Location & Salary
                  Row(
                    children: [
                      Expanded(
                        child: _buildIconText(
                          Icons.location_on_outlined,
                          'Location',
                          location,
                        ),
                      ),
                      Expanded(
                        child: _buildIconText(
                          Icons.payments_outlined,
                          'Salary',
                          salary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Job Description
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 24),

            // 3. Requirements / Qualifications (ดึงข้อมูลแบบไดนามิก)
            const Text(
              'Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (requirements.isEmpty)
              const Text(
                "ไม่มีระบุคุณสมบัติเฉพาะ",
                style: TextStyle(color: Colors.grey),
              ),
            ...requirements.map((req) => _buildCheckList(req.toString())),

            const SizedBox(height: 24),

            // 4. Gallery (รูปภาพประกอบงาน)
            const Text(
              'Gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildGalleryImage(imageUrl),
                  // สามารถดึงรูปจำลองอื่นๆ มาใส่เพิ่มได้หากต้องการความสวยงาม
                  _buildGalleryImage(
                    'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=500&q=80',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      // แถบเมนูด้านล่าง (Apply Button)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("ส่งใบสมัครงานเรียบร้อยแล้ว!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(String url) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
