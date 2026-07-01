/// Haier HSU07-HEA03 A/C infrared protocol encoder.
///
/// Unlike TV IR codes (one independent signal per button), this AC protocol
/// sends its ENTIRE current state (temperature, mode, fan speed, swing) in
/// a single 9-byte / 72-bit packet on every button press, with a checksum.
/// This encoder builds that packet dynamically and converts it into a raw
/// mark/space pulse pattern for transmission.
///
/// Protocol reference (community-verified, widely used):
/// https://github.com/crankyoldgit/IRremoteESP8266 — src/ir_Haier.h / ir_Haier.cpp
/// Model: Haier HSU07-HEA03 remote (protocol id: HAIER_AC)
///
/// NOTE: There are several distinct Haier AC protocol families in real-world
/// use (HAIER_AC, HAIER_AC_YRW02, HAIER_AC176, HAIER_AC160). This encoder
/// implements only the original/simplest one (HSU07-HEA03). It will not
/// necessarily work on Haier units that use a different remote family.
class HaierEncoder {
  // Timing constants (microseconds), from ir_Haier.cpp.
  static const int _hdrMark = 3000;
  static const int _hdrSpace = 4300;
  static const int _bitMark = 520;
  static const int _oneSpace = 1650;
  static const int _zeroSpace = 650;
  static const int _minGap = 150000;

  // Command nibble values (byte 1, low nibble).
  static const int cmdOff = 0x0;
  static const int cmdOn = 0x1;
  static const int cmdMode = 0x2;
  static const int cmdFan = 0x3;
  static const int cmdTempUp = 0x6;
  static const int cmdTempDown = 0x7;
  static const int cmdSleep = 0x8;
  static const int cmdSwing = 0xD;

  static const int minTemp = 16;
  static const int maxTemp = 30;

  // Mode values (byte 6, high 3 bits).
  static const int modeAuto = 0;
  static const int modeCool = 1;
  static const int modeDry = 2;
  static const int modeHeat = 3;
  static const int modeFan = 4;

  // Fan values (byte 5, high 2 bits). Native encoding: 1=High,2=Med,3=Low,0=Auto.
  static const int fanAuto = 0;
  static const int fanHigh = 1;
  static const int fanMed = 2;
  static const int fanLow = 3;

  // Vertical swing (byte 2, high 2 bits).
  static const int swingOff = 0;
  static const int swingUp = 1;
  static const int swingDown = 2;
  static const int swingChange = 3;

  /// Builds the raw mark/space pulse pattern for one full AC state + a
  /// specific button/command. [tempC] must already be clamped 16-30.
  static List<int> build({
    required int command,
    required int tempC,
    required int mode,
    required int fan,
    required int swingV,
    bool health = false,
    bool sleep = false,
  }) {
    final t = tempC.clamp(minTemp, maxTemp);
    final bytes = List<int>.filled(9, 0);

    bytes[0] = 0xA5; // Prefix (kHaierAcPrefix)
    bytes[1] = (command & 0x0F) | (((t - minTemp) & 0x0F) << 4);
    bytes[2] = (0 & 0x1F) | (1 << 5) | ((swingV & 0x3) << 6); // unknown bit = 1
    bytes[3] = 0; // current time / timers unused
    bytes[4] = (12 & 0x1F) | ((health ? 1 : 0) << 5); // default OffHours=12
    bytes[5] = (fan & 0x3) << 6;
    bytes[6] = (mode & 0x7) << 5;
    bytes[7] = (sleep ? 1 : 0) << 6;

    int sum = 0;
    for (int i = 0; i < 8; i++) {
      sum += bytes[i];
    }
    bytes[8] = sum & 0xFF;

    final pattern = <int>[];
    // sendHaierAC() sends an extra mark+space before the "real" header.
    pattern.add(_hdrMark);
    pattern.add(_hdrMark);
    // sendGeneric()'s own header.
    pattern.add(_hdrMark);
    pattern.add(_hdrSpace);
    // 9 bytes, MSB-first per byte.
    for (final byte in bytes) {
      for (int bit = 7; bit >= 0; bit--) {
        final isOne = ((byte >> bit) & 1) == 1;
        pattern.add(_bitMark);
        pattern.add(isOne ? _oneSpace : _zeroSpace);
      }
    }
    // Footer mark + trailing gap (kept explicit so the array has an even
    // length, as required by Android's ConsumerIrManager.transmit()).
    pattern.add(_bitMark);
    pattern.add(_minGap);

    return pattern;
  }
}
