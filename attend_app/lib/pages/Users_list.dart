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
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void decrementSession(String docId, int currentSessions) {
    usersRef.doc(docId).update({
      'sessionsLeft': currentSessions - 1,
      'attendanceInfo': 'Last visit: ${DateTime.now().toString().split(' ')[0]}',
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD60A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Users List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 🔍 Search bar outside StreamBuilder
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by name",
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black, width: 1.2),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),

          // 📡 Live data from Firebase
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading users"));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final allUsers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["name"] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList()
                  ..sort((a, b) {
                    final nameA = (a.data() as Map<String, dynamic>)["name"] ?? '';
                    final nameB = (b.data() as Map<String, dynamic>)["name"] ?? '';
                    return nameA.toLowerCase().compareTo(nameB.toLowerCase());
                  });

                final activeUsers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data["sessionsLeft"] ?? 0) > 0;
                }).toList();

                final expiredUsers = allUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data["sessionsLeft"] ?? 0) <= 0;
                }).toList();

                final expiringSoon = activeUsers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data["sessionsLeft"] ?? 0) < 3;
                }).length;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📊 Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(Icons.people_alt, size: 20, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text(
                              "Total Users: ${allUsers.length}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 12, top: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "⚠️ Expiring Soon (< 3 sessions): $expiringSoon",
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ),

                      // ✅ Active Users
                      if (activeUsers.isNotEmpty)
                        ...activeUsers.map((user) {
                          final data = user.data() as Map<String, dynamic>;
                          final sessionsLeft = data["sessionsLeft"] ?? 0;
                          final daysLeft = calculateDaysLeft(data["endDate"]);
                          final isExpiringSoon = sessionsLeft < 3;

                          return MyCard(
                            name: data["name"] ?? "Unknown",
                            sessionsLeft: sessionsLeft,
                            daysLeft: daysLeft,
                            isExpiringSoon: isExpiringSoon,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetails(docId: user.id, initialData: data),
                                ),
                              );
                            },
                            onDecrementSession: () => decrementSession(user.id, sessionsLeft),
                          );
                        }),

                      // ❌ Expired Users
                      if (expiredUsers.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                          child: Text(
                            "❌ Expired Users",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                          ),
                        ),
                        ...expiredUsers.map((user) {
                          final data = user.data() as Map<String, dynamic>;
                          final sessionsLeft = data["sessionsLeft"] ?? 0;
                          final daysLeft = calculateDaysLeft(data["endDate"]);

                          return MyCard(
                            name: data["name"] ?? "Unknown",
                            sessionsLeft: sessionsLeft,
                            daysLeft: daysLeft,
                            isExpiringSoon: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserDetails(docId: user.id, initialData: data),
                                ),
                              );
                            },
                            onDecrementSession: () => decrementSession(user.id, sessionsLeft),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Powered by Rise Superhuman",
              style: TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
