import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyCard extends StatelessWidget {
  final String name;
  final int sessionsLeft;
  final int daysLeft;
  final bool isExpiringSoon;
  final void Function()? onTap;
  final void Function()? onDecrementSession;

  const MyCard({
    super.key,
    required this.name,
    required this.sessionsLeft,
    required this.daysLeft,
    required this.isExpiringSoon,
    required this.onTap,
    required this.onDecrementSession,
  });

  @override
  Widget build(BuildContext context) {
    // 🌈 Background based on status
    final bool isExpired = sessionsLeft <= 0;
    final Color cardColor = isExpired
        ? const Color(0xFFFFEBEE) // 🟥 Light red for expired
        : isExpiringSoon
            ? const Color(0xFFFFF3CD) // ⚠️ Light yellow-orange
            : const Color(0xFFFFFDE7); // ✅ Soft yellow

    final BorderSide border = isExpired
        ? BorderSide(color: Colors.red.shade200, width: 1.5)
        : isExpiringSoon
            ? const BorderSide(color: Colors.orange, width: 1)
            : BorderSide.none;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.fromBorderSide(border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // 👤 Avatar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.85),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),

            // 📝 Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.add_box, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        "$sessionsLeft session${sessionsLeft.abs() == 1 ? '' : 's'} left",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        "$daysLeft days left",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🎯 Attend or Expired badge
            onDecrementSession != null
                ? ElevatedButton(
                    onPressed: onDecrementSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      elevation: 6,
                    ),
                    child: const Text(
                      "Attend",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : const Text(
                    "Expired",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
