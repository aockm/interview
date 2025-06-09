// services/storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:interview/comment/entity/question_entity.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _fileName = 'interview_questions.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<InterviewQuestion>> loadQuestions() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        // 如果文件不存在，创建一个空文件
        await file.writeAsString('[]');
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((e) => InterviewQuestion.fromMap(e)).toList();
    } catch (e) {
      print('Error loading questions: $e');
      return [];
    }
  }

  Future<void> saveQuestions(List<InterviewQuestion> questions) async {
    try {
      final file = await _localFile;
      final jsonList = questions.map((q) => q.toMap()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving questions: $e');
    }
  }

  Future<String> getAudioPath(String fileName) async {
    final path = await _localPath;
    return '$path/$fileName';
  }
}