import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prep_words/components/exam_card.dart';
import 'package:prep_words/consts.dart';

class ExamCalendarPage extends StatelessWidget {
  const ExamCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final examsRef = FirebaseFirestore.instance.collection('exams');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sınav Takvimi",
          style: headingLarge,
        ),
        backgroundColor: yellowGreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: examsRef.orderBy('examDate').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No exams found"));
          }

          final exams = snapshot.data!.docs;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index].data()! as Map<String, dynamic>;

              return ExamCard(
                shortName: exam['shortName'],
                fullName: exam['fullName'],
                examDate: (exam['examDate'] as Timestamp).toDate(),
                url: exam['url'],
              );
            },
          );
        },
      ),
    );
  }
}
