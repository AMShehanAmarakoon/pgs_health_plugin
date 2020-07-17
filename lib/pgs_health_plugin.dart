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

  static Future<List<HealthData>> readStats(
    DataType type, {
    DateTime dateFrom,
    DateTime dateTo,
    int interval,
  }) async {
    return await _channel
        .invokeListMethod('readStats', {
          "quantityTypeIdentifier": _dataTypeToString(type),
          "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
          "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
          "interval": interval,
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

  static Future<List<HealthData>> readCategory(
    DataType type, {
    DateTime dateFrom,
    DateTime dateTo,
    int interval,
  }) async {
    return await _channel
        .invokeListMethod('readCategory', {
          "categoryTypeIdentifier": _dataTypeToString(type),
          "date_from": dateFrom?.millisecondsSinceEpoch ?? 1,
          "date_to": (dateTo ?? DateTime.now()).millisecondsSinceEpoch,
          "interval": interval,
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

  static getAvailableSources() async {
    final results = await PgsHealthPlugin.read(
      DataType.STEP_COUNT,
      dateFrom: DateTime.now().subtract(Duration(days: 2)),
      dateTo: DateTime.now(),
    );

    List<String> sourceNameList = [];
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
      case DataType.BLOOD_PRESSURE_SYSTOLIC:
        return "blood_pressure_systolic";
      case DataType.BLOOD_PRESSURE_DIASTOLIC:
        return "blood_pressure_diastolic";
      case DataType.MINDFULNESS:
        return "mindfulness";
      case DataType.BLOOD_OXYGEN:
        return "blood_oxygen";
      case DataType.ACTIVE_ENERGY_BURNED:
        return "active_energy_burned";
    }
    throw Exception('dataType $type not supported');
  }
}

enum DataType {
  BLOOD_SUGAR,
  BLOOD_PRESSURE_SYSTOLIC,
  BLOOD_PRESSURE_DIASTOLIC,
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
  MINDFULNESS,
  BLOOD_OXYGEN,
  ACTIVE_ENERGY_BURNED
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
  final String type;

  HealthData(
    this.value,
    this.dateFrom,
    this.dateTo,
    this.source,
    this.userEntered,
    this.type,
  );

  HealthData.fromJson(Map<dynamic, dynamic> json)
      : value = json['value'],
        dateFrom = DateTime.fromMillisecondsSinceEpoch(json['date_from']),
        dateTo = DateTime.fromMillisecondsSinceEpoch(json['date_to']),
        source = json['source'],
        userEntered = json['user_entered'],
        type = json['type'];

  @override
  String toString() =>
      'FitData(value: $value, dateFrom: $dateFrom, dateTo: $dateTo, source: $source, userEntered: $userEntered, type: $type)';
}
