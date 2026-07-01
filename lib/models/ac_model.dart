class AcCodeModel {
  final String id;
  final String protocol; // e.g. 'haier_hsu07' (dynamic encoder), or 'static'
  final String? power, tempUp, tempDown, mode, fanSpeed, swing, timer;

  AcCodeModel({
    required this.id,
    this.protocol = 'static',
    this.power,
    this.tempUp,
    this.tempDown,
    this.mode,
    this.fanSpeed,
    this.swing,
    this.timer,
  });

  factory AcCodeModel.fromJson(Map<String, dynamic> json) {
    return AcCodeModel(
      id: json['id'] ?? '',
      protocol: json['protocol'] ?? 'static',
      power: json['power'],
      tempUp: json['tempUp'],
      tempDown: json['tempDown'],
      mode: json['mode'],
      fanSpeed: json['fanSpeed'],
      swing: json['swing'],
      timer: json['timer'],
    );
  }

  List<int> parseIrCode(String? code) {
    if (code == null || code.isEmpty) return [];
    return code.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
  }
}
