import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // globalProfileImageBytes এর জন্য

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  bool _isLoading = false;
  final User? user = FirebaseAuth.instance.currentUser;
  Uint8List? _tempImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    
    // পেজ ওপেন হওয়ার সময় গ্লোবাল ইমেজটি টেম্পোরারি ভেরিয়েবলে নেওয়া
    _tempImageBytes = globalProfileImageBytes;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc['name'] ?? "";
          _emailController.text = doc['email'] ?? "";
          _phoneController.text = doc['phone'] ?? "";
          _addressController.text = doc['address'] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _tempImageBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showMsg("Name cannot be empty", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // গ্লোবাল ইমেজ আপডেট
      globalProfileImageBytes = _tempImageBytes;

      if (mounted) {
        _showMsg("Profile Updated Successfully!", Colors.green);
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) _showMsg("Error: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[50],
                        backgroundImage: _tempImageBytes != null ? MemoryImage(_tempImageBytes!) : null,
                        child: _tempImageBytes == null ? const Icon(Icons.person, size: 60, color: Colors.blueAccent) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildTextField("Full Name", _nameController, Icons.person_outline),
                _buildTextField("Email Address", _emailController, Icons.email_outlined, enabled: false),
                _buildTextField("Phone Number", _phoneController, Icons.phone_android_outlined),
                // ফিক্সড লাইন: তিনটি প্যারামিটারই দেওয়া হয়েছে
                _buildTextField("Address", _addressController, Icons.location_on_outlined),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: enabled ? Colors.blueAccent : Colors.grey),
          filled: !enabled,
          fillColor: enabled ? Colors.transparent : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}