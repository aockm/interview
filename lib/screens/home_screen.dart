// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:interview/comment/entity/question_entity.dart';
import 'package:interview/services/audio_service.dart';
import 'package:interview/services/storage_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final AudioRecorderService _audioService = AudioRecorderService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  final logger = Logger();


  List<InterviewQuestion> _questions = [];
  bool _isPlaying = false;
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _audioPlayer.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _storageService.loadQuestions();
    setState(() {
      _questions = questions;
    });
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      return;
    }

    final newQuestion = InterviewQuestion(
      question: _questionController.text,
      answer: _answerController.text,
    );

    setState(() {
      _questions.insert(0, newQuestion);
    });

    await _storageService.saveQuestions(_questions);

    _questionController.clear();
    _answerController.clear();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _startRecording(InterviewQuestion question) async {
    if (_audioService.isRecording) return;

    final path = await _audioService.start();
    logger.i("普通信息:$path");
    if (path == null) return;

    setState(() {
      question.audioPath = path;
    });
  }

  Future<void> _showAddQuestionDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加面试问题'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: '问题',
                    hintText: '输入面试问题',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(
                    labelText: '答案',
                    hintText: '输入参考答案',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }



  Future<void> _stopRecording() async {
    await _audioService.stopRecording();
    await _storageService.saveQuestions(_questions);
  }

  Future<void> _playRecording(InterviewQuestion question) async {
    if (question.audioPath == null) return;

    if (_isPlaying && _currentlyPlayingId == question.id) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    try {
      await _audioPlayer.setFilePath(question.audioPath!);
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
        _currentlyPlayingId = question.id;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _showAnswer(InterviewQuestion question) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('参考答案'),
          content: SingleChildScrollView(
            child: Text(question.answer),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('面试记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddQuestionDialog,
          ),
        ],
      ),
      body: _questions.isEmpty
          ? const Center(
        child: Text('暂无面试问题，点击右上角添加'),
      )
          : ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final question = _questions[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(
                          question.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () => _showAnswer(question),
                        tooltip: '查看答案',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _audioService.isRecording
                              ? Icons.stop
                              : Icons.mic,
                          color: _audioService.isRecording
                              ? Colors.red
                              : Colors.blue,
                        ),
                        onPressed: () async {
                          if (_audioService.isRecording) {
                            logger.d("这是调试信息:_stopRecording");
                            await _stopRecording();
                          } else {
                            logger.d("这是调试信息:_startRecording");
                            await _startRecording(question);
                          }
                        },
                      ),
                      if (question.audioPath != null)
                        IconButton(
                          icon: Icon(
                            _isPlaying && _currentlyPlayingId == question.id
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.green,
                          ),
                          onPressed: () => _playRecording(question),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}