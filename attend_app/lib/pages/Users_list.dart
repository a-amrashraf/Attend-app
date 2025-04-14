import 'package:attend_app/components/card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _searchController.text
                .trim()
                .toLowerCase(); // Accept full name search
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void decrementSession(String docId, int currentSessions) {
    if (currentSessions <= 0) return;

    usersRef.doc(docId).update({
      'sessionsLeft': currentSessions - 1,
      'attendanceInfo':
          'Last visit: ${DateTime.now().toString().split(' ')[0]}',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance recorded"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  int calculateDaysLeft(String? endDateString) {
    if (endDateString == null) return 0;
    try {
      final endDate = DateTime.parse(endDateString);
      final now = DateTime.now();
      return endDate.difference(now).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading users"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUsers = snapshot.data!.docs;

          // Filter and sort users
          final filteredUsers =
              allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["name"] ?? "").toString().toLowerCase();
                  final sessions = data["sessionsLeft"] ?? 0;
                  return name.contains(_searchQuery) && sessions > 0;
                }).toList()
                ..sort((a, b) {
                  final nameA =
                      (a.data() as Map<String, dynamic>)["name"] ?? '';
                  final nameB =
                      (b.data() as Map<String, dynamic>)["name"] ?? '';
                  return nameA.toLowerCase().compareTo(nameB.toLowerCase());
                });

          final totalUsers = filteredUsers.length;
          final expiringSoon =
              filteredUsers.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return (data["sessionsLeft"] ?? 0) < 3;
              }).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search by name",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📋 Total Users: $totalUsers",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "⚠️ Expiring Soon (< 3 sessions): $expiringSoon",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final data = user.data() as Map<String, dynamic>;
                    final sessionsLeft = data["sessionsLeft"] ?? 0;
                    final daysLeft = calculateDaysLeft(data["endDate"]);
                    final isExpiringSoon = sessionsLeft < 3;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isExpiringSoon)
                          const Padding(
                            padding: EdgeInsets.only(left: 16, top: 4),
                            child: Text(
                              "⚠️ Expiring Soon",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        MyCard(
                          name: data["name"] ?? "Unknown",
                          sessionsLeft: sessionsLeft,
                          daysLeft: daysLeft,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UserDetails(
                                      docId: user.id,
                                      initialData: data,
                                    ),
                              ),
                            );
                          },
                          onDecrementSession:
                              () => decrementSession(user.id, sessionsLeft),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
