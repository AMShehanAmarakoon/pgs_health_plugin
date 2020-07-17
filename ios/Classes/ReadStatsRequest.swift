//
//  ReadStatsRequest.swift
//  pgs_health_plugin
//
//  Created by Shehan Amarakoon on 7/13/20.
//

import HealthKit

class ReadStatsRequest {
    let quantityTypeIdentifier: HKQuantityTypeIdentifier
    let unit:HKUnit
    let dateFrom: Date
    let dateTo: Date
    let interval:Int
    
    private init(quantityTypeIdentifier: HKQuantityTypeIdentifier, unit:HKUnit ,dateFrom: Date, dateTo: Date, interval: Int?) {
        self.quantityTypeIdentifier = quantityTypeIdentifier
        self.unit = unit
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.interval = interval ?? 1
    }
    
    static func fromCall(call: FlutterMethodCall) throws -> ReadStatsRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let quantityTypeIdentifier = arguments["quantityTypeIdentifier"] as? String,
              let dateFromEpoch = arguments["date_from"] as? NSNumber,
              let dateToEpoch = arguments["date_to"] as? NSNumber,
              let interval = arguments["interval"] as? Int else {
                throw "invalid call arguments \(call.arguments ?? "nil arguments")";
        }
        
        
        guard let values = HKQuantityTypeIdentifier.fromDartType(type: quantityTypeIdentifier),
              let sampleType = values.sampleType as? HKQuantityTypeIdentifier,
              let unit = values.unit as? HKUnit else {
            throw UnsupportedError(message: "type \(quantityTypeIdentifier) is not supported");
        }

        
        let dateFrom = Date(timeIntervalSince1970: dateFromEpoch.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: dateToEpoch.doubleValue / 1000)

        return ReadStatsRequest(quantityTypeIdentifier: sampleType,unit: unit, dateFrom: dateFrom, dateTo: dateTo, interval: interval)
    }
}
