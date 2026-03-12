import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/job_detail_screen.dart';
import '../home/recipe_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final bool isRecipeMode;
  final ValueChanged<bool> onModeChanged;

  const ExploreScreen({
    super.key,
    required this.isRecipeMode,
    required this.onModeChanged,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = "";

  // =====================================
  // ตัวแปรสำหรับเก็บค่า Filter ปัจจุบัน
  // =====================================
  List<String> activeFilterIngredients = [];
  List<String> activeFilterTags = [];
  String activeSortOption = "None"; // None, Highest Rated, Most Reviews
  String activeTimeOption = ""; // < 15m, 15-30m, 30-60m, 1h+
  String activeDifficultyOption = ""; // Easy, Medium, Hard

  final List<String> recipeTags = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Dessert",
    "Snack",
    "Beverage",
    "Thai",
    "Japanese",
    "Italian",
    "Mexican",
    "Chinese",
    "Indian",
    "Korean",
    "Vegan",
    "Vegetarian",
    "Keto",
    "Gluten-Free",
    "Low-Carb",
    "High-Protein",
    "Healthy",
    "Fast Food",
    "Street Food",
    "Seafood",
    "Chicken",
    "Beef",
    "Pork",
    "Spicy",
    "Sweet",
    "Savory",
    "Baking",
    "Grilling",
    "Fried",
    "Soup",
    "Salad",
  ];

  final List<String> jobTags = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.isRecipeMode
        ? const Color(0xFFF97316)
        : Colors.blue.shade600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryColor),
            _buildSearchBar(primaryColor),
            const SizedBox(height: 10),
            Expanded(child: _buildResultsList(primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isRecipeMode ? 'Explore Recipes' : 'Explore Jobs',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2B4C),
            ),
          ),
          ActionChip(
            label: Text(widget.isRecipeMode ? 'Jobs' : 'Recipes'),
            onPressed: () {
              widget.onModeChanged(!widget.isRecipeMode);
              _resetFilters(); // รีเซ็ตตัวกรองเมื่อสลับโหมด
            },
            backgroundColor: primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            avatar: Icon(
              widget.isRecipeMode ? Icons.work_outline : Icons.restaurant_menu,
              size: 16,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: widget.isRecipeMode
                    ? 'Search recipes, chefs...'
                    : 'Search jobs...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ปุ่ม Filter ด้านขวา
          GestureDetector(
            onTap: () => _showFilterModal(primaryColor),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune, color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      activeFilterIngredients.clear();
      activeFilterTags.clear();
      activeSortOption = "None";
      activeTimeOption = "";
      activeDifficultyOption = "";
      searchQuery = "";
    });
  }

  // =====================================
  // Modal Filter
  // =====================================
  void _showFilterModal(Color primaryColor) {
    List<String> tempIngredients = List.from(activeFilterIngredients);
    List<String> tempTags = List.from(activeFilterTags);
    String tempSort = activeSortOption;
    String tempTime = activeTimeOption;
    String tempDiff = activeDifficultyOption;

    TextEditingController ingredientController = TextEditingController();

    showModalBottomSheet(
      context: context, // Outer context
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // 🔴 เปลี่ยนชื่อเพื่อไม่ให้ Context ซ้อนทับกัน
        return StatefulBuilder(
          builder: (stateContext, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (scrollContext, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempIngredients.clear();
                                tempTags.clear();
                                tempSort = "None";
                                tempTime = "";
                                tempDiff = "";
                              });
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            if (widget.isRecipeMode) ...[
                              // 1. Ingredients (เฉพาะ Recipe)
                              _buildModalSectionTitle('Ingredients'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...tempIngredients.map(
                                    (ing) => Chip(
                                      label: Text(
                                        ing,
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      deleteIcon: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      onDeleted: () => setModalState(
                                        () => tempIngredients.remove(ing),
                                      ),
                                      backgroundColor: primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  ActionChip(
                                    label: const Text(
                                      'Add +',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        useRootNavigator: true,
                                        builder: (dialogContext) => MediaQuery(
                                          // 🔴 บังคับ viewInsets เป็น 0 เพื่อหลอก Dialog ว่าไม่มีคีย์บอร์ด มันจะได้ไม่ขยับ
                                          data: MediaQuery.of(dialogContext)
                                              .copyWith(
                                                viewInsets: EdgeInsets.zero,
                                              ),
                                          child: AlertDialog(
                                            title: const Text("Add Ingredient"),
                                            content: TextField(
                                              controller: ingredientController,
                                              decoration: const InputDecoration(
                                                hintText: "e.g. Tomato",
                                              ),
                                              autofocus: true,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  if (ingredientController.text
                                                      .trim()
                                                      .isNotEmpty) {
                                                    setModalState(
                                                      () => tempIngredients.add(
                                                        ingredientController
                                                            .text
                                                            .trim(),
                                                      ),
                                                    );
                                                  }
                                                  ingredientController.clear();
                                                  Navigator.pop(dialogContext);
                                                },
                                                child: const Text("Add"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.grey.shade200,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],

                            // 2. Tags (แสดงทั้ง Recipe และ Job)
                            _buildModalSectionTitle('Tags'),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  (widget.isRecipeMode ? recipeTags : jobTags)
                                      .map((tag) {
                                        bool isSelected = tempTags.contains(
                                          tag,
                                        );
                                        return FilterChip(
                                          label: Text(
                                            tag,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          selected: isSelected,
                                          selectedColor: primaryColor,
                                          backgroundColor: Colors.grey.shade100,
                                          checkmarkColor: Colors.white,
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          onSelected: (bool selected) {
                                            setModalState(() {
                                              if (selected)
                                                tempTags.add(tag);
                                              else
                                                tempTags.remove(tag);
                                            });
                                          },
                                        );
                                      })
                                      .toList(),
                            ),
                            const SizedBox(height: 24),

                            // 🔴 ย้าย Sort By, Time Required, Difficulty Level ให้โชว์เฉพาะ Recipe Mode
                            if (widget.isRecipeMode) ...[
                              // 3. Sort By
                              _buildModalSectionTitle('Sort By'),
                              Wrap(
                                spacing: 8,
                                children:
                                    [
                                      'Highest Rated',
                                      'Most Reviews',
                                      'None',
                                    ].map((sort) {
                                      bool isSelected = tempSort == sort;
                                      return ChoiceChip(
                                        label: Text(sort),
                                        selected: isSelected,
                                        onSelected: (val) => setModalState(
                                          () => tempSort = sort,
                                        ),
                                        selectedColor: primaryColor,
                                        backgroundColor: Colors.grey.shade50,
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        side: BorderSide.none,
                                        showCheckmark: false,
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 24),

                              // 4. Time Required
                              _buildModalSectionTitle('Time Required'),
                              Row(
                                children: ['< 15m', '15-30m']
                                    .map(
                                      (time) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                            bottom: 8,
                                          ),
                                          child: _buildChoiceButton(
                                            time,
                                            tempTime == time,
                                            primaryColor,
                                            () => setModalState(
                                              () => tempTime = tempTime == time
                                                  ? ""
                                                  : time,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              Row(
                                children: ['30-60m', '1h+']
                                    .map(
                                      (time) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: _buildChoiceButton(
                                            time,
                                            tempTime == time,
                                            primaryColor,
                                            () => setModalState(
                                              () => tempTime = tempTime == time
                                                  ? ""
                                                  : time,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 24),

                              // 5. Difficulty Level
                              _buildModalSectionTitle('Difficulty Level'),
                              Row(
                                children: ['Easy', 'Medium', 'Hard']
                                    .map(
                                      (diff) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: _buildChoiceButton(
                                            diff,
                                            tempDiff == diff,
                                            primaryColor,
                                            () => setModalState(
                                              () => tempDiff = tempDiff == diff
                                                  ? ""
                                                  : diff,
                                            ),
                                            isVertical: true,
                                            icon: diff == 'Easy'
                                                ? Icons.speed
                                                : diff == 'Medium'
                                                ? Icons.bolt
                                                : Icons.workspace_premium,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ],
                        ),
                      ),
                      // ปุ่ม Apply
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              activeFilterIngredients = tempIngredients;
                              activeFilterTags = tempTags;
                              activeSortOption = tempSort;
                              activeTimeOption = tempTime;
                              activeDifficultyOption = tempDiff;
                            });
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildModalSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF1A2B4C),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(
    String label,
    bool isSelected,
    Color primaryColor,
    VoidCallback onTap, {
    bool isVertical = false,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isVertical
            ? Column(
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      color: isSelected ? primaryColor : Colors.grey,
                      size: 20,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? primaryColor : Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }

  // =====================================
  // แสดงผลลัพธ์ (กรองและเรียงลำดับ)
  // =====================================
  Widget _buildResultsList(Color primaryColor) {
    String collection = widget.isRecipeMode ? 'recipes' : 'jobs';
    Query query = FirebaseFirestore.instance.collection(collection);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(child: Text('ไม่พบข้อมูลในระบบ'));

        // 1. นำข้อมูลมากรองฝั่ง Client
        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // --- กรอง 1: ชื่ออาหาร (Search Query) ---
          String title = (data['title'] ?? "").toString().toLowerCase();
          if (searchQuery.isNotEmpty && !title.contains(searchQuery))
            return false;

          if (widget.isRecipeMode) {
            // --- กรอง 2: Ingredients ---
            if (activeFilterIngredients.isNotEmpty) {
              List<dynamic> recipeIngs = data['ingredients'] ?? [];
              bool hasIngredientMatch = false;
              for (var fIng in activeFilterIngredients) {
                for (var rIng in recipeIngs) {
                  if (rIng['name'].toString().toLowerCase().contains(
                    fIng.toLowerCase(),
                  )) {
                    hasIngredientMatch = true;
                    break;
                  }
                }
                if (hasIngredientMatch) break;
              }
              if (!hasIngredientMatch) return false;
            }

            // --- กรอง 3: Tags ---
            if (activeFilterTags.isNotEmpty) {
              List<dynamic> rTags = data['tags'] ?? [];
              bool hasTagMatch = false;
              for (var t in activeFilterTags) {
                if (rTags.contains(t)) {
                  hasTagMatch = true;
                  break;
                }
              }
              if (!hasTagMatch) return false;
            }

            // --- กรอง 4: Time Required ---
            if (activeTimeOption.isNotEmpty) {
              int time = data['timeMins'] ?? 0;
              if (activeTimeOption == '< 15m' && time >= 15) return false;
              if (activeTimeOption == '15-30m' && (time < 15 || time > 30))
                return false;
              if (activeTimeOption == '30-60m' && (time <= 30 || time > 60))
                return false;
              if (activeTimeOption == '1h+' && time <= 60) return false;
            }

            // --- กรอง 5: Difficulty Level ---
            if (activeDifficultyOption.isNotEmpty) {
              if (data['difficulty'] != activeDifficultyOption) return false;
            }
          } else {
            // โหมด Job (กรองแค่ Search กับ Tags)
            if (activeFilterTags.isNotEmpty &&
                !activeFilterTags.contains(data['jobType']))
              return false;
          }

          return true;
        }).toList();

        // 2. จัดเรียงข้อมูล (Sorting) สำหรับโหมด Recipe
        if (widget.isRecipeMode && activeSortOption != "None") {
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            if (activeSortOption == 'Highest Rated') {
              double ratingA = (dataA['rating'] ?? 0.0).toDouble();
              double ratingB = (dataB['rating'] ?? 0.0).toDouble();
              return ratingB.compareTo(ratingA); // มากไปน้อย
            } else if (activeSortOption == 'Most Reviews') {
              // 🔴 แก้ไขแล้ว: ดึงข้อมูลจากฟิลด์ reviewCount แทน likes
              int reviewsA = dataA['reviewCount'] ?? 0;
              int reviewsB = dataB['reviewCount'] ?? 0;
              return reviewsB.compareTo(reviewsA); // มากไปน้อย
            }
            return 0;
          });
        }

        if (docs.isEmpty)
          return const Center(child: Text('ไม่พบผลลัพธ์ที่ตรงกับตัวกรอง'));

        // 3. แสดงผล List
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String docId = docs[index].id;

            return GestureDetector(
              onTap: () {
                if (widget.isRecipeMode) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeDetailScreen(recipeData: data, recipeId: docId),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          JobDetailScreen(jobData: data, jobId: docId),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data['imageUrl'] ?? 'https://via.placeholder.com/150',
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 75,
                          height: 75,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1A2B4C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isRecipeMode
                                ? "Chef ${data['authorName'] ?? ''}"
                                : (data['companyName'] ?? ''),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 🔴 จัดกลุ่ม Badge และคะแนนดาวให้อยู่ใน Row เดียวกัน
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.isRecipeMode
                                      ? (data['difficulty'] ?? 'Easy')
                                      : (data['jobType'] ?? 'Full-time'),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // 🔴 เพิ่มส่วนแสดงคะแนนดาวเมื่อเป็นหน้าสูตรอาหาร
                              if (widget.isRecipeMode) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.star,
                                  color: Colors.orange.shade400,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${data['rating'] ?? 0.0} (${data['reviewCount'] ?? 0} Reviews)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
