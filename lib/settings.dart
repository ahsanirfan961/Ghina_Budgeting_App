import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/auth_gate.dart';
import 'package:frontend/main_page.dart';
import 'package:frontend/monthly.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  //final String name; // Receive the name from q1 page

  //Settings({required this.name});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  int _selectedIndex =
      2; // 2 for the settings page, meaning I'm currently on this page

  void _navigateToPage(int index, Widget page) {
    setState(() {
      _selectedIndex = index; // Update selected icon
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      body: Column(
        children: [
          const SizedBox(height: 60),
          Align(
            alignment: Alignment.center,
            child: Text(
              "الإعدادات",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "أهلا جمانه", // Modify later with name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Divider(color: Colors.white54),
          const SizedBox(height: 30),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                children: [
                  _buildSettingsOption("الحساب", Icons.person_outline),
                  _buildSettingsOption(
                    "الإشعارات",
                    Icons.notifications_outlined,
                  ),
                  _buildSettingsOption("الخصوصية", Icons.lock_outline),
                  _buildSettingsOption("حذف الحساب", Icons.delete_outline),
                  _buildSettingsOption(
                    "تسجيل خروج",
                    Icons.logout_outlined,
                    onTap: () async {
                      print('Logging out...');
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthGate()),
                      );
                    },
                  ),
                  Divider(color: Colors.white54),
                  _buildSettingsOption("تبليغ عن مشكلة", Icons.flag_outlined),
                  _buildSettingsOption("المساعدة و الدعم", Icons.help_outline),
                ],
              ),
            ),
          ),

          // Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.show_chart,
                      color:
                          _selectedIndex == 0
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed: () => _navigateToPage(0, MonthlyExpensesPage()),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color:
                          _selectedIndex == 1
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed: () => _navigateToPage(1, Mainpage1()),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color:
                          _selectedIndex == 2
                              ? Color(0xFF9FB5DA)
                              : Colors.black,
                      size: 40,
                    ),
                    onPressed:
                        () => _navigateToPage(
                          2,
                          Settings(),
                        ), //Settings(name: widget.name)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Styling for the icons and texts
  Widget _buildSettingsOption(
    String title,
    IconData icon, {
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
              onPressed:
                  onTap ??
                  () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
            ),
            Spacer(), // Pushes the text and icon to the right
            Text(title, style: TextStyle(color: Colors.white, fontSize: 26)),
            const SizedBox(width: 20),
            Icon(icon, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
