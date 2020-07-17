import Flutter
import UIKit
import HealthKit

public class SwiftPgsHealthPlugin: NSObject, FlutterPlugin {
  private let TAG = "FitKit";
  private let TAG_UNSUPPORTED = "unsupported";
  private var healthStore: HKHealthStore? = nil;
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pgs_health_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftPgsHealthPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    guard HKHealthStore.isHealthDataAvailable() else {
        result(FlutterError(code: TAG, message: "Not supported", details: nil))
        return
    }

    if (healthStore == nil) {
        healthStore = HKHealthStore();
    }
   
    do {
        if (call.method == "hasPermissions") {
            let request = try PermissionsRequest.fromCall(call: call)
            hasPermissions(request: request, result: result)
        } else if (call.method == "requestPermissions") {
            let request = try PermissionsRequest.fromCall(call: call)
            requestPermissions(request: request, result: result)
        } else if (call.method == "revokePermissions") {
            revokePermissions(result: result)
        } else if (call.method == "read") {
            let request = try ReadRequest.fromCall(call: call)
            read(request: request, result: result)
        } else if (call.method == "readStats") {
            let request = try ReadStatsRequest.fromCall(call: call)
            readStats(request: request, result: result)
        }else if (call.method == "readCategory") {
            let request = try ReadCategoryRequest.fromCall(call: call)
            readCategory(request: request, result: result)
        }else {
            result(FlutterMethodNotImplemented)
        }
    } catch let error as UnsupportedError {
        result(FlutterError(code: TAG_UNSUPPORTED, message: error.message, details: nil))
    } catch {
        result(FlutterError(code: TAG, message: "\(error)", details: nil))
    }
  }
    
    private func revokePermissions(result: @escaping FlutterResult) {
        result(nil)
    }
    
    private func readCategory(request: ReadCategoryRequest, result: @escaping FlutterResult){
        print("readCategory: \(request.categoryTypeIdentifier)")
        
        guard let type = HKObjectType.categoryType(forIdentifier: request.categoryTypeIdentifier) else{
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictStartDate)
        
        // Sort if needed
        //let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierEndDate,ascending: false)
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: nil) { (query, res, error) in
            
            guard let samples = res else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error.debugDescription))
                return
            }
            
            result(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: request.unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true,
                    "type": request.categoryTypeIdentifier
                ]
            })
            
        }
        
        healthStore!.execute(query)
        
        
    }
    
    private func readStats(request: ReadStatsRequest, result: @escaping FlutterResult){
        print("readStats: \(request.quantityTypeIdentifier)")
        
        let type = HKSampleType.quantityType(forIdentifier: request.quantityTypeIdentifier)
        
        let calendar = NSCalendar.current
        let interval = NSDateComponents()
        interval.day = request.interval
        
        var anchorComponents = calendar.dateComponents([.day , .month , .year], from: NSDate() as Date)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)

        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval as DateComponents)
        
        query.initialResultsHandler = {query, res, error in
            
            guard res != nil else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error.debugDescription))
                return
            }
            
            
            let endDate = request.dateTo //Date()
            let startDate = request.dateFrom// calendar.date(byAdding: .day, value: 0, to: endDate)
            if let myResults = res{
                var mapArray = [Dictionary<String,Any>]()
                
                
                myResults.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                    if let quantity = statistics.sumQuantity(){
                        let date = statistics.startDate
                        let value = quantity.doubleValue(for: request.unit)
                        //print("\(date): steps = \(value)")
            
                        mapArray.append([
                            "value" : value,
                            "date_from": Int(statistics.startDate.timeIntervalSince1970 * 1000),
                            "date_to": Int(statistics.endDate.timeIntervalSince1970 * 1000),
                            "type": request.quantityTypeIdentifier
                        ])
                        
                    }
                }
                
                result(mapArray)
            }
        }
        
        healthStore!.execute(query)
       
    }

    private func read(request: ReadRequest, result: @escaping FlutterResult) {
 
        requestAuthorization(sampleTypes: [request.sampleType]) { success, error in
            guard success else {
                result(error)
                return
            }

            self.readSample(request: request, result: result)
        }
    }
    
    private func readSample(request: ReadRequest, result: @escaping FlutterResult) {
        print("readSample: \(request.type)")

        let predicate = HKQuery.predicateForSamples(withStart: request.dateFrom, end: request.dateTo, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: request.limit == nil)

        let query = HKSampleQuery(sampleType: request.sampleType, predicate: predicate, limit: request.limit ?? HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in

            guard var samples = samplesOrNil else {
                result(FlutterError(code: self.TAG, message: "Results are null", details: error.debugDescription))
                return
            }

            if (request.limit != nil) {
                // if limit is used sort back to ascending
                samples = samples.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
            }

            //print(samples)
            result(samples.map { sample -> NSDictionary in
                [
                    "value": self.readValue(sample: sample, unit: request.unit),
                    "date_from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "date_to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                    "source": self.readSource(sample: sample),
                    "user_entered": sample.metadata?[HKMetadataKeyWasUserEntered] as? Bool == true,
                    "type": request.type
                ]
            })
        }
        healthStore!.execute(query)
    }
    
    private func readValue(sample: HKSample, unit: HKUnit) -> Any {
           if let sample = sample as? HKQuantitySample {
               return sample.quantity.doubleValue(for: unit)
           } else if let sample = sample as? HKCategorySample {
               return sample.value
           }

           return -1
       }

       private func readSource(sample: HKSample) -> String {
           if #available(iOS 9, *) {
               return sample.sourceRevision.source.name;
           }

           return sample.source.name;
       }
    
    private func hasPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            healthStore!.getRequestStatusForAuthorization(toShare: [], read: Set(request.sampleTypes)) { (status, error) in
                guard error == nil else {
                    result(FlutterError(code: self.TAG, message: "hasPermissions", details: error.debugDescription))
                    return
                }

                guard status == HKAuthorizationRequestStatus.unnecessary else {
                    result(false)
                    return
                }

                result(true)
            }
        } else {
            let authorized = request.sampleTypes.map {
                        healthStore!.authorizationStatus(for: $0)
                    }
                    .allSatisfy {
                        $0 != HKAuthorizationStatus.notDetermined
                    }
            result(authorized)
        }
    }

    private func requestPermissions(request: PermissionsRequest, result: @escaping FlutterResult) {
        requestAuthorization(sampleTypes: request.sampleTypes) { success, error in
            guard success else {
                result(false)
                return
            }

            result(true)
        }
    }
    
    private func requestAuthorization(sampleTypes: Array<HKSampleType>, completion: @escaping (Bool, FlutterError?) -> Void) {
        healthStore!.requestAuthorization(toShare: nil, read: Set(sampleTypes)) { (success, error) in
            guard success else {
                completion(false, FlutterError(code: self.TAG, message: "requestAuthorization", details: error.debugDescription))
                return
            }

            completion(true, nil)
        }
    }
    

    private func readSampleStatistic(request:ReadRequest, completion: @escaping(_ stepRetrieved: Double) -> Void) {

        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)

        let calendar = NSCalendar.current
        let interval = NSDateComponents()
        interval.day = 1

        var anchorComponents = calendar.dateComponents([.day , .month , .year], from: NSDate() as Date)
        anchorComponents.hour = 0
        let anchorDate = calendar.date(from: anchorComponents)

        let stepsQuery = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate!, intervalComponents: interval as DateComponents)

        stepsQuery.initialResultsHandler = {query, results, error in
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: 0, to: endDate)
            if let myResults = results{
                
                myResults.enumerateStatistics(from: startDate!, to: endDate) { statistics, stop in
                    
                    if let quantity = statistics.sumQuantity(){
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        print("\(date): steps = \(steps)")
                        completion(steps)
                    }
                }
            }
        }
        
        healthStore!.execute(stepsQuery)
    }
}



    
    
