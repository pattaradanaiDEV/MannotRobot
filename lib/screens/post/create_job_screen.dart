import 'dart:io'; // 🔴 เพิ่มตัวนี้
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // 🔴 เพิ่มตัวนี้
import '../../services/firestore_service.dart';
import '../../models/job.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  // Services & Controllers
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int jobTypeIndex = 0;
  final List<String> jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship'];
  List<String> requirements = [];

  // 🔴 1. ตัวแปรสำหรับรูปภาพ
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

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

  // 🔴 2. ฟังก์ชันเลือกรูปภาพ
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันสำหรับส่งข้อมูลงานขึ้น Firebase
  Future<void> _handlePostJob() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")));
      return;
    }
    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณากรอกข้อมูลสำคัญให้ครบ")));
      return;
    }

    // โชว์ Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 🔴 3. Logic การจัดการรูปภาพก่อนเซฟ
    String finalImageUrl = "https://images.unsplash.com/photo-1556910103-1c02745aae4d"; // รูป Default

    try {
      if (_imageFile != null) {
        // เรียกใช้ฟังก์ชัน uploadImage จาก FirestoreService ของคุณ
        String? uploadedUrl = await _firestoreService.uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      Job newJob = Job(
        userId: user.uid,
        recruiterName: user.displayName ?? "Anonymous Recruiter",
        companyName: _companyController.text,
        title: _titleController.text,
        jobType: jobTypes[jobTypeIndex],
        salaryRange: "฿${_minSalaryController.text} - ฿${_maxSalaryController.text}",
        location: _locationController.text,
        description: _descriptionController.text,
        requirements: requirements,
        logoUrl: user.photoURL ?? "",
        imageUrl: finalImageUrl, // 🔴 ใช้ URL ที่อัปโหลดใหม่
        likes: [],
      );

      await _firestoreService.addJob(newJob);
      if (mounted) {
        Navigator.pop(context); // ปิด Loading
        Navigator.pop(context); // ปิดหน้า Post
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("โพสต์ประกาศสำเร็จ!")));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Post a New Job', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty ? Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Posting publicly as Recruiter', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Job Title'),
            _buildTextField('e.g. Head Chef', controller: _titleController),
            const SizedBox(height: 20),

            _buildSectionTitle('Company Name'),
            _buildTextField('e.g. The Velvet Lounge', controller: _companyController),
            const SizedBox(height: 20),

            _buildSectionTitle('Job Type'),
            Wrap(
              spacing: 8,
              children: List.generate(jobTypes.length, (index) => _buildTypeChip(jobTypes[index], index)),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Salary Range'),
            Row(
              children: [
                Expanded(child: _buildTextField('Min', prefix: '฿ ', controller: _minSalaryController)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to')),
                Expanded(child: _buildTextField('Max', prefix: '฿ ', controller: _maxSalaryController)),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('/ month')),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Location'),
            _buildTextField('Address or city', icon: Icons.location_on_outlined, controller: _locationController),
            const SizedBox(height: 20),

            _buildSectionTitle('Description'),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Share details...', border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Qualifications & Requirements'),
            ...requirements.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => requirements[index] = v,
                          decoration: const InputDecoration(hintText: 'Requirement...', border: InputBorder.none),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => setState(() => requirements.removeAt(index))),
                    ],
                  ),
                ),
              );
            }).toList(),

            TextButton.icon(
              onPressed: () => setState(() => requirements.add('')),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Requirement'),
            ),

            const SizedBox(height: 24),

            // 🔴 4. ส่วนแอดรูปภาพ (เพิ่มต่อจาก Requirement)
            _buildSectionTitle('Job Banner Photo'),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 40),
                    const SizedBox(height: 8),
                    const Text('Tap to upload job photo', style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : Stack(
                  children: [
                    Positioned(
                      top: 8, right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54, radius: 18,
                        child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: () => setState(() => _imageFile = null)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _handlePostJob,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Post Job Listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Widgets อื่นๆ เหมือนเดิม...
  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))));
  }

  Widget _buildTextField(String hint, {String? prefix, IconData? icon, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, prefixText: prefix, prefixIcon: icon != null ? Icon(icon, size: 20) : null),
      ),
    );
  }

  Widget _buildTypeChip(String label, int index) {
    bool isSelected = jobTypeIndex == index;
    return ChoiceChip(
      label: Text(label), selected: isSelected,
      onSelected: (v) => setState(() => jobTypeIndex = index),
      selectedColor: Colors.blue.shade100,
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, items: [value].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (_) {})),
    );
  }
}