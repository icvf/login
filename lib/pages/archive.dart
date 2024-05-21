import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArchivePage extends StatefulWidget {
  final String userId;

  const ArchivePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> dates = [];
  String? selectedDate;
  Map<String, dynamic> measurements = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDates();
  }

  Future<void> _fetchDates() async {
    try {
      // Fetch the user document
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(widget.userId).get();

      if (userDoc.exists) {
        // Assuming each field name (except known fields like CIN, CNAM, name, etc.) is a date
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          dates = userData.keys
              .where((key) =>
                  key != 'CIN' &&
                  key != 'CNAM' &&
                  key != 'name' &&
                  key != 'phone' &&
                  key != 'emg' &&
                  key != 'spo2' &&
                  key != 'bpm' &&
                  key != 'temperature' &&
                  key != '' &&
                  key != 'phone_friend')
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching dates: $e");
    }
  }

  Future<void> _fetchMeasurements(String date) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Users')
          .doc(widget.userId)
          .collection(date)
          .doc(
              'measurements') // Assuming measurements are stored under a single document named 'measurements'
          .get();
      setState(() {
        measurements = doc.data() as Map<String, dynamic>;
      });
    } catch (e) {
      print("Error fetching measurements: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Archive'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Date:'),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedDate,
                        items: dates.map((date) {
                          return DropdownMenuItem<String>(
                            value: date,
                            child: Text(date),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDate = value;
                            measurements = {}; // Clear previous measurements
                          });
                          if (value != null) {
                            _fetchMeasurements(value);
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      selectedDate != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sensorTile('Blood Sugar', 'bloodSugar',
                                    'lib/images/GLC.png', 'mg'),
                                sensorTile(
                                    'BPM', 'bpm', 'lib/images/RC.png', 'BPM'),
                                sensorTile(
                                    'ECG', 'ecg', 'lib/images/ECG.png', ''),
                                sensorTile(
                                    'EMG', 'emg', 'lib/images/EMG.png', ''),
                                sensorTile(
                                    'SPO2', 'spo2', 'lib/images/spo2.png', '%'),
                                sensorTile('Temperature', 'temperature',
                                    'lib/images/TC.png', '°C'),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget sensorTile(String title, String field, String imagePath, String unit) {
    var value = measurements[field] != null
        ? '${measurements[field]}$unit'
        : 'Unavailable';

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
          ImageIcon(AssetImage(imagePath), size: 40, color: Colors.blue),
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
  }
}
