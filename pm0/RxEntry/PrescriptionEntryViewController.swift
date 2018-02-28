//
//  PrescriptionEntryViewController.swift
//  pm0
//
//  Created by Michael Langford on 1/22/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField

protocol Listable{
  var title:String {get}
  var list:[String] {get}
  var pluralPrefix:String {get}
  var singularPrefix:String {get}
}

extension Listable{
  var pluralPrefix:String{
    return ""
  }
  var singularPrefix:String{
    return ""
  }
}

extension SearchTextFieldItem{
  convenience init(listable:Listable){
    let first = listable.list.first
    let rest = listable.list.dropFirst()
    let pluralPrefix = listable.pluralPrefix
    let singularPrefix = listable.singularPrefix

    switch (first, rest){

    case (nil, nil):
      self.init(title:listable.title)

    case (_,nil):
      self.init(title:listable.title,subtitle:"\(singularPrefix)\(first!)")

    default:
      let first = first ?? ""
      let subtitle = rest.reduce(first,{orig, next in return "\(pluralPrefix)\(orig), \(next)"})
      self.init(title:listable.title, subtitle: subtitle)
    }
  }
}




extension DisplayDrug:Listable{

  /*
   let form = dosageForm != "" ?  "(\(dosageForm))" : ""
   let dosage = "\(numerator ?? "") \(unit ?? ""): "
   let altDosage = ""
   let prefix = (numerator == "" && unit == "") ? altDosage : dosage

   self.init(name: "\(item["PROPRIETARYNAME"] ?? "") \(form)",
   commonUses: [prefix + nonProp ],
   unit:unit,
   form:form,
   numerator:numerator)
 */
  var title:String{
    let formattedForm = dosageForm.flatMap{ df in
      df != "" ?  "(\(df))" : ""
    }

    return "\(name) \(formattedForm ?? "")"
  }

  var list:[String]{
    let dosage = "\(activeStrength ?? "") \(unit ?? ""): "
    let altDosage = ""
    let prefix = (activeStrength == "" && unit == "") ? altDosage : dosage

    return [prefix+nonPropName]
  }
}


var doctors = [
  DisplayDoctor(name:"Andy Lindorn, MD", specialities:["Podiatry, Orthopedics"]),
  DisplayDoctor(name:"Rena Patel, MD", specialities:["Hemophilia, Bone Cancer"]),
  DisplayDoctor(name:"James Jodi, NP", specialities:["General Care"])
]

struct DisplaySchedule{
  var name:String
  var examples:[String]
}

extension DisplaySchedule:Listable{
  var title:String{
    return name
  }

  var list:[String]{
    return examples
  }
}

var schedules = [
  DisplaySchedule(name:"When I wake up in the morning",
                  examples:["Once per day",
                            "Immeadiately upon awakening",
                            "Before breakfast",
                            "First thing"]),
  DisplaySchedule(name:"With Breakfast",
                  examples:["Once a day with food",
                            "Early in the day with food",
                            "First thing in the morning with food"]),
  DisplaySchedule(name:"With Lunch",
                  examples:["Once a day with food",
                            "Early in the day with food",
                            "Avoid taking with alcohol"]),
  DisplaySchedule(name:"With Breakfast and Dinner",
                  examples:["Twice a day with food",
                            "At least 6 hours apart",
                            "At least 4 hours apart"]),
  DisplaySchedule(name:"Custom",
                  examples:["Make my own schedule",
                            "Other",
                            "Something else",
                            "Every other day",
                            "Once a week"," "])
]

struct DisplayDoctor{
  var name:String
  var specialities:[String]
}

extension DisplayDoctor:Listable{
  var title:String{ return name}
  var list:[String] {return specialities}
}


struct DisplayDrug{
  var name:String
  var nonPropName:String
  var unit:String? = nil
  var dosageForm:String? = nil
  var activeStrength:String? = nil
}

extension DisplayDrug{
  init(_ item: [String:String]){
    name = item["PROPRIETARYNAME"] ?? item["NONPROPRIETARYNAME"] ?? ""
    dosageForm = item["DOSAGEFORMNAME"] ?? ""
    nonPropName = item["NONPROPRIETARYNAME"] ?? ""
    activeStrength = item["ACTIVE_NUMERATOR_STRENGTH"]
    unit = item["ACTIVE_INGRED_UNIT"] ?? ""
  }
}

class PrescriptionEntryViewController: UIViewController,UIScrollViewDelegate {

  @IBOutlet weak var medicationNameField:SearchTextField!
  @IBOutlet weak var unitQuantityPerDoseField:SearchTextField!
  @IBOutlet weak var unitDoseField:SearchTextField!
  @IBOutlet weak var whenIsItTakenField:SearchTextField!
  @IBOutlet weak var prescribingDoctorField:SearchTextField!
  @IBOutlet weak var pharmacyField:SearchTextField!
  @IBOutlet weak var conditionField:SearchTextField!


  @IBOutlet weak var pharmacyLine: PrescriptionLineEntry!
  
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

  func pillSizesMatching(name:String, partial:String, completion:@escaping ([SearchTextFieldItem])->()){
    DispatchQueue.global().async {
      let rawMatches:[[String:String]] = pillSizesMatch(name: name, partial: partial)
      let matches:[DisplayDrug] =  rawMatches.map{ item in
        return DisplayDrug(item)
      }

      let numberToKeep = 10000
      let numberToDrop = max(matches.count - numberToKeep, 0)
      let possiblyTruncated = matches.dropLast(numberToDrop)
      debugPrint(rawMatches.first ?? "")
      let listable = possiblyTruncated.map{SearchTextFieldItem(listable:$0)}
      debugPrint("\(listable.count) results for \(name)")
      DispatchQueue.main.async {
        completion(listable)
      }
    }
  }



