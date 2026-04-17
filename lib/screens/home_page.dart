import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; 
import 'my_profile_page.dart';
import 'analysis_loading_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

 
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFileBytes = result.files.first.bytes;
          _selectedFileName = result.files.first.name;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selected: $_selectedFileName"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _showFeatureInfo(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.blueAccent),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Got it!",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String userName = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          userName = snapshot.data!['name'] ?? "User";
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          drawer: Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Colors.blueAccent),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    // গ্লোবাল ভেরিয়েবল থেকে ছবি নেওয়া হচ্ছে
                    backgroundImage: globalProfileImageBytes != null
                        ? MemoryImage(globalProfileImageBytes!)
                        : null,
                    child: globalProfileImageBytes == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blueAccent,
                          )
                        : null,
                  ),
                  accountName: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(""),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dashboard_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Dashboard"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("My Profile"),
                  onTap: () async {
                    Navigator.pop(context); 
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyProfilePage(),
                      ),
                    );
                    setState(
                      () {},
                    ); 
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Settings"),
                  onTap: () async {
                    Navigator.pop(context); // ক্লোজ ড্রয়ার
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                    setState(() {}); 
                  },
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text(
              "CareerPath",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blueAccent,
            elevation: 0.5,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back, ${userName.split(' ')[0]}! 👋",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Ready to optimize your professional career?",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- Upload Zone ---
                Center(
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _selectedFileName != null
                            ? Colors.green
                            : Colors.blueAccent.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _selectedFileName != null
                                ? Colors.green[50]
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedFileName != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file_rounded,
                            size: 60,
                            color: _selectedFileName != null
                                ? Colors.green
                                : Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _selectedFileName ?? "Upload Your Resume",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _pickPDF,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedFileName != null
                                ? Colors.green
                                : Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _selectedFileName != null
                                ? "Change PDF File"
                                : "Choose PDF File",
                          ),
                        ),
                        if (_selectedFileName != null) ...[
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnalysisLoadingPage(
                                    fileName: _selectedFileName!,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.auto_fix_high),
                            label: const Text(
                              "Start Analysis",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Core Features",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildFeatureCard(
                      Icons.document_scanner_outlined,
                      "AI Parsing",
                      "Extracts metadata",
                      () => _showFeatureInfo(
                        "AI Parsing",
                        "Extracts info from PDF.",
                      ),
                    ),
                    _buildFeatureCard(
                      Icons.fact_check_outlined,
                      "ATS Score",
                      "Rank against JD",
                      () => _showFeatureInfo(
                        "ATS Score",
                        "Calculate match percentage.",
                      ),
                    ),
                    _buildFeatureCard(
                      Icons.lightbulb_outline,
                      "Insights",
                      "Get suggestions",
                      () => _showFeatureInfo(
                        "AI Insights",
                        "Get improvement tips.",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String desc,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

