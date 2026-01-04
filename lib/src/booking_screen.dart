import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BarberBookingScreen extends StatefulWidget {
  // ЧУХАЛ: SDK гаднаас Barber-ийн Firestore холболтыг хүлээж авна
  final FirebaseFirestore firestore; 

  const BarberBookingScreen({super.key, required this.firestore});

  @override
  State<BarberBookingScreen> createState() => _BarberBookingScreenState();
}

class _BarberBookingScreenState extends State<BarberBookingScreen> {
  DateTime _selectedValue = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;

  final List<String> timeSlots = [
    '09:00', '10:00', '11:00', '12:00', '13:00',
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'
  ];

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Barber Booking"),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: DatePicker(
              DateTime.now(),
              height: 90,
              width: 60,
              initialSelectedDate: DateTime.now(),
              selectionColor: Colors.black,
              selectedTextColor: Colors.white,
              onDateChange: (date) {
                setState(() {
                  _selectedValue = date;
                  _selectedTime = null;
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // ЧУХАЛ: FirebaseFirestore.instance-ийн оронд widget.firestore ашиглана
              stream: widget.firestore
                  .collection('bookings')
                  .where('date', isEqualTo: formattedDate)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<String> bookedTimes = snapshot.data!.docs
                    .map((doc) => doc['time'] as String)
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    final time = timeSlots[index];
                    final isBooked = bookedTimes.contains(time);
                    final isSelected = _selectedTime == time;

                    return GestureDetector(
                      onTap: isBooked ? null : () => setState(() => _selectedTime = time),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.grey[300] : (isSelected ? Colors.black : Colors.white),
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isBooked ? Colors.grey : (isSelected ? Colors.white : Colors.black),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: (_selectedTime == null || _isLoading)
                    ? null
                    : () => _confirmBooking(formattedDate),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Захиалах ($_selectedTime)", style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(String dateStr) async {
    setState(() => _isLoading = true);
    final String bookingId = "${dateStr}_$_selectedTime";

    try {
      // ЧУХАЛ: widget.firestore ашиглаж Barber-ийн DB-рүү бичнэ
      await widget.firestore.collection('bookings').doc(bookingId).set({
        'date': dateStr,
        'time': _selectedTime,
        'timestamp': DateTime.now(),
        'status': 'confirmed',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Амжилттай!")));
        setState(() => _selectedTime = null);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Алдаа: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}