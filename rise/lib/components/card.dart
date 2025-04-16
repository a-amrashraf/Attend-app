import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyCard extends StatelessWidget {
  final String name;
  final int sessionsLeft;
  final int daysLeft;
  final bool isExpiringSoon;
  final void Function()? onTap;
  final void Function()? onDecrementSession;
  final String phone;

  const MyCard({
    super.key,
    required this.name,
    required this.sessionsLeft,
    required this.daysLeft,
    required this.isExpiringSoon,
    required this.onTap,
    required this.onDecrementSession,
    required this.phone,
  });

  void sendWhatsAppMessage(BuildContext context, String name, String phone, String messageType) async {
  String cleanedPhone = phone.trim().replaceAll(RegExp(r'^0+'), '');
  String fullPhone = '+20$cleanedPhone';

  String message;
  if (messageType == 'expiring') {
    message = """Hey $name 

Just a quick reminder — we’ve got 2 training sessions left before our current package expires! Let’s make the most of them, bring that energy, and finish strong! 🔥

See you at the next session!""";
  } else if (messageType == 'expired_date') {
    message = """Hello $name! 

I wanted to let you know that your sessions at Rise have now expired.

Please feel free to reach out if you have any other questions or needs. I'm here to support you.

Best regards,
Rise Family """;
  } else {
    message = """Hello $name! 

I wanted to let you know that your sessions at Rise have now ended due to session usage.

Please feel free to reach out if you have any other questions or needs. I'm here to support you.

Best regards,
Rise Family """;
  }

  final url = "https://wa.me/$fullPhone?text=${Uri.encodeComponent(message)}";

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not open WhatsApp")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final bool isExpired = sessionsLeft <= 0 || daysLeft < 0;
    final Color cardColor = isExpired
        ? const Color(0xFFFFEBEE)
        : isExpiringSoon
            ? const Color(0xFFFFF3CD)
            : const Color(0xFFFFFDE7);

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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.85),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
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
            Column(
              children: [
                if (onDecrementSession != null)
                  ElevatedButton(
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
                    child: const Text("Attend", style: TextStyle(fontWeight: FontWeight.w600)),
                  )
                else
                  const Text(
                    "Expired",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                if (sessionsLeft == 2 || isExpired)
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    onPressed: () {
                      if (sessionsLeft == 2) {
                        sendWhatsAppMessage(context, name, phone, 'expiring');
                      } else if (daysLeft < 0) {
                        sendWhatsAppMessage(context, name, phone, 'expired_date');
                      } else if (sessionsLeft <= 0) {
                        sendWhatsAppMessage(context, name, phone, 'expired_sessions');
                      }
                    },
                    tooltip: "Send WhatsApp Reminder",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
