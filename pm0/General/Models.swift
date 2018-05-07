//
//  models.swift
//  pm0
//
//  Created by Michael Langford on 3/5/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation


///makes it so the prescriber can be saved to a file, clearly, nothing is saved yet
struct Prescriber:Codable{

}


///What they user needs to take of a medicine
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


///Why a user tkaes a medication
struct Condition:Codable{
  var name:String

  var description:String{
    return name
  }
}

///How a user gets a medication, some are from *wierd* places to pick them up
///  Mostly not used yet
struct MedicationSource:Codable{
  var name:String
  var isPharmacy:Bool
  var isHospital:Bool
  var isDoctor:Bool
  var isOverTheCounter:Bool
}


/// Used to record what the person picked, this is saved to make editing a lot easier to recreate. Somewhat duplicates other fields of the prescription datastructure.
struct EntryInfo:Codable{
  var name:String? ///What they typed on the name line
  var form:String? ///what they typed on the pill description line
  var unitDescription:String? ///what they typed on the how much do you take line
  var quantityOfUnits:String? ///how many they take at once
  var scheduleSelection:Schedule?  ///Which schedue they picked
  var prescribingDoctor:String? ///Who told them to take it
  var pharmacy:String? /// where they get it
  var condition:String? ///Why they take it
  var drugDBSelection:MedicationPackage? ///What item out of the drug db they selected, used so we can figure out more about what they chose
  var prescription:Prescription{ ///The item this distills down to elsewhere in the app
    return Prescription(info:self)
  }
}


/// Used to record the item given to the user by their doctor to say how to take a medication
struct Prescription:Codable{
  var dosage:Dosage? ///One use of the medication
  var prescriber:Prescriber? ///Who prescribed it
  var obtainedFrom:MedicationSource? ///Pharmacy or other place of acquisition
  var conditionPrescribedFor:Condition? ///Why they take it
  var editInfo:EntryInfo ///Used to repopulate the entry field when editing
  let itemRef:UUID = UUID() ///Used primarily for logging

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


///Where their doctor is. Clearly US oriented right now
struct Address:Codable{
  var street:String
  var streetCont:String
  var city:String
  var state:String
  var ZIP:String
}


///This is used to store what the user typed as their name
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

///A phone number that is callable most likely
struct PhoneNumber:Codable{
  var number:String
  var telURL:URL?{
    let url = URL(string:"tel://\(number.digitsOnly)")
    return url
  }
}
///A phone number that you can fax to
struct FaxNumber:Codable{
  var number:String
}

///info about a doctor
struct DoctorInfo:Codable{
  var name:String
  var specialty:String ///e.g. Podiatry
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