  func namesMatchingAsync(_ str:String, completion:@escaping ([DisplayDrug])->()){
    DispatchQueue.global().async {
      let rawMatches:[[String:String]] = packagesMatching(str)
      let numberToKeep = 10000
      let numberToDrop = max(rawMatches.count - numberToKeep, 0)
      let truncatedRawMatches = rawMatches.dropLast(numberToDrop)
      let matches:[DisplayDrug] =  truncatedRawMatches.map{ item in
        return DisplayDrug(item)
      }

      DispatchQueue.main.async {
        completion(matches)
      }
    }
  }


  @IBOutlet weak var scrollView: UIScrollView!


  var allSearchFields:[SearchTextField]{
    return [
      medicationNameField,
      unitQuantityPerDoseField,
      unitDoseField,
      whenIsItTakenField,
      prescribingDoctorField,
      pharmacyLine.searchTextField,
      conditionField
    ]
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
    allSearchFields.forEach { (field) in
      field.hideResultsList()
    }
  }

  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    allSearchFields.filter{$0.isFocused}.forEach { (field) in
        field.layoutSubviews()
    }
  }

  let searchMainTextSize = 20.0 as CGFloat

  func configureSearchField(_ field:SearchTextField){
    field.theme = SearchTextFieldTheme.darkTheme()
    field.theme.font  = UIFont.systemFont(ofSize: 20)
    field.theme.cellHeight = 65
    field.theme.bgColor = popupBackgroundColor
    field.highlightAttributes =  [
      NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):
        UIFont.boldSystemFont(ofSize: searchMainTextSize),
      NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):
        VLColors.warmHighlight,
    ]
    field.theme.separatorColor = UIColor.darkGray
    field.tableBottomMargin = 0

    debugPrint("field.tableBottomMargin: \(field.tableBottomMargin)")
  }

  func configureHeader(_ field:SearchTextField, withText headerText:String){
    let header = UILabel(frame: CGRect(x: 0, y: 0, width: field.frame.width, height: 30))
    header.backgroundColor = UIColor.darkGray
    header.textColor = UIColor.white
    header.textAlignment = .center
    header.font = UIFont.systemFont(ofSize: searchMainTextSize-2.0)
    header.text = headerText
    field.resultsListHeader = header
  }

  @objc open func keyboardWillShow(_ notification: Notification) {
   // scrollView.contentInset.bottom = notification.keyboard
  }

  @objc open func keyboardWillHide(_ notification: Notification) {
    /*
    if keyboardIsShowing {
      keyboardIsShowing = false
      direction = .down
      redrawSearchTableView()
    }
 */
  }

  func updatePillSizePopup(){
    self.unitDoseField.showLoadingIndicator()

    let search = medicationNameField.text ?? ""
    let pillSizePartial = unitDoseField.text ?? ""
    guard !search.isEmpty else{
      medicationNameField.filterItems([])
      return
    }

    pillSizesMatching(name: search, partial: pillSizePartial){ medications in
      DispatchQueue.main.async {
        self.unitDoseField?.stopLoadingIndicator()
        self.unitDoseField?.filterItems(medications)
      }
    }
  }

  var namedDrugs:[DisplayDrug] = [] {
    didSet{
      let displayable = namedDrugs.map{SearchTextFieldItem(listable:$0)}
      self.medicationNameField?.filterItems(displayable)
    }
  }

  func updateDrugsPopup(){

    medicationNameField.showLoadingIndicator()

    let search = medicationNameField.text ?? ""
    guard !search.isEmpty else{
      medicationNameField.filterItems([])
      return
    }

    namesMatchingAsync(search){ medications in
      DispatchQueue.main.async {
        self.medicationNameField?.stopLoadingIndicator()
        self.namedDrugs = medications
      }
    }
  }

  var lastSelectedDrug:DisplayDrug?

  func nameItemSelectionHandler(_ filteredResults: [SearchTextFieldItem], _ index: Int) {
    let drugSelection = namedDrugs[index]
    dump(("Drug Selection",drugSelection))

    medicationNameField?.text = drugSelection.name
    unitDoseField?.text = [drugSelection.activeStrength,
                           drugSelection.unit,
                           drugSelection.dosageForm].flatMap{$0}.joined(separator:" ")
    lastSelectedDrug = drugSelection
  }

  override func viewDidLoad() {
    scrollView.delegate = self
/*
    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(keyboardWasShown:)
      name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
      selector:@selector(keyboardWillBeHidden:)
      name:UIKeyboardWillHideNotification object:nil];
    NotificationCenter.default.addObserver(self, selector: keyboardShow, name: "keyboardWillShow", object: <#T##Any?#>)
*/
    configureSearchField(medicationNameField)
    configureHeader(medicationNameField, withText: "Tap to fill-in")

    //updateDrugsPopup()
    medicationNameField.userStoppedTypingHandler = {
      self.updateDrugsPopup()
    }
    medicationNameField.itemSelectionHandler = self.nameItemSelectionHandler


    unitDoseField.userStoppedTypingHandler = {
      self.updatePillSizePopup()
    }

    configureSearchField(prescribingDoctorField)
    configureHeader(prescribingDoctorField, withText: "Type new name or tap existing")
    prescribingDoctorField.filterItems(
      doctors.map{SearchTextFieldItem(listable:$0)})


    configureSearchField(whenIsItTakenField)
    configureHeader(whenIsItTakenField, withText: "Tap one or type 'Custom'")
    whenIsItTakenField.filterItems(
      schedules.map{SearchTextFieldItem(listable:$0)})
  }

  var prescription:DisplayDrug?{
    return lastSelectedDrug
  }

  var medicationName:String?{
    return medicationNameField?.text
  }
}
