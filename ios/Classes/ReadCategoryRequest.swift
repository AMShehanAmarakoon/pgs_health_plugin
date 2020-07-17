//
//  ReadCategoryRequest.swift
//  pgs_health_plugin
//
//  Created by Shehan Amarakoon on 7/16/20.
//
//

import HealthKit

class ReadCategoryRequest {
    let categoryTypeIdentifier: HKCategoryTypeIdentifier
    let unit:HKUnit
    let dateFrom: Date
    let dateTo: Date
    let interval:Int
    
    private init(categoryTypeIdentifier: HKCategoryTypeIdentifier, unit:HKUnit ,dateFrom: Date, dateTo: Date, interval: Int?) {
        self.categoryTypeIdentifier = categoryTypeIdentifier
        self.unit = unit
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.interval = interval ?? 1
    }
    
    static func fromCall(call: FlutterMethodCall) throws -> ReadCategoryRequest {
        guard let arguments = call.arguments as? Dictionary<String, Any>,
              let categoryTypeIdentifier = arguments["categoryTypeIdentifier"] as? String,
              let dateFromEpoch = arguments["date_from"] as? NSNumber,
              let dateToEpoch = arguments["date_to"] as? NSNumber,
              let interval = arguments["interval"] as? Int else {
                throw "invalid call arguments \(call.arguments ?? "nil arguments")";
        }
        
        
        guard let values = HKCategoryTypeIdentifier.fromDartType(type: categoryTypeIdentifier),
              let sampleType = values.sampleType as? HKCategoryTypeIdentifier,
              let unit = values.unit as? HKUnit else {
            throw UnsupportedError(message: "type \(categoryTypeIdentifier) is not supported");
        }

        
        let dateFrom = Date(timeIntervalSince1970: dateFromEpoch.doubleValue / 1000)
        let dateTo = Date(timeIntervalSince1970: dateToEpoch.doubleValue / 1000)
           
        return ReadCategoryRequest(categoryTypeIdentifier: sampleType, unit: unit, dateFrom: dateFrom, dateTo: dateTo, interval: interval)
        
    
    }
}

