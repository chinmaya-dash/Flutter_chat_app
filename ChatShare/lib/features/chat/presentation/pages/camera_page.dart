import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  final Function(File) onImageCaptured; // Callback function to send image

  const CameraPage({super.key, required this.onImageCaptured});

  @override
  // ignore: library_private_types_in_public_api
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _openCamera(); // Automatically open camera on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Close camera
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_capturedImage != null)
            Expanded(
              child: Image.file(_capturedImage!), // Show captured image
            )
          else
            Expanded(
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          
          // Buttons: Send, Reclick, Back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Re-click Button
              ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text("Re-click"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _openCamera, // Reopen camera
              ),

              // Send Button
              ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Text("Send"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  if (_capturedImage != null) {
                    widget.onImageCaptured(_capturedImage!); // Send image to chat
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
