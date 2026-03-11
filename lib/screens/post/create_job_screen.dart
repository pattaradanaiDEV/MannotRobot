import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/job.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  // State variables
  int jobTypeIndex = 0;
  final List<String> jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
  ];

  // Services & Controllers
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // สำหรับคุณสมบัติ (Dynamic Requirements)
  List<String> requirements = [

  ];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับส่งข้อมูลงานขึ้น Firebase
  Future<void> _handlePostJob() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อนโพสต์งาน")),
      );
      return;
    }
    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกชื่อตำแหน่งและชื่อบริษัท")),
      );
      return;
    }

    // สร้างก้อนข้อมูล Job Object
    Job newJob = Job(
      userId: user.uid,
      recruiterName: user.displayName ?? "Anonymous Recruiter",
      companyName: _companyController.text,
      title: _titleController.text,
      jobType: jobTypes[jobTypeIndex],
      salaryRange:
          "\฿${_minSalaryController.text} - \฿${_maxSalaryController.text}",
      location: _locationController.text,
      description: _descriptionController.text,
      requirements: requirements,
      logoUrl: user.photoURL ?? "", // ใช้รูปโปรไฟล์เป็นโลโก้เบื้องต้น หรือเว้นว่างไว้
      imageUrl: "https://images.unsplash.com/photo-1556910103-1c02745aae4d",
      likes: [],
    );

    try {
      await _firestoreService.addJob(newJob);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("โพสต์ประกาศรับสมัครงานสำเร็จ!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล User ปัจจุบัน
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Anonymous";
    final String photoUrl = user?.photoURL ?? "";
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post a New Job',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 25, // ปรับขนาดให้พอดี
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Text(
                        initial,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName, // แสดงชื่อจริงจาก Firebase
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Posting publicly as Recruiter',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Job Title'),
            _buildTextField(
              'e.g. Head Chef, Sous Chef',
              controller: _titleController,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Company Name'),
            _buildTextField(
              'e.g. The Velvet Lounge',
              controller: _companyController,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Job Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                jobTypes.length,
                (index) => _buildTypeChip(jobTypes[index], index),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Salary Range'),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    'Min',
                    prefix: '฿ ',
                    controller: _minSalaryController,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    'Max',
                    prefix: '฿ ',
                    controller: _maxSalaryController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _buildDropdown('/ month')),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Location'),
            _buildTextField(
              'Restaurant address or city',
              icon: Icons.location_on_outlined,
              controller: _locationController,
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Description'),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Share the details of the opening here...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Qualifications & Requirements'),
            ...requirements.asMap().entries.map(
                  (entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController.fromValue(
                              TextEditingValue(
                                text: entry.value,
                                selection: TextSelection.collapsed(offset: entry.value.length),
                              ),
                            ),
                            onChanged: (newValue) {
                              // อัปเดตค่าใน List เมื่อมีการพิมพ์
                              requirements[index] = newValue;
                            },
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter requirement...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => requirements.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),

            TextButton.icon(
              onPressed: () =>
                  setState(() => requirements.add('')), // เพิ่มเป็นค่าว่างเพื่อให้ User พิมพ์เอง
              icon: Icon(
                Icons.add_circle_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              label: Text(
                'Add Requirement',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _handlePostJob, // เชื่อมต่อฟังก์ชันส่งข้อมูล
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Post Job Listing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2B4C),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, {
        String? prefix,
        IconData? icon,
        TextEditingController? controller,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center, // จัดตัวหนังสือให้อยู่กลางแนวตั้ง
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixText: prefix,
          // ปรับตรงนี้ครับ
          prefixIcon: icon != null
              ? Padding(
            padding: const EdgeInsets.only(right: 12.0), // เพิ่มช่องไฟขวาของ Icon
            child: Icon(icon, color: Colors.grey.shade500, size: 20),
          )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14), // เพิ่มพื้นที่บน-ล่าง
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, int index) {
    bool isSelected = jobTypeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => jobTypeIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [value]
              .map((val) => DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}
