import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // globalProfileImageBytes এর জন্য জরুরি

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- প্রোফাইল পিকচার সেকশন ---
                Center(
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.blue[50],
                    // গ্লোবাল ভেরিয়েবল থেকে ইমেজ নেওয়া হচ্ছে
                    backgroundImage: globalProfileImageBytes != null
                        ? MemoryImage(globalProfileImageBytes!)
                        : null,
                    child: globalProfileImageBytes == null
                        ? const Icon(Icons.person, size: 65, color: Colors.blueAccent)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userData['name'] ?? "User Name",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),

                // --- ইনফরমেশন কার্ডস ---
                _buildInfoTile(Icons.phone_android_outlined, "Phone", userData['phone'] ?? "Not set"),
                _buildInfoTile(Icons.location_on_outlined, "Address", userData['address'] ?? "Not set"),
                _buildInfoTile(Icons.calendar_today_outlined, "Joined", "April 2026"), // ডামি ডাটা বা ক্রিয়েশন টাইম দিতে পারো
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}