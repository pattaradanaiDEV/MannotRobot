import 'package:flutter/material.dart';

class PostModal extends StatelessWidget {
  const PostModal({super.key});
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => _createPostModal(context));
    return Scaffold(body: Center(child: Text('Please select type. . . ')));
  }
}

//สร้าง modal ขึ้น มาเพื่อเป็นทางเลือกให้ผู้ใช้สามารถเลือกโพสต์ได้
void _createPostModal(BuildContext context) {
  showDialog(
    context: context,
    //barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPostOption(
                context,
                icon: Icons.restaurant,
                label: 'Share a recipe',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 20),
              _buildPostOption(
                context,
                icon: Icons.work_outline,
                label: 'Hire/find a work',
                color: Colors.grey,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildPostOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  //สร้างปุ่มที่มีขนาดเท่ากันเป๊ะๆ
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.black),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
