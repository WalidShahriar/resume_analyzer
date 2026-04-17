import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // যোগ করা হয়েছে
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  bool _isUpdating = false;

  // --- Firebase Password Change Logic ---
  Future<void> _changePassword() async {
    String currentPassword = _currentPassController.text.trim();
    String newPassword = _newPassController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showSnackBar("Please fill in both fields", Colors.orange);
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar("New password must be at least 6 characters", Colors.orange);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? email = user?.email;

      if (email != null) {
        // ১. আগে চেক করা হচ্ছে বর্তমান পাসওয়ার্ড সঠিক কি না (Re-authentication)
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );

        await user?.reauthenticateWithCredential(credential);

        // ২. পাসওয়ার্ড আপডেট করা হচ্ছে
        await user?.updatePassword(newPassword);

        _currentPassController.clear();
        _newPassController.clear();
        if (mounted) Navigator.pop(context); // Dialog বন্ধ করা

        _showSnackBar("Password updated successfully!", Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Update failed";
      if (e.code == 'wrong-password') errorMsg = "Current password is incorrect!";
      _showSnackBar(errorMsg, Colors.redAccent);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(
            context,
            Icons.person_outline,
            "Edit Profile",
            "Update your name, email, and more",
            () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
              setState(() {}); 
            },
          ),
          _buildSettingsTile(
            context,
            Icons.lock_outline,
            "Change Password",
            "Update your login security",
            () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: !_isUpdating,
      builder: (context) => StatefulBuilder( // Dialog-এর ভেতর UI আপডেট করার জন্য
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPassController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: "Current Password", 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  )
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _newPassController,
                  obscureText: true, 
                  decoration: InputDecoration(
                    labelText: "New Password", 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  )
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isUpdating ? null : () {
                  _currentPassController.clear();
                  _newPassController.clear();
                  Navigator.pop(context);
                }, 
                child: const Text("Cancel")
              ),
              ElevatedButton(
                onPressed: _isUpdating ? null : () async {
                  setDialogState(() {}); // Dialog লোডিং দেখানোর জন্য
                  await _changePassword();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, 
                  foregroundColor: Colors.white
                ),
                child: _isUpdating 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Update"),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }
}