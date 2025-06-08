import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecordPage extends StatefulWidget {
  final int questionId;
  const RecordPage({super.key, required this.questionId});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press and hold the button to speak';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
          },
          cancelOnError: false, // 不停止监听出错
          partialResults: true, // 允许部分结果
          localeId: 'en_US',
        );
        Future.delayed(Duration(minutes: 10), _stopListening);
      } else {
        setState(() => _isListening = false);
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text(
                'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
             ),
             SizedBox(height: 100),
             Expanded(
              child: Text(
                _text,
                style: TextStyle(fontSize: 24.0),
                maxLines: 50,
                softWrap: true,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                ),
              ),

          ],

        )
      )
    );
  }
}
