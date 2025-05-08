import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> addUserToFirebase({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String phone,
  required DateTime? birthdate,
  required String selectedSessions,
  required VoidCallback clearInputs,
  required VoidCallback onSuccess,
}) async {
  if (firstName.isEmpty ||
      lastName.isEmpty ||
      phone.isEmpty ||
      birthdate == null ||
      !RegExp(r'^\d{10,}$').hasMatch(phone)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please complete all fields correctly")),
    );
    return;
  }

  final now = DateTime.now();
  final int sessions = int.parse(selectedSessions);
  late DateTime endDate;

  if (sessions == 10) {
    endDate = now.add(const Duration(days: 35));
  } else if (sessions == 20) {
    endDate = now.add(const Duration(days: 56));
  } else {
    endDate = now.add(const Duration(days: 77));
  }

  await FirebaseFirestore.instance.collection('users').add({
    "name": "$firstName $lastName",
    "phone": phone,
    "birthdate": DateFormat('yyyy-MM-dd').format(birthdate),
    "sessionsLeft": sessions,
    "startDate": DateFormat('yyyy-MM-dd').format(now),
    "endDate": DateFormat('yyyy-MM-dd').format(endDate),
    "attendanceInfo": "New User",
    'secret': 'BigYahya',

  });

  clearInputs();
  onSuccess();
}
