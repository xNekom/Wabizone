import 'package:flutter/material.dart';
import '../utils/constants_utils.dart';

class ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const ContactItem({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Constants.primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(content),
            ],
          ),
        ],
      ),
    );
  }
}