//    let calendar = NSCalendar.current
//    let endDate = Date()
//
//    guard let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) else {
//        fatalError("*** Unable to create the start date ***")
//    }
//
//    let units: Set<Calendar.Component> = [.day, .month, .year, .era]
//
//    var startDateComponents = calendar.dateComponents(units, from: startDate)
//    startDateComponents.calendar = calendar
//
//    var endDateComponents = calendar.dateComponents(units, from: endDate)
//    endDateComponents.calendar = calendar
//
//    // Create the predicate for the query
//    if #available(iOS 9.3, *) {
//        let summariesWithinRange = HKQuery.predicate(forActivitySummariesBetweenStart: startDateComponents,
//                                                     end: endDateComponents)
//
//        if #available(iOS 9.3, *) {
//            let query = HKActivitySummaryQuery(predicate: summariesWithinRange) { (query, summariesOrNil, errorOrNil) -> Void in
//
//                guard let summaries = summariesOrNil else {
//                    // Handle any errors here.
//                    return
//                }
//
//                for summary in summaries {
//                    // Process each summary here.
//                    print(summary)
//                }
//
//                // The results come back on an anonymous background queue.
//                // Dispatch to the main queue before modifying the UI.
//
//                DispatchQueue.main.async {
//                    // Update the UI here.
//                }
//            }
//
//             healthStore!.execute(query)
//        } else {
//            // Fallback on earlier versions
//        }
//
//    } else {
//        // Fallback on earlier versions
//    }
//
    // 410 ,  2748,  3014
    
    
   
    
    /////////////////////////////////////////
