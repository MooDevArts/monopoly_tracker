import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelfieScreen extends StatefulWidget {
  const SelfieScreen({super.key});

  @override
  State<SelfieScreen> createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Show a snackbar message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Signed In'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    });
  }

  Future<void> _takeSelfie() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        setState(() {
          errorMessage = 'No Image Selected';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a Selfie!')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _takeSelfie();
          },
          child: Text('Take Selfie'),
        ),
      ),
    );
  }
}
