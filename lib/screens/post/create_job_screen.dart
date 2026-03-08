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
    'Minimum 3 years in a high-volume kitchen',
    'Food Safety Certification (ServSafe)',
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
          "\$${_minSalaryController.text} - \$${_maxSalaryController.text}",
      location: _locationController.text,
      description: _descriptionController.text,
      requirements: requirements,
      logoUrl: "", // สามารถเพิ่ม logic อัปโหลดรูปโลโก้ได้ในอนาคต
      imageUrl:
          "https://images.unsplash.com/photo-1556910103-1c02745aae4d", // Mockup URL
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
        actions: [
          TextButton(
            onPressed: () {}, // สำหรับดูตัวอย่าง
            child: Text(
              'Preview',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=5',
                      ),
                      radius: 24,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sarah Jenkins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
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
                    prefix: '\$ ',
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
                    prefix: '\$ ',
                    controller: _maxSalaryController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _buildDropdown('/ year')),
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
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13,
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
                            setState(() => requirements.removeAt(entry.key)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => requirements.add('New Requirement')),
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
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixText: prefix,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.grey.shade500, size: 20)
              : null,
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
