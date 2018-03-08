//
//  models.swift
//  pm0
//
//  Created by Michael Langford on 3/5/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation

var global_allDrugs:[Dosage] = []


struct DosingSchedule{
  var periodLength:Int
  var dosesPerPeriod:Int
  var isWakeToTake:Bool = false
  var isOnlyForConsumptionWithFood:Bool = false
}

struct Prescriber:Codable{

}

struct DosageForm:Codable{

}

struct TakeTime{
  var hour:Int
  var minute:Int
  var timeName:String?
}

struct Potency{

}

struct Dosage:Codable{
  var name:String
  var form:String?
  var events:[TemporalEvent]
  var shortName:String{
    return name
  }

  func timesTaken(for:Date)->[TakeTime]{
    return events.map{
      TakeTime(hour:$0.hourOffset,
               minute:$0.minuteOffset,
        timeName: $0.name)
    }
  }
}

struct Condition:Codable{
  var name:String

  var description:String{
    return name
  }
}

struct MedicationSource:Codable{
  var name:String
  var isPharmacy:Bool
  var isHospital:Bool
  var isDoctor:Bool
  var isOverTheCounter:Bool
}

struct Prescription:Codable{
  var dosage:Dosage?
  var prescriber:Prescriber?
  var obtainedFrom:MedicationSource?
  var conditionPrescribedFor:Condition?
}
