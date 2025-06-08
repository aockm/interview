import 'package:flutter/material.dart';
import 'package:siri_wave/siri_wave.dart';

void showVoiceRecordingSheet(BuildContext context,String title) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,

    builder: (ctx) => StatefulBuilder( // 关键：使用StatefulBuilder
      builder: (context, setState) {
        bool isRecording = false;
        final waveController = IOS9SiriWaveformController();

        void _toggleRecording() {
          setState(() => isRecording = !isRecording);
          // 实际录音逻辑
          if (isRecording) {
            // waveController.setAmplitude(1.5); // 开始波形
          } else {
            // waveController.setAmplitude(0); // 停止波形
          }
        }

        return Container(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          child: Column(
            children: [
              Text(title),
              FloatingActionButton.large(
                onPressed: _toggleRecording,
                backgroundColor: isRecording ? Colors.red : Colors.blue,
                child: Icon(isRecording ? Icons.stop : Icons.mic),
              )

            ]
          ),
        );
      },
    ),
  );
}