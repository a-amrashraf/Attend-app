import 'package:attend_app/components/card.dart';
import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users List"),
      ),
      body: ListView(
        children: [
          MyCard(name: "amr", sessionsLeft: 8, daysLeft: 8, onTap: (){}),
          MyCard(name: "omar", sessionsLeft: 9, daysLeft: 20, onTap: (){}),
        ]
      ),
    );
  }
}