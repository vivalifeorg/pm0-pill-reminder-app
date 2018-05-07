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


struct Dosage:Codable,Equatable{
  var name:String = "Drug"
  var unitDescription:String?
  var form:String?
  var quantity:String?

  var description:String{
    return "\(name), \(quantity ?? "1" ) of\(unitDescription.spaceBeforeOrEmpty) \(form ?? "UNITS")"
  }
  var schedule:Schedule
  var shortName:String{
    return name
  }
}

func ==(lhs:Dosage, rhs:Dosage)->Bool{
  return lhs.name == rhs.name &&
    lhs.unitDescription == rhs.unitDescription &&
   lhs.form == rhs.form &&
  lhs.quantity == rhs.quantity &&
  lhs.schedule == rhs.schedule
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
  var form:String?
  var unitDescription:String?
  var quantityOfUnits:String?
  var scheduleSelection:Schedule? 
  var prescribingDoctor:String?
  var pharmacy:String?
  var condition:String?
  var drugDBSelection:MedicationPackage?
  var prescription:Prescription{
    return Prescription(info:self)
  }
}


struct Prescription:Codable{
  var dosage:Dosage?
  var prescriber:Prescriber?
  var obtainedFrom:MedicationSource?
  var conditionPrescribedFor:Condition?
  var editInfo:EntryInfo
  let itemRef:UUID = UUID()
  

  init(info:EntryInfo){
    editInfo = info
    dosage = Dosage(name: info.name ?? "Drug",
                        unitDescription: info.unitDescription,
                        form: info.form,
                        quantity: info.quantityOfUnits,
                        schedule: info.scheduleSelection!)
    prescriber = nil
    obtainedFrom = nil
    conditionPrescribedFor = nil
  }
}


///Doctors

struct Address:Codable{
  var street:String
  var streetCont:String
  var city:String
  var state:String
  var ZIP:String
}


struct PatientInfo:Codable{
  var lastDocumentName:String = "" //last name the user put on a document (transgender complexities/recent name changes make this important to track).
  var contactPhoneNumber:String = ""
}

extension String {

  var digitsOnly: String {
    //todo: handle # and *
    let filtered = self.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
    return filtered
  }
}
struct PhoneNumber:Codable{
  var number:String
  var telURL:URL?{
    let url = URL(string:"tel://\(number.digitsOnly)")
    return url
  }
}

struct FaxNumber:Codable{
  var number:String
}

struct DoctorInfo:Codable{
  var name:String
  var specialty:String
  var address:Address
  var fax:FaxNumber
  var phone:PhoneNumber
}

extension DoctorInfo{
  ///Default blank
  init(){
    name = ""
    specialty = ""
    address = Address(street: "", streetCont: "", city: "", state: "", ZIP: "")
    fax = FaxNumber(number:"")
    phone = PhoneNumber(number:"")
  }
}

///End doctors
