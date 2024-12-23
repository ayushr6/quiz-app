import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SideNav extends StatelessWidget {
  const SideNav({super.key});

  Future<void> _updateQuizzes(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/quiz/update'), // Adjust URL as needed
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quizzes updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update quizzes.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: const Color.fromRGBO(128, 0, 128, 1),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Ayush Ranwa",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Rs. 50,000",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),
            listItem(label: "Daily Quiz", icon: Icons.quiz, onTap: () {}),
            listItem(label: "Leaderboard", icon: Icons.leaderboard, onTap: () {}),
            listItem(label: "How To Use", icon: Icons.question_answer, onTap: () {}),
            listItem(label: "About Us", icon: Icons.face, onTap: () {}),
            const SizedBox(height: 20),
            // Add Update button
            listItem(
              label: "Update",
              icon: Icons.update,
              onTap: () => _updateQuizzes(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget listItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final color = Colors.white;
    final hovercolor = Colors.white60;

    return ListTile(
      leading: Icon(icon, color: color),
      hoverColor: hovercolor,
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
