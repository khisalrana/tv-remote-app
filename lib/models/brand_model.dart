class BrandModel {
  final String name;
  final int fileIndex;

  BrandModel({required this.name, required this.fileIndex});

  factory BrandModel.fromJson(Map<String, dynamic> json, int index) {
    return BrandModel(name: json['brand'] ?? '', fileIndex: index);
  }
}

class IrCodeModel {
  final String id;
  final String? power, volUp, volDown, chanUp, chanDown, mute;
  final String? menu, exit, up, down, left, right, ok, back;
  final String? num0, num1, num2, num3, num4, num5, num6, num7, num8, num9;
  final String? play, pause, stop, rewind, forward;
  final String? red, green, yellow, blue, info, guide;
  final String? threeD, chlist, sleep, smart;

  IrCodeModel({
    required this.id,
    this.power, this.volUp, this.volDown, this.chanUp, this.chanDown, this.mute,
    this.menu, this.exit, this.up, this.down, this.left, this.right, this.ok, this.back,
    this.num0, this.num1, this.num2, this.num3, this.num4,
    this.num5, this.num6, this.num7, this.num8, this.num9,
    this.play, this.pause, this.stop, this.rewind, this.forward,
    this.red, this.green, this.yellow, this.blue, this.info, this.guide,
    this.threeD, this.chlist, this.sleep, this.smart,
  });

  factory IrCodeModel.fromJson(Map<String, dynamic> json) {
    return IrCodeModel(
      id: json['id'] ?? '',
      power: json['power'], volUp: json['volUp'], volDown: json['volDown'],
      chanUp: json['chanUp'], chanDown: json['chanDown'], mute: json['mute'],
      menu: json['menu'], exit: json['exit'], up: json['up'], down: json['down'],
      left: json['left'], right: json['right'], ok: json['ok'], back: json['back'],
      num0: json['num0'], num1: json['num1'], num2: json['num2'],
      num3: json['num3'], num4: json['num4'], num5: json['num5'],
      num6: json['num6'], num7: json['num7'], num8: json['num8'], num9: json['num9'],
      play: json['play'], pause: json['pause'], stop: json['stop'],
      rewind: json['rewind'], forward: json['fastforward'] ?? json['forward'],
      red: json['red'], green: json['green'], yellow: json['yellow'],
      blue: json['blue'], info: json['info'], guide: json['guide'],
      threeD: json['3d'], chlist: json['chlist'],
      sleep: json['sleep'], smart: json['smart'],
    );
  }

  List<int> parseIrCode(String? code) {
    if (code == null || code.isEmpty) return [];
    return code.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }
}
