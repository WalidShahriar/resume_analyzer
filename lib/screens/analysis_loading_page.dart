import 'package:flutter/material.dart';
import 'dart:async';
import 'result_page.dart';
// এখানে আপনার রেজাল্ট পেজটি ইমপোর্ট করতে হবে (পরে আমরা এটি বানাবো)
// import 'result_page.dart';

class AnalysisLoadingPage extends StatefulWidget {
  final String fileName;
  const AnalysisLoadingPage({super.key, required this.fileName});

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage> {
  double _progress = 0.0;
  String _loadingText = "Reading PDF Content...";

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // একটি টাইমার সেট করা যা ৩-৪ সেকেন্ড পর পর টেক্সট এবং প্রগ্রেস বার চেঞ্জ করবে
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.2;
          if (_progress >= 1.0) {
            timer.cancel();
            // এই লাইনটি এখন একটিভ করুন
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ResultPage()),
            );
          }

          // প্রগ্রেস অনুযায়ী মেসেজ আপডেট
          if (_progress < 0.4) {
            _loadingText = "Extracting Metadata...";
          } else if (_progress < 0.7) {
            _loadingText = "Comparing with ATS Standards...";
          } else {
            _loadingText = "Generating AI Insights...";
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // একটি সুন্দর এনিমেটেড আইকন বা সার্কুলার প্রগ্রেস
              const SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _loadingText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "File: ${widget.fileName}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // লিনিয়ার প্রগ্রেস বার
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: Colors.blue[50],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

