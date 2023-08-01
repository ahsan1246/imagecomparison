// To parse this JSON data, do
//
//     final compareImageModel = compareImageModelFromJson(jsonString);

import 'dart:convert';

class CompareImageModel {
  String? result;
  String? percentage;

  CompareImageModel({
    this.result,
    this.percentage,
  });

  factory CompareImageModel.fromRawJson(String str) =>
      CompareImageModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  CompareImageModel.fromJson(Map<String, dynamic> json) {
    try {
      result = '${json["result"]}';
    } catch (e) {
      print('CompareImageModel -> result -> Error => $e');
    }
    try {
      percentage = double.tryParse('${json["similarity"]}')?.toStringAsFixed(1);
    } catch (e) {
      percentage = '0';
      print('CompareImageModel -> percentage -> Error => $e');
    }
  }

  Map<String, dynamic> toJson() => {
        "result": result,
        "similarity": percentage,
      };
}
