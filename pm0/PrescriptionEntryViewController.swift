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

    let first = commonUses.first
    let rest = commonUses.dropFirst()
    switch (first, rest){

      case (nil, nil):
        return SearchTextFieldItem(title:name)

      case (_,nil):
        return SearchTextFieldItem(title:name,subtitle:"\(first!)")

      default:
        let first = commonUses.first!
        let subtitle = rest.reduce(first,{orig, next in return "\(orig), \(next)"})
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



  var popupBackgroundColor:UIColor{
    return UIColor(red:0.13, green:0.22, blue:0.30, alpha:1.00)
  }

  func drugsForText(str:String?)->[DisplayDrug]{
    return drugs
  }

  func configureSearchField(_ field:SearchTextField){
    field.theme = SearchTextFieldTheme.darkTheme()
    field.theme.font  = UIFont.systemFont(ofSize: 17)
    field.theme.bgColor = popupBackgroundColor
  }

  func configureHeader(_ field:SearchTextField, withText headerText:String){
    let header = UILabel(frame: CGRect(x: 0, y: 0, width: field.frame.width, height: 30))
    header.backgroundColor = UIColor.darkGray.withAlphaComponent(1.0)
    header.textAlignment = .center
    header.font = UIFont.systemFont(ofSize: 14)
    header.text = headerText
    field.resultsListHeader = header
  }

  func updateMedicationSearchItems(){
    let medicationNameSearchItems = drugsForText(str: medicationNameField?.text).map{$0.searchTextFieldItem}
    medicationNameField.filterItems(medicationNameSearchItems)
  }

  override func viewDidLoad() {
    configureSearchField(medicationNameField)
    configureHeader(medicationNameField, withText: "Tap to fill-in name")

    updateMedicationSearchItems()
  }

  var medicationName:String?{
    return medicationNameField?.text
  }
}
