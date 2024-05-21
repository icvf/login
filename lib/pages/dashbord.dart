import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tawhida_login/pages/save.dart';
import 'package:tawhida_login/side_nav/navigation.dart';

class dashBorad extends StatelessWidget {
  dashBorad({super.key});

  final String userId = FirebaseAuth.instance.currentUser?.uid ??
      'defaultUserId'; // Fallback to a default user ID if none is found
  final Map<String, String> sensorData = {}; // Map to store sensor data

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Image.asset(
              "lib/images/logotaw.png",
              width: 100,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'Welcome To Your Tawhida Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                sensorTile('SpO2', userId, 'spo2', 'lib/images/spo2.png', '%'),
                sensorTile(
                    'Heart Rate', userId, 'bpm', 'lib/images/RC.png', ' BPM'),
                sensorTile('Blood Sugar', userId, 'bloodSugar',
                    'lib/images/GLC.png', ' mg'),
                sensorTile('Body Temperature', userId, 'temperature',
                    'lib/images/TC.png', '°C'),
                sensorTile('ECG', userId, 'ecg', 'lib/images/ECG.png', ''),
                sensorTile('EMG', userId, 'emg', 'lib/images/EMG.png', ''),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Save save = Save(userId);
                    await save.saveData(sensorData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data saved successfully')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Save All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
