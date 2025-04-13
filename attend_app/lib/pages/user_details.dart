import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${user['name']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text('Sessions Left: ${user['sessionsLeft']}'),
            Text('Days Left: ${user['daysLeft']}'),
          ],
        ),
      ),
    );
  }
}
