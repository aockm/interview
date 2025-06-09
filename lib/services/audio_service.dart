// services/audio_service.dart
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';


class AudioRecorderService {
  final logger = Logger();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  Future<bool> get isRecordingSupported async {
    try {
      return await _audioRecorder.hasPermission() &&
          await _audioRecorder.isEncoderSupported(AudioEncoder.aacLc);
    } catch (_) {
      return false;
    }
  }
  Future<bool> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    final storageStatus = await Permission.storage.status;
    logger.i("micStatus:$micStatus storageStatus$storageStatus");
    if (!micStatus.isGranted || !storageStatus.isGranted) {
      final results = await [
        Permission.microphone,
        Permission.storage,
      ].request();

      return results[Permission.microphone]?.isGranted == true &&
          results[Permission.storage]?.isGranted == true;
    }
    return true;
  }

  Future<String?> start() async {
    try {
      if (_isRecording) return null;

      if (!await _checkPermissions()) {
        logger.i("没有权限");
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      // final path = await _generatePath();

      final config = await _getBestConfig();

      await _audioRecorder.start(
        RecordConfig(encoder: config.encoder,
          bitRate: config.bitRate,
          sampleRate: config.sampleRate,),
        path: path,

      );

      _isRecording = true;
      return path;
    } catch (e) {
      // _logError(e);
      return null;
    }
  }

  Future<AudioConfig> _getBestConfig() async {
    const presets = [
      AudioConfig(AudioEncoder.aacLc, 44100, 128000),
      AudioConfig(AudioEncoder.aacLc, 16000, 64000),
      AudioConfig(AudioEncoder.amrNb, 8000, 12200),
    ];

    for (final preset in presets) {
      if (await _audioRecorder.isEncoderSupported(preset.encoder)) {
        return preset;
      }
    }
    throw 'No supported audio config found';
  }
  Future<void> stopRecording() async {
    try {
      if (!_isRecording) return;
      await _audioRecorder.stop();
      _isRecording = false;
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  void dispose() {
    _audioRecorder.dispose();
  }

// 其他辅助方法...
}

class AudioConfig {
  final AudioEncoder encoder;
  final int sampleRate;
  final int bitRate;

  const AudioConfig(this.encoder, this.sampleRate, this.bitRate);
}