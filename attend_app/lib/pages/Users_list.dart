import 'package:attend_app/components/card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'All';

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

  void sendWhatsAppMessage(String name, String phone, {required bool expiredByDate}) async {
    phone = phone.replaceAll(RegExp(r'\s+|-'), '').replaceFirst(RegExp(r'^0+'), '');
    final formattedPhone = '+20$phone';

    String message = expiredByDate
        ? "Hello $name! 👋🏽\n\nI wanted to let you know that your sessions at Rise have now expired.\n\nPlease feel free to reach out if you have any other questions or needs. I'm here to support you.\n\nBest regards,\nRise Family 💛"
        : "Hello $name! 👋🏽\n\nI wanted to let you know that your sessions at Rise have now ended due to session usage.\n\nPlease feel free to reach out if you have any other questions or needs. I'm here to support you.\n\nBest regards,\nRise Family 💛";

    final url = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to open WhatsApp for $formattedPhone"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD60A),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "Customers List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Text(
                  "Filter:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filter,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _filter = value);
                          }
                        },
                        items: ["All", "Active", "Expiring Soon", "Expired"].map((filter) {
                          return DropdownMenuItem(value: filter, child: Text(filter));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

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

                List<QueryDocumentSnapshot> filteredUsers = allUsers;
                if (_filter == "Active") {
                  filteredUsers = allUsers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final sessions = data["sessionsLeft"] ?? 0;
                    final endDate = data["endDate"];
                    if (endDate == null) return sessions > 0;
                    final daysLeft = calculateDaysLeft(endDate);
                    return sessions > 0 && daysLeft >= 0;
                  }).toList();
                } else if (_filter == "Expired") {
                  filteredUsers = allUsers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final sessions = data["sessionsLeft"] ?? 0;
                    final endDate = data["endDate"];
                    final daysLeft = endDate != null ? calculateDaysLeft(endDate) : 0;
                    return sessions <= 0 || daysLeft < 0;
                  }).toList();
                } else if (_filter == "Expiring Soon") {
                  filteredUsers = allUsers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data["sessionsLeft"] ?? 0) < 3 && (data["sessionsLeft"] ?? 0) > 0;
                  }).toList();
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final data = user.data() as Map<String, dynamic>;
                    final sessionsLeft = data["sessionsLeft"] ?? 0;
                    final daysLeft = calculateDaysLeft(data["endDate"]);
                    final isExpiringSoon = sessionsLeft < 3;

                    return MyCard(
                      name: data["name"] ?? "Unknown",
                      phone: data["phone"] ?? "201000000000",
                      sessionsLeft: sessionsLeft,
                      daysLeft: daysLeft,
                      isExpiringSoon: isExpiringSoon,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetails(
                              docId: user.id,
                              initialData: data,
                            ),
                          ),
                        );
                      },
                      onDecrementSession: () => decrementSession(user.id, sessionsLeft),
                    );
                  },
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
