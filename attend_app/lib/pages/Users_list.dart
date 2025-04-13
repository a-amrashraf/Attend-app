import 'package:attend_app/components/card.dart';
import 'package:flutter/material.dart';
import 'user_details.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  // Sample data - this would typically come from a database
  List<Map<String, dynamic>> users = [
    {"name": "amr", "sessionsLeft": 8, "daysLeft": 8},
    {"name": "omar", "sessionsLeft": 9, "daysLeft": 20},
  ];

  void decrementSession(int index) {
    setState(() {
      if (users[index]["sessionsLeft"] > 0) {
        users[index]["sessionsLeft"]--;
      }
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Attendance recorded for ${users[index]["name"]}"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users List")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return MyCard(
            name: users[index]["name"],
            sessionsLeft: users[index]["sessionsLeft"],
            daysLeft: users[index]["daysLeft"],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetails(user: users[index]),
                ),
              );
            },
            onDecrementSession: () => decrementSession(index),
          );
        },
      ),
    );
  }
}
