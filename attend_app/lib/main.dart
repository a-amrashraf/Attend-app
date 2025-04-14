import 'package:attend_app/pages/users_list.dart';
import 'package:attend_app/pages/add_user.dart';
import 'package:attend_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // ⬅️ This replaces the empty call
  // );
  runApp(const MainApp());
}

void testFirebaseConnection() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('test').get();
    print("✅ Firebase connected! Docs count: ${snapshot.docs.length}");
  } catch (e) {
    print("❌ Firebase not connected: $e");
  }
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
