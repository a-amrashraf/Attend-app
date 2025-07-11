import 'package:rise/components/birthdate_field.dart';
import 'package:rise/components/buttons.dart';
import 'package:rise/components/fun_add_user.dart';
import 'package:rise/components/text_field.dart';
import 'package:flutter/material.dart';
import 'package:rise/components/sesh_options.dart';


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

  void handleAddUser() {
    addUserToFirebase(
      context: context,
      firstName: firstnamecontroller.text.trim(),
      lastName: lastnamecontroller.text.trim(),
      phone: numbercontroller.text.trim(),
      birthdate: birthdate,
      selectedSessions: selectedSessions,
      clearInputs: () {
        firstnamecontroller.clear();
        lastnamecontroller.clear();
        numbercontroller.clear();
        setState(() {
          birthdate = null;
          selectedSessions = '10';
        });
      },
      onSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
    );
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
            MyButton(text: "Add User", onTap: handleAddUser),
          ],
        ),
      ),
    );
  }
}
