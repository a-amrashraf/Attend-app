import 'package:attend_app/pages/Users_list.dart';
import 'package:attend_app/pages/add_user.dart';
import 'package:attend_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 

void main() async {
  runApp(const MainApp());
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MainApp());

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),

      routes: {
        '/home': (context) => HomePage(),
        '/Userslist': (context) => UsersList(),
        '/AddUser': (context) => AddUser(),
        '/EditUser': (context) => HomePage(),
        '/DeleteUser': (context) => HomePage(),
        '/UserDetails': (context) => HomePage(),
      },
    );
  }
}
