import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prep_words/consts.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamCard extends StatelessWidget {
  final String shortName;
  final String fullName;
  final DateTime examDate;
  final String? url;

  const ExamCard({
    super.key,
    required this.shortName,
    required this.fullName,
    required this.examDate,
    this.url,
  });

  int daysLeft(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final days = daysLeft(examDate);
    final formattedDate = DateFormat("d MMMM yyyy", "tr_TR").format(examDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: yellowGreen,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // En solda shortName kutusu
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white70, // Koyu yeşil
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(shortName,
                textAlign: TextAlign.center, style: greyButtonText),
          ),
          const SizedBox(width: 16),

          // Ortada fullName ve tarih
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    if (url != null && url!.isNotEmpty) {
                      final uri = Uri.parse(url!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  child: Text(
                    fullName,
                    style: greyButtonText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: greyButtonText,
                ),
              ],
            ),
          ),

          Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white70, // Açık arka plan
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$days',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Canlı kontrast
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'days left',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
