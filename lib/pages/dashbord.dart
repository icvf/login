import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawhida_login/side_nav/navigation.dart'; // Adjust import as necessary for your project structure

class dashBorad extends StatelessWidget {
  dashBorad({super.key});

  final String userId = FirebaseAuth.instance.currentUser?.uid ??
      'defaultUserId'; // Fallback to a default user ID if none is found

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(), // Your custom navigation drawer
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.1,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Welcome To Your Tawhida Dashboard ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                sensorTile('SpO2', userId, 'spo2', 'lib/images/spo2.png', '%'),
                sensorTile(
                    'Heart Rate', userId, 'bpm', 'lib/images/RC.png', ' BPM'),
                sensorTile('Blood Sugar', userId, 'bloodSugar',
                    'lib/images/GLC.png', ' mg'),
                sensorTile('Body Temperature', userId, 'temperature',
                    'lib/images/TC.png', ' °C'),
                sensorTile('ECG', userId, 'ecg', 'lib/images/ECG.png', ''),
                sensorTile('EMG', userId, 'emg', 'lib/images/EMG.png', ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget sensorTile(String title, String userId, String field, String imagePath,
      String unit) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            var data = snapshot.data!.data()!;
            var value =
                data[field] != null ? '${data[field]}$unit' : 'Unavailable';
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ImageIcon(AssetImage(imagePath),
                      size: 40, color: Colors.blue),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      '$title: $value',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 21.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                    fontWeight: FontWeight.bold));
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
