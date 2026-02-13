import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // เก็บหน้าปัจจุบันของ Navbar
  bool isJobMode = true;  // เก็บโหมด Job/Recipe

  // ฟังก์ชันสร้างเนื้อหาภายในหน้า Home (ที่สลับ Job/Recipe ได้)
  Widget _buildHomeContent() {
    return Column(
      children: [
        // ส่วน Toggle ด้านบน
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildToggleButton('Job Search', isJobMode, Colors.deepPurple, () {
                setState(() => isJobMode = true);
              }),
              const SizedBox(width: 10),
              _buildToggleButton('Recipes', !isJobMode, Colors.green, () {
                setState(() => isJobMode = false);
              }),
            ],
          ),
        ),
        // รายการ Card
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isJobMode ? Colors.deepPurple.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  child: Icon(
                    isJobMode ? Icons.work : Icons.restaurant,
                    color: isJobMode ? Colors.deepPurple : Colors.green,
                  ),
                ),
                title: Text(isJobMode ? 'Job Title $index' : 'Recipe Name $index'),
                subtitle: const Text('Tap to view details'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper สร้างปุ่ม Toggle
  Widget _buildToggleButton(String text, bool isActive, Color activeColor, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? activeColor : Colors.grey[200],
          foregroundColor: isActive ? Colors.white : Colors.black54,
          elevation: isActive ? 4 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // รายการหน้าต่างๆ ตามเมนู Navbar
    final List<Widget> pages = [
      _buildHomeContent(), // หน้าแรกคือตัวที่มี Card และ Toggle
      const Center(child: Text('Explore Page')),
      const Center(child: Text('Post Page')),
      const Center(child: Text('Saved Page')),
      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MannotRobot', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      
      body: pages[_selectedIndex], // แสดงหน้าตามที่กด Navbar

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note, size: 35),
            label: 'Post',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}