import 'package:flutter/material.dart';

class SavedScreen extends StatefulWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const SavedScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // ข้อมูลจะถูกดึงมาจาก Firebase ในอนาคต
  final List<Map<String, dynamic>> savedRecipes = [];
  final List<Map<String, dynamic>> savedJobs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: Color(0xFF1A2B4C),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF1A2B4C)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // แท็บสลับ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onModeChanged(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Recipes',
                          style: TextStyle(
                            color: widget.isRecipeMode
                                ? Colors.black87
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onModeChanged(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !widget.isRecipeMode
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Jobs',
                          style: TextStyle(
                            color: !widget.isRecipeMode
                                ? Colors.green.shade700
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // เนื้อหา
          Expanded(
            child: widget.isRecipeMode
                ? _buildSavedRecipesGrid()
                : _buildSavedJobsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRecipesGrid() {
    if (savedRecipes.isEmpty) {
      return const Center(
        child: Text(
          "ยังไม่มีสูตรอาหารที่บันทึกไว้",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      itemCount: savedRecipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) => const SizedBox(),
    );
  }

  Widget _buildSavedJobsList() {
    if (savedJobs.isEmpty) {
      return const Center(
        child: Text(
          "ยังไม่มีงานที่บันทึกไว้",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      itemCount: savedJobs.length,
      itemBuilder: (context, index) => const SizedBox(),
    );
  }
}
