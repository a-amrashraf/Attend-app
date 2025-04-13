import 'package:flutter/material.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:attend_app/components/buttons.dart';

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
          children: [
            MyTextfield(
              hintText: 'Name',
              obsecureText: false,
              controller: TextEditingController(text: user['name']),
            ),
            SizedBox(height: 16),
            MyTextfield(
              hintText: 'Birthdate',
              obsecureText: false,
              controller: TextEditingController(text: user['birthdate']),
            ),
            SizedBox(height: 16),
            MyTextfield(
              hintText: 'Phone Number',
              obsecureText: false,
              controller: TextEditingController(text: user['phone']),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text('Remain Session'),
                        Text('${user['sessionsLeft']}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text('Remain Days'),
                        Text('${user['daysLeft']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(user['attendanceInfo'] ?? 'No attendance info'),
            ),
            Spacer(),
            MyButton(
              text: 'Customer Attend',
              onTap: () {
                // TODO: Implement attendance logic
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8),
            MyButton(
              text: 'Renew Membership',
              onTap: () {
                // TODO: Implement renewal logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
