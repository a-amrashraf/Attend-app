import 'package:attend_app/components/birthdate_field.dart';
import 'package:attend_app/components/buttons.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:attend_app/pages/sesh_options.dart';
import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

final TextEditingController firstnamecontroller = TextEditingController();
final TextEditingController lastnamecontroller = TextEditingController();
final TextEditingController numbercontroller = TextEditingController();
// final TextEditingController firstnamecontroller = TextEditingController();
// final TextEditingController firstnamecontroller = TextEditingController();


class _AddUserState extends State<AddUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User"),
      ),
      body:Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          MyTextfield(hintText: "First Name", obsecureText: false, controller: firstnamecontroller),
          SizedBox(height: 20,),
          MyTextfield(hintText: "Last Name", obsecureText: false, controller: lastnamecontroller),
          SizedBox(height: 20,),
          MyTextfield(hintText: "Phone Number", obsecureText: false, controller: numbercontroller),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: BirthdateEntryField()),
          SizedBox(height: 20),
          Container(
            child: Text("Number of Sessions:", style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: CustomDropdown(options: ['10', '20', '30'], initialSelection: '10', onChanged: (selectedValue) {
              setState(() {
              });
            }),
          ),
          SizedBox(height: 20,),
          MyButton(text: "Add User", onTap: (){
            Navigator.pushReplacementNamed(context, '/home');// change it to user info page
          })

          ],
      )
      ),
    );
  }
}