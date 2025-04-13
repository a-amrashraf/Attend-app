import 'package:flutter/material.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:attend_app/components/buttons.dart';
import 'package:attend_app/pages/sesh_options.dart';

class UserDetails extends StatefulWidget {
  final Map<String, dynamic> user;
  final int index;
  final Function(int) onAttend;
  final Function(int, Map<String, dynamic>) onUpdate;

  const UserDetails({
    super.key,
    required this.user,
    required this.index,
    required this.onAttend,
    required this.onUpdate,
  });

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Map<String, dynamic> localUser;
  String selectedSessions = '10';

  final Map<String, int> sessionsToDays = {'10': 35, '20': 56, '30': 77};

  @override
  void initState() {
    super.initState();
    localUser = Map.from(widget.user);
  }

  void handleAttendance() {
    if (localUser['sessionsLeft'] > 0) {
      widget.onAttend(widget.index);
      setState(() {
        localUser['sessionsLeft']--;
        localUser['attendanceInfo'] =
            'Last visit: ${DateTime.now().toString().split(' ')[0]}';
      });
      widget.onUpdate(widget.index, localUser);
    }
  }

  void handleRenewal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Renew Membership'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select number of sessions to add:'),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: CustomDropdown(
                      options: ['10', '20', '30'],
                      initialSelection: selectedSessions,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSessions = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Days to be added: ${sessionsToDays[selectedSessions]}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      localUser['sessionsLeft'] += int.parse(selectedSessions);
                      localUser['daysLeft'] +=
                          sessionsToDays[selectedSessions]!;
                    });
                    widget.onUpdate(widget.index, localUser);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membership renewed successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
              controller: TextEditingController(text: localUser['name']),
            ),
            SizedBox(height: 16),
            MyTextfield(
              hintText: 'Birthdate',
              obsecureText: false,
              controller: TextEditingController(text: localUser['birthdate']),
            ),
            SizedBox(height: 16),
            MyTextfield(
              hintText: 'Phone Number',
              obsecureText: false,
              controller: TextEditingController(text: localUser['phone']),
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
                        Text('${localUser['sessionsLeft']}'),
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
                        Text('${localUser['daysLeft']}'),
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
              child: Text(localUser['attendanceInfo'] ?? 'No attendance info'),
            ),
            Spacer(),
            MyButton(text: 'Customer Attend', onTap: handleAttendance),
            SizedBox(height: 8),
            MyButton(text: 'Renew Membership', onTap: handleRenewal),
          ],
        ),
      ),
    );
  }
}
