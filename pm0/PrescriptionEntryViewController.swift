//
//  PrescriptionEntryViewController.swift
//  pm0
//
//  Created by Michael Langford on 1/22/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField


struct DisplayDrug{
  var name:String
  var commonUses:[String]
}

var drugs = [
  DisplayDrug(name:"Aspirin", commonUses:["Pain Relief", "Inflammation Reduction", "Anti-clotting"]),
  DisplayDrug(name:"Lipitor", commonUses:["Cholesterol Control"]),
  DisplayDrug(name:"Advair Diskus", commonUses:["Asthma Attack Prevention"]),
  DisplayDrug(name:"Metformin", commonUses:["Diabetes Treatment"])
]
extension DisplayDrug{
  var searchTextFieldItem:SearchTextFieldItem{
    switch commonUses.count{
    case 0:
    return SearchTextFieldItem(title:name)
    case 1:
    return SearchTextFieldItem(title:name,subtitle:"Common use: \(commonUses.first!)")

    default:
      let appending:(String,String)->String = {orig, next in return "\(orig), \(next)"}
      let subtitle = commonUses.reduce("Common uses: ",appending)
    return SearchTextFieldItem(title:name, subtitle: subtitle)
    }
  }
}

class PrescriptionEntryViewController: UIViewController {

  @IBOutlet weak var medicationNameField:SearchTextField!
  @IBOutlet weak var unitQuantityPerDoseField:SearchTextField!
  @IBOutlet weak var unitDoseField:SearchTextField!
  @IBOutlet weak var whenIsItTakenField:SearchTextField!
  @IBOutlet weak var prescribingDoctorField:SearchTextField!
  @IBOutlet weak var pharmacyField:SearchTextField!
  @IBOutlet weak var conditionField:SearchTextField!



  @IBOutlet weak var medicationNameHelpButton: UIButton!
  @IBOutlet weak var quantityPerDoseHelpButton: UIButton!
  @IBOutlet weak var unitDoseHelpButton: UIButton!
  @IBOutlet weak var conditionHelpButton: UIButton!
  @IBOutlet weak var pharmacyHelpButton: UIButton!
  @IBOutlet weak var prescribingDoctorHelpButton: UIButton!
  @IBOutlet weak var whenTakenHelpButton: UIButton!

  @IBAction func doctorContactAddressButtonTapped(_ sender: Any) {

  }

  @IBAction func pharmacyContactAddressButtonTapped(_ sender: Any) {
  }



  func drugsForText(str:String?)->[DisplayDrug]{
    return drugs
  }

  override func viewDidLoad() {
    let medicationNameSearchItems = drugsForText(str: medicationNameField?.text).map{$0.searchTextFieldItem}
    medicationNameField.filterItems(medicationNameSearchItems)

  }

  var medicationName:String?{
    return medicationNameField?.text
  }
}
