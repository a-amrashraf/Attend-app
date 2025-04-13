import 'package:attend_app/components/buttons.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: const Color(0xFFFFD60A), // Primary color
        title: Text(
          'Welcome',
          style: TextStyle(color: Color(0xFF0A0A0A)),
        ), // Text color
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 30),
            MyButton(
              text: "Users List",
              onTap: () {
                Navigator.pushNamed(context, '/Userslist');
              },
            ),
            SizedBox(height: 30),
            MyButton(
              text: "Add User",
              onTap: () {
                Navigator.pushNamed(context, '/AddUser');
              },
            ),
            SizedBox(height: 30),
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
