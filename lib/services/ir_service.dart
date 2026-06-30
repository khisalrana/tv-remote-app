import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/brand_model.dart';

class IrService {
  static const MethodChannel _channel = MethodChannel('com.tvremote.app/ir');

  static Future<bool> hasIrBlaster() async {
    try {
      final bool result = await _channel.invokeMethod('hasIrBlaster');
      return result;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendIrCode(List<int> pattern) async {
    if (pattern.isEmpty) return false;
    try {
      await _channel.invokeMethod('transmit', {
        'frequency': 38000,
        'pattern': pattern,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<IrCodeModel?> loadIrCodes(int fileIndex) async {
    try {
      final String data = await rootBundle.loadString(
        'assets/ir_codes/$fileIndex.json'
      );
      final Map<String, dynamic> json = jsonDecode(data);
      return IrCodeModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<List<BrandModel>> loadBrands() async {
    try {
      final String data = await rootBundle.loadString('assets/brands/brand.json');
      final List<dynamic> json = jsonDecode(data);
      return json.asMap().entries
          .map((e) => BrandModel.fromJson(e.value, e.key))
          .toList();
    } catch (e) {
      return [];
    }
  }
}