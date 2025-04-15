import 'package:flutter/material.dart';
import 'package:attend_app/components/text_field.dart';
import 'package:attend_app/components/buttons.dart';
import 'package:attend_app/components/sesh_options.dart';
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

  late TextEditingController nameController;
  late TextEditingController birthdateController;
  late TextEditingController phoneController;

  int sessionsLeft = 0;
  String expiryDate = '';

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialData['name']);
    birthdateController = TextEditingController(text: widget.initialData['birthdate']);
    phoneController = TextEditingController(text: widget.initialData['phone']);
    sessionsLeft = widget.initialData['sessionsLeft'] ?? 0;
    expiryDate = widget.initialData['endDate'] ?? '';
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
        'sessionsLeft': sessionsLeft,
        'endDate': expiryDate,
      });

      setState(() => isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> handleRenewal() async {
    String selectedSessions = '10';
    final Map<String, int> sessionsToDays = {'10': 35, '20': 56, '30': 77};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Renew Membership'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select number of sessions to add:'),
                const SizedBox(height: 16),
                CustomDropdown(
                  options: ['10', '20', '30'],
                  initialSelection: selectedSessions,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSessions = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Days to be added: ${sessionsToDays[selectedSessions]}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final doc = await usersRef.doc(widget.docId).get();
                    final data = doc.data() as Map<String, dynamic>;

                    final int currentSessions = data['sessionsLeft'] ?? 0;
                    final String currentExpiryStr = data['endDate'] ?? '';
                    final DateTime now = DateTime.now();
                    final DateTime currentExpiry = DateTime.tryParse(currentExpiryStr) ?? now;
                    final int daysLeft = currentExpiry.difference(now).inDays;

                    final bool isExpiredByDate = daysLeft < 0;

                    final DateTime newExpiry = isExpiredByDate
                        ? now.add(Duration(days: sessionsToDays[selectedSessions]!))
                        : currentExpiry.add(Duration(days: sessionsToDays[selectedSessions]!));

                    final int newSessions = isExpiredByDate
                        ? int.parse(selectedSessions)
                        : currentSessions + int.parse(selectedSessions);

                    await usersRef.doc(widget.docId).update({
                      'sessionsLeft': newSessions,
                      'endDate': newExpiry.toString().split(' ')[0],
                    });

                    Navigator.pop(context);
                    setState(() {
                      sessionsLeft = newSessions;
                      expiryDate = newExpiry.toString().split(' ')[0];
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membership renewed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  void adjustSessions(int delta) {
    final newSessions = sessionsLeft + delta;
    if (newSessions < 0) return;

    final currentExpiry = DateTime.tryParse(expiryDate) ?? DateTime.now();
    final adjustedExpiry = currentExpiry.add(Duration(days: delta * 3));

    setState(() {
      sessionsLeft = newSessions;
      expiryDate = adjustedExpiry.toString().split(' ')[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD60A),
        title: const Text('User Details', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.black),
            onPressed: () {
              isEditing ? handleUpdateUserInfo() : setState(() => isEditing = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this user? This action cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final deletedUserData = widget.initialData;
                await usersRef.doc(widget.docId).delete();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('User deleted'),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'UNDO',
                      textColor: Colors.white,
                      onPressed: () async {
                        await usersRef.doc(widget.docId).set(deletedUserData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User restored'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                );
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
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(child: Text('No data found for this user.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("User Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                MyTextfield(hintText: 'Full Name', obsecureText: false, controller: nameController, enabled: isEditing),
                const SizedBox(height: 12),
                MyTextfield(hintText: 'Birthdate', obsecureText: false, controller: birthdateController, enabled: isEditing),
                const SizedBox(height: 12),
                MyTextfield(hintText: 'Phone Number', obsecureText: false, controller: phoneController, enabled: isEditing),
                const SizedBox(height: 18),
                const Text("Membership Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            const Text("Sessions Left", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isEditing)
                                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => adjustSessions(-1)),
                                Text('$sessionsLeft', style: const TextStyle(fontSize: 18)),
                                if (isEditing)
                                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => adjustSessions(1)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          children: [
                            const Text("Expiry Date", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(expiryDate, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1, color: Colors.black12),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.shade50,
                  ),
                  child: Text(
                    data['attendanceInfo'] ?? 'No attendance info',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(text: "Renew Membership", onTap: handleRenewal),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
