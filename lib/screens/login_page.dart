import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data'; // প্রোফাইল পিকচারের জন্য
import 'home_page.dart';

// গ্লোবাল ভেরিয়েবল যাতে প্রোফাইল পিকচার সিঙ্ক থাকে
Uint8List? globalProfileImageBytes;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isLoading = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  // --- Firebase Logic ---
  Future<void> _handleAuth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      _showSnackBar("Please fill in all fields", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // ১. লগইন লজিক
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // ২. রেজিস্ট্রেশন লজিক
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // ৩. Firestore-এ ডাটা সেভ
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': userCredential.user!.uid,
          'phone': '',
          'address': '',
          'createdAt': DateTime.now(),
        });

        _showSnackBar("Registration Successful! Please login.", Colors.green);
        _toggleAuthMode();
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "An error occurred";
      if (e.code == 'user-not-found') errorMsg = "No user found for that email.";
      else if (e.code == 'wrong-password') errorMsg = "Wrong password provided.";
      else if (e.code == 'email-already-in-use') errorMsg = "This email is already registered.";
      else if (e.code == 'invalid-email') errorMsg = "The email address is badly formatted.";
      
      _showSnackBar(errorMsg, Colors.redAccent);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
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
      body: Row(
        children: [
          // লার্জ স্ক্রিনের জন্য সাইড প্যানেল (Responsive UI)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              child: Container(
                color: Colors.blueAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      "CareerPath",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Analyze your resume with the power of AI",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          
          // লগইন/সাইনআপ ফর্ম
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isLogin ? "Welcome Back" : "Create Account",
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      if (!isLogin) ...[
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleAuth, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isLogin ? "Login" : "Sign Up",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(
                          isLogin 
                              ? "New here? Create an account" 
                              : "Already have an account? Login",
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}