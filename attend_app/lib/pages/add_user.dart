import 'package:attend_app/components/birthdate_field.dart';
import 'package:attend_app/components/buttons.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting dates
import 'package:attend_app/components/sesh_options.dart';


class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController firstnamecontroller = TextEditingController();
  final TextEditingController lastnamecontroller = TextEditingController();
  final TextEditingController numbercontroller = TextEditingController();

  String selectedSessions = '10';
  DateTime? birthdate;

  void pickBirthdate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdate = picked;
      });
    }
  }

  Future<void> addUserToFirebase() async {
    final firstName = firstnamecontroller.text.trim();
    final lastName = lastnamecontroller.text.trim();
    final phone = numbercontroller.text.trim();
    final fullName = '$firstName $lastName';

  if (firstName.isEmpty || lastName.isEmpty || phone.isEmpty || birthdate == null || !RegExp(r'^\d{10,}$').hasMatch(phone)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Please complete all fields correctly")),
  );
  return;
}

    final now = DateTime.now();
    final int sessions = int.parse(selectedSessions);
    late DateTime endDate;

if (sessions == 10) {
  endDate = now.add(const Duration(days: 35)); // 5 weeks
} else if (sessions == 20) {
  endDate = now.add(const Duration(days: 56)); // 8 weeks
} else if (sessions == 30) {
  endDate = now.add(const Duration(days: 77)); // 11 weeks
}


    await FirebaseFirestore.instance.collection('users').add({
      "name": fullName,
      "phone": phone,
      "birthdate": DateFormat('yyyy-MM-dd').format(birthdate!),
      "sessionsLeft": sessions,
      "startDate": DateFormat('yyyy-MM-dd').format(now),
      "endDate": DateFormat('yyyy-MM-dd').format(endDate),
      "attendanceInfo": "New User"
    });

    firstnamecontroller.clear();
lastnamecontroller.clear();
numbercontroller.clear();
setState(() {
  birthdate = null;
  selectedSessions = '10';
});


    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add User")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(height: 20),
            MyTextfield(
              hintText: "First Name",
              obsecureText: false,
              controller: firstnamecontroller,
            ),
            SizedBox(height: 20),
            MyTextfield(
              hintText: "Last Name",
              obsecureText: false,
              controller: lastnamecontroller,
            ),
            SizedBox(height: 20),
            MyTextfield(
              hintText: "Phone Number",
              obsecureText: false,
              controller: numbercontroller,
            ),
            
SizedBox(height: 20),
BirthdateEntryField(
  onDateSelected: (pickedDate) {
    setState(() {
      birthdate = pickedDate;
    });
  },
),

            SizedBox(height: 20),
Text("Number of Sessions:", style: TextStyle(fontSize: 20)),
SizedBox(height: 10),
CustomDropdown(
  options: ['10', '20', '30'],
  initialSelection: selectedSessions,
  onChanged: (value) {
    setState(() {
      selectedSessions = value;
    });
  },
),

            SizedBox(height: 30),
            MyButton(
              text: "Add User",
              onTap: addUserToFirebase,
            ),
          ],
        ),
      ),
    );
  }
}
