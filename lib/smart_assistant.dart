import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SmartAssistant extends StatefulWidget {
  final Map<String, VoidCallback> actions;
  const SmartAssistant({super.key, required this.actions});

  @override
  State<SmartAssistant> createState() => _SmartAssistantState();
}

class _SmartAssistantState extends State<SmartAssistant> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _response = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  _initTts() async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.2);
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize();
    if (available && mounted) {
      _startListening();
    } else {
      _speak("الميكروفون غير متاح");
    }
  }

  Future<void> _speak(String text) async {
    if (mounted) setState(() => _response = text);
    await _tts.speak(text);
  }

  Future<void> _startListening() async {
    if (_isListening || _speech.isListening) return;
    bool available = await _speech.initialize();
    if (!available) return;
    if (mounted) setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) async {
        if (_isProcessing) return;
        String command = result.recognizedWords;
        if (command.isNotEmpty && mounted && !_isProcessing) {
          setState(() => _isListening = false);
          _isProcessing = true;
          await _executeCommand(command);
          _isProcessing = false;
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_speech.isListening) _startListening();
          });
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: "ar_SA",
        listenFor: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _executeCommand(String cmd) async {
    cmd = cmd.toLowerCase();
    bool found = false;
    for (var entry in widget.actions.entries) {
      if (cmd.contains(entry.key.toLowerCase())) {
        found = true;
        entry.value();
        await _speak("تم ${entry.key}");
        break;
      }
    }
    if (!found) {
      await _speak("عذراً، لم أفهم الأمر: $cmd");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_response.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_response, style: const TextStyle(fontSize: 14)),
          ),
        ElevatedButton.icon(
          onPressed: _startListening,
          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 28),
          label: Text(_isListening ? "جاري الاستماع..." : "تكلم مع المساعدة", style: const TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(150, 40),
          ),
        ),
      ],
    );
  }
}