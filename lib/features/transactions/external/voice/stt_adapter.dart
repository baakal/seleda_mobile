import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextAdapter {
  SpeechToTextAdapter({stt.SpeechToText? speech}) : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;

  Future<String?> dictateOnce() async {
    final available = await _speech.initialize(onError: (error) {}, onStatus: (_) {});
    if (!available) {
      return null;
    }
    final completer = Completer<String?>();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          completer.complete(result.recognizedWords);
          _speech.stop();
        }
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {
      _speech.stop();
      return null;
    });
  }
}
