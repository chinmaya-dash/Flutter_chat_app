import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePopup extends StatefulWidget {
  final String initialUsername;
  final String initialEmail;

  const EditProfilePopup({
    super.key,
    required this.initialUsername,
    required this.initialEmail,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePopupState createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  String username = "";
  String email = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    username = widget.initialUsername;
    email = widget.initialEmail;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      String? token = await _storage.read(key: 'token');
      if (token == null) {
        // ignore: avoid_print
        print("No token found, user not logged in.");
        return;
      }

      try {
        final response = await http.put(
          Uri.parse('http://192.168.33.126:4000/profile/update'), // ✅ Correct API route
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'username': username, 'email': email}),
        );

        if (response.statusCode == 200) {
          await _storage.write(key: 'username', value: username);
          await _storage.write(key: 'email', value: email);

          // ✅ Success animation
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xFF31372d), // Dark theme background
                title: Text("Profile Updated", style: TextStyle(color: Colors.white)),
                content: Text("Your profile has been successfully updated.", style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, {'username': username, 'email': email});
                    },
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        } else {
          // ignore: avoid_print
          print("Failed to update profile: ${response.body}");
        }
      } catch (e) {
        print("Error updating profile: $e");
      }

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Close when tapping outside
      child: Dialog(
        backgroundColor: Color(0xFF31372d), // Dark theme background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              // Close Button (X) at Top-Left
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: username,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black54,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Username is required" : null,
                          onChanged: (value) => setState(() => username = value),
                        ),
                        SizedBox(height: 15),

                        TextFormField(
                          initialValue: email,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.black54,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Email is required" : null,
                          onChanged: (value) => setState(() => email = value),
                        ),
                        SizedBox(height: 20),

                        // Save Button
                        ElevatedButton(
                          onPressed: isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF708759), // ✅ Button color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Save Changes",
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
