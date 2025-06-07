// interview_practice_app.dart
import 'package:flutter/material.dart';
import 'package:interview/home/HomePage.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(InterviewApp());

class InterviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Practice',
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

// Mock database
final questions = [
  {'id': 1, 'question': 'What are your strengths?', 'answer': 'My strengths are adaptability and problem-solving.'},
  {'id': 2, 'question': 'Tell me about a challenge you faced.', 'answer': 'I faced a tough project deadline and managed it by reprioritizing tasks.'},
];

class QuestionListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interview Questions')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return ListTile(
            title: Text(question['question'] as String),
            trailing: IconButton(
              icon: Icon(Icons.mic),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecordingPage(questionId: question['id'] as int),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecordingPage extends StatefulWidget {
  final int questionId;
  RecordingPage({required this.questionId});

  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  late SpeechToText _speech;
  bool _isListening = false;
  String _transcription = '';

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    setState(() => _isListening = true);
    await _speech.listen(onResult: (result) {
      setState(() => _transcription = result.recognizedWords);
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    _saveAnswer(widget.questionId, _transcription);
  }

  Future<void> _saveAnswer(int id, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('answer_$id', answer);
  }

  void _viewAnswerComparison() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnswerComparisonPage(questionId: widget.questionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Your Answer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            Text('Your Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_transcription),
            Spacer(),
            ElevatedButton(
              onPressed: _transcription.isNotEmpty ? _viewAnswerComparison : null,
              child: Text('View Answer Comparison'),
            )
          ],
        ),
      ),
    );
  }
}

class AnswerComparisonPage extends StatelessWidget {
  final int questionId;
  AnswerComparisonPage({required this.questionId});

  Future<String> _loadUserAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('answer_$questionId') ?? 'No answer recorded.';
  }

  @override
  Widget build(BuildContext context) {
    final question = questions.firstWhere((q) => q['id'] == questionId);

    return Scaffold(
      appBar: AppBar(title: Text('Answer Comparison')),
      body: FutureBuilder<String>(
        future: _loadUserAnswer(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(snapshot.data!),
                SizedBox(height: 20),
                Text('Reference Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(question['answer'] as String),
              ],
            ),
          );
        },
      ),
    );
  }
}
