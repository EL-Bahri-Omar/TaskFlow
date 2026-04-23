import 'package:flutter/material.dart';
import 'package:flutter_app/data/constants.dart';

class StatusBadgeWidget extends StatelessWidget {
  const StatusBadgeWidget({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KTaskStatus.color(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            KTaskStatus.icon(status),
            size: 14,
            color: KTaskStatus.color(status),
          ),
          SizedBox(width: 4),
          Text(
            KTaskStatus.label(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: KTaskStatus.color(status),
            ),
          ),
        ],
      ),
    );
  }
}
