import 'package:flutter/material.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:attend_app/components/buttons.dart';
import 'package:attend_app/pages/sesh_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const UserDetails({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final usersRef = FirebaseFirestore.instance.collection('users');
  String selectedSessions = '10';
  final Map<String, int> sessionsToDays = {'10': 35, '20': 56, '30': 77};

  //  controllers for editable fields
  late TextEditingController nameController;
  late TextEditingController birthdateController;
  late TextEditingController phoneController;
  bool isEditing = false;

  // In initState, initialize with initial data
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    birthdateController = TextEditingController(
      text: widget.initialData['birthdate'],
    );
    phoneController = TextEditingController(text: widget.initialData['phone']);
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdateController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> handleUpdateUserInfo() async {
    try {
      await usersRef.doc(widget.docId).update({
        'name': nameController.text,
        'birthdate': birthdateController.text,
        'phone': phoneController.text,
      });

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleAttendance() async {
    try {
      DocumentSnapshot doc = await usersRef.doc(widget.docId).get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data['sessionsLeft'] > 0) {
        await usersRef.doc(widget.docId).update({
          'sessionsLeft': data['sessionsLeft'] - 1,
          'attendanceInfo':
              'Last visit: ${DateTime.now().toString().split(' ')[0]}',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance recorded successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> handleRenewal() async {
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
                  onPressed: () async {
                    try {
                      DocumentSnapshot doc =
                          await usersRef.doc(widget.docId).get();
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      DateTime currentEndDate = DateTime.parse(data['endDate']);
                      DateTime newEndDate = currentEndDate.add(
                        Duration(days: sessionsToDays[selectedSessions]!),
                      );

                      await usersRef.doc(widget.docId).update({
                        'sessionsLeft':
                            data['sessionsLeft'] + int.parse(selectedSessions),
                        'endDate': newEndDate.toString().split(' ')[0],
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Membership renewed successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
      appBar: AppBar(
        title: Text('User Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                handleUpdateUserInfo();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersRef.doc(widget.docId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Update controllers with latest data if not editing
          //if (!isEditing) {
          //   nameController.text = userData['name'] ?? '';
          //  birthdateController.text = userData['birthdate'] ?? '';
          // phoneController.text = userData['phone'] ?? '';
          //  }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                MyTextfield(
                  hintText: 'Name',
                  obsecureText: false,
                  controller: nameController,
                ),
                SizedBox(height: 16),
                MyTextfield(
                  hintText: 'Birthdate',
                  obsecureText: false,
                  controller: birthdateController,
                ),
                SizedBox(height: 16),
                MyTextfield(
                  hintText: 'Phone Number',
                  obsecureText: false,
                  controller: phoneController,
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
                            Text('${userData['sessionsLeft']}'),
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
                            Text('Expiry Date'),
                            Text('${userData['endDate']}'),
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
                  child: Text(
                    userData['attendanceInfo'] ?? 'No attendance info',
                  ),
                ),
                Spacer(),
                MyButton(text: 'Customer Attend', onTap: handleAttendance),
                SizedBox(height: 8),
                MyButton(text: 'Renew Membership', onTap: handleRenewal),
              ],
            ),
          );
        },
      ),
    );
  }
}
