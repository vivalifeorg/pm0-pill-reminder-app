//
//  models.swift
//  pm0
//
//  Created by Michael Langford on 3/5/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


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

struct Dosage:Codable{
  var name:String = "Drug"
  var unitDescription:String?
  var form:String?
  var quantity:Int
  var description:String{
    return "\(name): \(quantity) × \(unitDescription ?? form ?? "dose")"
  }
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

struct EntryInfo:Codable{
  var name:String?
  var unitDescription:String?
  var quantityOfUnits:String?
  var schedule:String?
  var scheduleSelection:[TemporalEvent]
  var prescribingDoctor:String?
  var pharmacy:String?
  var condition:String?
  var drugDBSelection:MedicationPackage?
}
extension EntryInfo{
  init(){
    self.init(name:nil,
              unitDescription:nil,
              quantityOfUnits:nil,
              schedule:nil,
              scheduleSelection:[],prescribingDoctor:nil,pharmacy:nil,condition:nil,drugDBSelection:nil)
  }
}

struct Prescription:Codable{
  var dosage:Dosage?
  var prescriber:Prescriber?
  var obtainedFrom:MedicationSource?
  var conditionPrescribedFor:Condition?
  var editInfo:EntryInfo

  init(info:EntryInfo){
    editInfo = info
    dosage = Dosage(name: info.name ?? "Drug",
                        unitDescription: info.unitDescription,
                        form: "[PILL]",
                        quantity: Int(info.quantityOfUnits ?? "") ?? 1,
                        events: info.scheduleSelection)
    prescriber = nil
    obtainedFrom = nil
    conditionPrescribedFor = nil
  }
}
