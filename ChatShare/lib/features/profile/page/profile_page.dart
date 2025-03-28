import 'package:chatshare/core/theme.dart';
import 'package:chatshare/features/profile/data/edit_profile_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = FlutterSecureStorage();
  String username = "";
  String email = "";
  String profileImage = "";
  String password = "";
  bool _isPasswordVisible = false;

  final List<String> avatarImages = [
    'https://img.freepik.com/free-photo/cute-cat-studio_23-2150932375.jpg?semt=ais_hybrid',
    'https://img.freepik.com/premium-photo/cute-cate-vector-design_780593-3.jpg?semt=ais_hybrid',
    'https://img.freepik.com/free-photo/christmas-pet-background-illustration_23-2151847693.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxSmyTnqOsoHay-NiDT-Zi4iorzBYucTpvmw&s',
    'https://img.freepik.com/premium-vector/cute-cat-cartoon-sitting_194935-99.jpg',
    'https://img.freepik.com/premium-photo/hipster-cute-pop-art-cat-illustration-hand-drawn_739548-370.jpg',
    'https://img.freepik.com/premium-photo/adorable-cat-with-big-eyes-ai-generated_8829-3252.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? storedUsername = await _storage.read(key: 'username');
    String? storedEmail = await _storage.read(key: 'email');
    String? storedProfileImage = await _storage.read(key: 'profileImage');
    String? storedPassword = await _storage.read(key: 'password');

    setState(() {
      username = storedUsername ?? "Unknown";
      email = storedEmail ?? "Unknown";
      profileImage = storedProfileImage ?? avatarImages[0]; // Default image
      password = storedPassword ?? "******";
    });
    _showProfileImagePopup(); // Show popup after login
  }

  Future<void> deleteAccount(BuildContext context) async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.33.126:4000/profile/delete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await _storage.deleteAll(); // Clear stored user data
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
      } else {
        print("Failed to delete account: ${response.body}");
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF31372d),
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: DefaultColors.whiteText),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : AssetImage('lib/assets/images/profile.png')
                          as ImageProvider,
            ),
            SizedBox(height: 20),

            // Username
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text(
                username,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // Email
            ListTile(
              leading: Icon(Icons.email, color: Colors.white),
              title: Text(
                email,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // Password
            ListTile(
              leading: Icon(Icons.lock, color: Colors.white),
              title: Text(
                _isPasswordVisible ? password : '••••••••',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              trailing: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),

            SizedBox(height: 20),

            // Edit Profile Button
            IconButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder:
                      (context) => EditProfilePopup(
                        initialUsername: username,
                        initialEmail: email,
                      ),
                );

                if (result != null) {
                  setState(() {
                    username = result['username'];
                    email = result['email'];
                  });
                }
              },
              icon: Icon(Icons.edit, color: Colors.white),
            ),

            SizedBox(height: 20), // Spacing
            // Delete Account Button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Color(
                        0xFF31372d,
                      ), // ✅ Set the dialog background color
                      title: Text(
                        "Delete Account",
                        style: TextStyle(
                          color: Colors.white,
                        ), // ✅ Title in white
                      ),
                      content: Text(
                        "Are you sure you want to delete your account permanently?",
                        style: TextStyle(
                          color: Colors.white70,
                        ), // ✅ Content in light white
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context), // Cancel
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteAccount(context); // ✅ Call delete function
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: DefaultColors.buttonColor),
                          ), // ✅ Set delete button color
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    DefaultColors.buttonColor, // ✅ Set the button color
              ),
              child: Text(
                "Delete Account",
                style: TextStyle(color: Colors.white),
              ), // ✅ Text in white
            ),
          ],
        ),
      ),
    );
  }

  // showprofileimage
  Future<void> _showProfileImagePopup() async {
    await Future.delayed(
      Duration(milliseconds: 500),
    ); // Delay for smooth display
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Choose Profile Image"),
            content: SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: avatarImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _updateProfileImage(avatarImages[index]);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(avatarImages[index]),
                      radius: 30,
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }

  Future<void> _updateProfileImage(String newImage) async {
    String? userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    try {
      final response = await http.put(
        Uri.parse("http://192.168.33.126:4000/profile/update-profile-image"),
        body: jsonEncode({"userId": userId, "newImage": newImage}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'profileImage', value: newImage);
        setState(() => profileImage = newImage);
      } else {
        print("Failed to update profile image: ${response.body}");
      }
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }
}
