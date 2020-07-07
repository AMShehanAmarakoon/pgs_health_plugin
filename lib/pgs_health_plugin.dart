import 'dart:async';

import 'package:flutter/services.dart';

class PgsHealthPlugin {
  static const MethodChannel _channel =
      const MethodChannel('pgs_health_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> requestPermissions(List<DataType> types) async {
    return await _channel.invokeMethod('requestPermissions', {
      "types": types.map((type) => _dataTypeToString(type)).toList(),
    });
  }

  static Future<List<HealthData>> read(
    DataType type, {
    DateTime dateFrom,
    DateTime dateTo,
    int limit,
  }) async {
    return await _channel
        .invokeListMethod('read', {
          "type": _dataTypeToString(type),
          "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
          "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
          "limit": limit,
        })
        .then(
          (response) =>
              response.map((item) => HealthData.fromJson(item)).toList(),
        )
        .catchError(
          (_) => throw UnsupportedException(type),
          test: (e) {
            if (e is PlatformException) return e.code == 'unsupported';
            return false;
          },
        );
  }

  static Future<HealthData> readLast(DataType type) async {
    return await read(type, limit: 1)
        .then((results) => results.isEmpty ? null : results[0]);
  }

  static String _dataTypeToString(DataType type) {
    switch (type) {
      case DataType.HEART_RATE:
        return "heart_rate";
      case DataType.STEP_COUNT:
        return "step_count";
      case DataType.HEIGHT:
        return "height";
      case DataType.WEIGHT:
        return "weight";
      case DataType.DISTANCE:
        return "distance";
      case DataType.ENERGY:
        return "energy";
      case DataType.WATER:
        return "water";
      case DataType.SLEEP:
        return "sleep";
//      case DataType.STAND_TIME:
//        return "stand_time";
      case DataType.EXERCISE_TIME:
        return "exercise_time";
      case DataType.BLOOD_SUGAR:
        return "blood_sugar";
      case DataType.BLOOD_SUGAR:
        return "blood_sugar";
      case DataType.MINDFULNESS:
        return "mindfulness";
    }
    throw Exception('dataType $type not supported');
  }
}

enum DataType {
  BLOOD_SUGAR,
  HEART_RATE,
  STEP_COUNT,
  HEIGHT,
  WEIGHT,
  DISTANCE,
  ENERGY,
  WATER,
  SLEEP,
  //STAND_TIME,
  EXERCISE_TIME,
  MINDFULNESS
}

class UnsupportedException implements Exception {
  final DataType dataType;
  UnsupportedException(this.dataType);

  @override
  String toString() => 'UnsupportedException: dataType $dataType not supported';
}

class HealthData {
  final num value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String source;
  final bool userEntered;

  HealthData(
    this.value,
    this.dateFrom,
    this.dateTo,
    this.source,
    this.userEntered,
  );

  HealthData.fromJson(Map<dynamic, dynamic> json)
      : value = json['value'],
        dateFrom = DateTime.fromMillisecondsSinceEpoch(json['date_from']),
        dateTo = DateTime.fromMillisecondsSinceEpoch(json['date_to']),
        source = json['source'],
        userEntered = json['user_entered'];

  @override
  String toString() =>
      'FitData(value: $value, dateFrom: $dateFrom, dateTo: $dateTo, source: $source, userEntered: $userEntered)';
}
