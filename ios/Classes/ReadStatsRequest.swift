//
//  ReadStatsRequest.swift
//  pgs_health_plugin
//
//  Created by Shehan Amarakoon on 7/13/20.
//

import HealthKit

class ReadStatsRequest {
    let quantityTypeIdentifier: HKQuantityTypeIdentifier
    let dateFrom: Date
    let dateTo: Date
    let interval:Int
    
    private init(quantityTypeIdentifier: HKQuantityTypeIdentifier,  dateFrom: Date, dateTo: Date, interval: Int?) {
        self.quantityTypeIdentifier = quantityTypeIdentifier
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
        
        guard let quantityType = HKQuantityTypeIdentifier.fromDartType(type: quantityTypeIdentifier)
            else {
            throw UnsupportedError(message: "type \(quantityTypeIdentifier) is not supported");
        }

        
        let dateFrom = Date(timeIntervalSince1970: dateFromEpoch.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: dateToEpoch.doubleValue / 1000)

        return ReadStatsRequest(quantityTypeIdentifier: quantityType, dateFrom: dateFrom, dateTo: dateTo, interval: interval)
    }
}
