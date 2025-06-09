
import 'package:uuid/uuid.dart';

class InterviewQuestion {
  final String id;
  final String question;
  final String answer;
  String? audioPath;
  DateTime createdAt;

  InterviewQuestion({
    required this.question,
    required this.answer,
    this.audioPath,
    DateTime? createdAt,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'audioPath': audioPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InterviewQuestion.fromMap(Map<String, dynamic> map) {
    return InterviewQuestion(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      audioPath: map['audioPath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}