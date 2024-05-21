import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tawhida_login/pages/BLEpage.dart';
import 'package:tawhida_login/pages/HomePage.dart';
import 'package:tawhida_login/pages/archive.dart';
import 'package:tawhida_login/pages/login_page.dart'; // Ensure this import exists

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final String userId =
      FirebaseAuth.instance.currentUser?.uid ?? 'defaultUserId';
  File? _profileImage;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadBackgroundImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImagePath');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _loadBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('backgroundImagePath');
    if (imagePath != null) {
      setState(() {
        _backgroundImage = File(imagePath);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', pickedFile.path);
    }
  }

  Future<void> _pickBackgroundImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backgroundImagePath', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading...");
                } else if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data()!;
                  var name = data['name'] ?? "No name";
                  return Text(name.toString());
                } else {
                  return Text("No user");
                }
              },
            ),
            accountEmail: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading...");
                } else if (snapshot.hasData) {
                  return Text(snapshot.data!.email ?? "No email");
                } else {
                  return Text("No user");
                }
              },
            ),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey[800],
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 8, 210, 225),
              image: _backgroundImage != null
                  ? DecorationImage(
                      image: FileImage(_backgroundImage!),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage('lib/images/img.jpg'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.black26),
            title: Text("Profile"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.home_filled, color: Colors.black26),
            title: Text("Home"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(fromLoginPage: true),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications_sharp, color: Colors.black26),
            title: Text("Notifications"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.folder_open, color: Colors.black26),
            title: Text("Archive DMI"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchivePage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black26),
            title: Text("Configure Device "),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BLEPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_month, color: Colors.black26),
            title: Text("Calendrier"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.image, color: Colors.black26),
            title: Text("Change Background"),
            onTap: _pickBackgroundImage,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.black26),
            title: Text("Log out"),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.grey[200],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null
                ? Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey[800],
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
