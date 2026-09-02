import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final file = File('assets/sounds/clear_new.wav');
  final sampleRate = 44100;
  final duration = 0.6; // 0.6 seconds
  final numSamples = (sampleRate * duration).toInt();
  
  // Arpeggio frequencies (C5, G5, C6, E6, G6)
  final freqs = [523.25, 783.99, 1046.50, 1318.51, 1567.98];
  
  final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
  final fileSize = 36 + dataSize;
  
  final header = BytesBuilder();
  
  // RIFF chunk descriptor
  header.add('RIFF'.codeUnits);
  header.add(_int32ToBytes(fileSize));
  header.add('WAVE'.codeUnits);
  
  // fmt sub-chunk
  header.add('fmt '.codeUnits);
  header.add(_int32ToBytes(16)); // Subchunk1Size
  header.add(_int16ToBytes(1)); // AudioFormat (PCM)
  header.add(_int16ToBytes(1)); // NumChannels
  header.add(_int32ToBytes(sampleRate)); // SampleRate
  header.add(_int32ToBytes(sampleRate * 2)); // ByteRate
  header.add(_int16ToBytes(2)); // BlockAlign
  header.add(_int16ToBytes(16)); // BitsPerSample
  
  // data sub-chunk
  header.add('data'.codeUnits);
  header.add(_int32ToBytes(dataSize));
  
  final audioData = BytesBuilder();
  
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    
    int segment = ((t / duration) * freqs.length).toInt();
    if (segment >= freqs.length) segment = freqs.length - 1;
    
    final freq = freqs[segment];
    
    // Square wave with vibrato
    final vibrato = sin(2 * pi * 10 * t) * 10;
    final val = sin(2 * pi * (freq + vibrato) * t);
    var sample = val > 0 ? 1.0 : -1.0;
    
    // Envelope per segment
    final segmentT = (t % (duration / freqs.length)) / (duration / freqs.length);
    final envelope = exp(-3 * segmentT);
    
    // Global envelope
    final globalEnv = 1.0 - pow(t / duration, 2);
    
    sample = sample * envelope * globalEnv * 0.4;
    
    final intSample = (sample * 32767).toInt();
    audioData.add(_int16ToBytes(intSample));
  }
  
  final output = BytesBuilder();
  output.add(header.toBytes());
  output.add(audioData.toBytes());
  
  file.writeAsBytesSync(output.toBytes());
  print('Generated clear_new.wav successfully!');
}

List<int> _int16ToBytes(int value) {
  return [value & 0xff, (value >> 8) & 0xff];
}

List<int> _int32ToBytes(int value) {
  return [
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff,
  ];
}
