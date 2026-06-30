class BrandModel {
  final String name;
  final int fileIndex;

  BrandModel({required this.name, required this.fileIndex});

  factory BrandModel.fromJson(Map<String, dynamic> json, int index) {
    return BrandModel(
      name: json['brand'] ?? '',
      fileIndex: index,
    );
  }
}

class IrCodeModel {
  final String id;
  final String? power;
  final String? volUp;
  final String? volDown;
  final String? chanUp;
  final String? chanDown;
  final String? mute;
  final String? menu;
  final String? exit;
  final String? up;
  final String? down;
  final String? left;
  final String? right;
  final String? ok;
  final String? back;
  final String? num0;
  final String? num1;
  final String? num2;
  final String? num3;
  final String? num4;
  final String? num5;
  final String? num6;
  final String? num7;
  final String? num8;
  final String? num9;
  final String? play;
  final String? pause;
  final String? stop;
  final String? rewind;
  final String? forward;
  final String? record;
  final String? guide;
  final String? info;
  final String? red;
  final String? green;
  final String? yellow;
  final String? blue;

  IrCodeModel({
    required this.id,
    this.power, this.volUp, this.volDown,
    this.chanUp, this.chanDown, this.mute,
    this.menu, this.exit, this.up, this.down,
    this.left, this.right, this.ok, this.back,
    this.num0, this.num1, this.num2, this.num3,
    this.num4, this.num5, this.num6, this.num7,
    this.num8, this.num9, this.play, this.pause,
    this.stop, this.rewind, this.forward,
    this.record, this.guide, this.info,
    this.red, this.green, this.yellow, this.blue,
  });

  factory IrCodeModel.fromJson(Map<String, dynamic> json) {
    return IrCodeModel(
      id: json['id'] ?? '',
      power: json['power'],
      volUp: json['volUp'],
      volDown: json['volDown'],
      chanUp: json['chanUp'],
      chanDown: json['chanDown'],
      mute: json['mute'],
      menu: json['menu'],
      exit: json['exit'],
      up: json['up'],
      down: json['down'],
      left: json['left'],
      right: json['right'],
      ok: json['ok'],
      back: json['back'],
      num0: json['num0'],
      num1: json['num1'],
      num2: json['num2'],
      num3: json['num3'],
      num4: json['num4'],
      num5: json['num5'],
      num6: json['num6'],
      num7: json['num7'],
      num8: json['num8'],
      num9: json['num9'],
      play: json['play'],
      pause: json['pause'],
      stop: json['stop'],
      rewind: json['rewind'],
      forward: json['fastforward'] ?? json['forward'],
      record: json['record'],
      guide: json['guide'],
      info: json['info'],
      red: json['red'],
      green: json['green'],
      yellow: json['yellow'],
      blue: json['blue'],
    );
  }

  List<int> parseIrCode(String? code) {
    if (code == null || code.isEmpty) return [];
    return code.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }
}
