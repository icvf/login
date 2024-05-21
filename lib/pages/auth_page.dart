// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawhida_login/pages/HomePage.dart';

import 'login_or_register_page.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return HomePage(
              fromLoginPage: false,
            );
          }

          // user is not logged in
          else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }

  // Declare the sensorData map
  final Map<String, String> sensorData = {};

  Widget sensorTile(String title, String userId, String field, String imagePath,
      String unit) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            var data = snapshot.data!.data()!;
            var value =
                data[field] != null ? '${data[field]}$unit' : 'Unavailable';

            // Store the sensor data in the map
            sensorData[field] = data[field]?.toString() ?? 'Unavailable';

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ImageIcon(AssetImage(imagePath),
                      size: 40, color: Colors.blue),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      '$title: $value',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
