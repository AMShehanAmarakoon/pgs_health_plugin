//
//  Extentions.swift
//  pgs_health_plugin
//
//  Created by Shehan Amarakoon on 7/7/20.
//

import HealthKit

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
extension HKCategoryTypeIdentifier {
    public static func fromDartType(type:String) ->  (sampleType:HKCategoryTypeIdentifier?,unit:HKUnit)?{
        switch type {
        case "sleep":
            return (HKCategoryTypeIdentifier.sleepAnalysis, HKUnit.minute())
        case "mindfulness":
            if #available(iOS 10.0, *) {
                return (HKCategoryTypeIdentifier.mindfulSession, HKUnit.minute())
            } else {
                return nil
            }
        default:
            return nil
        }
        
    }
}
extension HKQuantityTypeIdentifier {
    public static func fromDartType(type:String) ->  (sampleType:HKQuantityTypeIdentifier?,unit:HKUnit)?{
        switch type {
        case "step_count":
            return (HKQuantityTypeIdentifier.stepCount, HKUnit.count())
        case "water":
            if #available(iOS 9.0, *) {
                return (HKQuantityTypeIdentifier.dietaryWater, HKUnit.fluidOunceUS())
            } else {
                return nil
            }
        default:
            return nil
        }
        
    }
}

extension HKSampleType {
    public static func fromDartType(type: String) -> (sampleType: HKSampleType?, unit: HKUnit)? {
        switch type {
        case "heart_rate":
            return (
                    HKSampleType.quantityType(forIdentifier: .heartRate),
                    HKUnit.init(from: "count/min")
            )
        case "blood_pressure_systolic":
            return (
                    HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic),
                    HKUnit.millimeterOfMercury()
            )
        case "blood_pressure_diastolic":
            return (
                    HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic),
                    HKUnit.millimeterOfMercury()
            )
        case "blood_oxygen":
            return (
                    HKSampleType.quantityType(forIdentifier: .oxygenSaturation),
                    HKUnit.percent()
            )
        case "water":
            if #available(iOS 9, *) {
                return (
                    HKSampleType.quantityType(forIdentifier: .dietaryWater),
                    HKUnit.fluidOunceUS()
                )
            } else {
                return nil
            }
        case "active_energy_burned":
            return (
                    HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
                    HKUnit.kilocalorie()
            )
        case "step_count":
            return (
                    HKSampleType.quantityType(forIdentifier: .stepCount),
                    HKUnit.count()
            )
        case "stand_time":
            if #available(iOS 13.0, *) {
                return (
                        HKSampleType.quantityType(forIdentifier: .appleStandTime),
                        HKUnit.minute()
                )
            } else {
                return nil
            }
        case "exercise_time":
            if #available(iOS 9.3, *) {
                return (
                        HKSampleType.quantityType(forIdentifier: .appleExerciseTime),
                        HKUnit.minute()
                )
            } else {
                return nil
            }
        case "height":
            return (
                    HKSampleType.quantityType(forIdentifier: .height),
                    HKUnit.meter()
            )
        case "weight":
            return (
                    HKSampleType.quantityType(forIdentifier: .bodyMass),
                    HKUnit.gramUnit(with: .kilo)
            )
        case "distance":
            return (
                    HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
                    HKUnit.meter()
            )
        case "energy":
            return (
                    HKSampleType.quantityType(forIdentifier: .activeEnergyBurned),
                    HKUnit.kilocalorie()
            )
        
        case "sleep":
            return (
                    HKSampleType.categoryType(forIdentifier: .sleepAnalysis),
                    HKUnit.minute() // this is ignored
            )
        case "blood_sugar":
                   return (
                    HKSampleType.quantityType(forIdentifier: .bloodGlucose),
                    HKUnit.init(from: "mg/dl")
                   )
        case "mindfulness":
            if #available(iOS 10, *) {
                return (
                       HKSampleType.categoryType(forIdentifier: .mindfulSession),
                       HKUnit.minute()
                )
            } else {
                return nil
            }
           
        default:
            return nil
        }
    }
}

public struct UnsupportedError: Error {
    let message: String
}
