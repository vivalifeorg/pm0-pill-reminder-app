//
//  PrescriptionEntryViewController.swift
//  pm0
//
//  Created by Michael Langford on 1/22/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SearchTextField
import Down



struct VLFonts{
  static var body:UIFont{
    return UIFont.preferredFont(forTextStyle: .body)
  }
  static var h1:UIFont{
    return UIFont.preferredFont(forTextStyle: .title1)
  }
  static var h2:UIFont{
    return UIFont.preferredFont(forTextStyle: .title2)
  }
  static var h3:UIFont{
    return UIFont.preferredFont(forTextStyle: .title3)
  }
  static var bold:UIFont{
    return UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
  }
  static var italic:UIFont{
    return UIFont.italicSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
  }
}


let debugMarkdown = false
extension String{
  var renderMarkdownAsAttributedString:NSAttributedString{
    let rendered = Down(markdownString: self) as DownAttributedStringRenderable

    if debugMarkdown {
      debugPrint("--css--")
      debugPrint(RXEntryHelpText.helpTextCSSStylesheet)
      debugPrint("--css -> html--")
      debugPrint(try! rendered.toHTML(DownOptions.default))
      debugPrint("--endhtml---")
    }
    return try! rendered.toAttributedString(
      DownOptions.default,
      stylesheet: RXEntryHelpText.helpTextCSSStylesheet)
  }
}

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
  var title:String{
    let formattedForm = dosageForm.flatMap{ df in
      df != "" ?  "(\(df))" : ""
    }

    return "\(name) \(formattedForm ?? "")"
  }


  var decoratedDUS:String{
    let dosage = "\(activeStrength ?? "") \(unit ?? ""): "
    let altDosage = ""
    return (activeStrength == "" && unit == "") ? altDosage : dosage
  }

  var drugUnitSummary:String?{
    guard activeStrength != nil || unit != nil else {
      return nil
    }
    return "\(activeStrength ?? "") \(unit ?? "")"
  }

  var list:[String]{
    return [decoratedDUS+nonPropName]
  }
}


var doctors = [
  DisplayDoctor(name:"Andy Lindorn, MD", specialities:["Podiatry, Orthopedics"]),
  DisplayDoctor(name:"Rena Patel, MD", specialities:["Hemophilia, Bone Cancer"]),
  DisplayDoctor(name:"James Jodi, NP", specialities:["General Care"])
]

typealias MinuteOffset = Int
typealias HourOffset = Int

struct TemporalEvent:Hashable,Codable{
  var hashValue: Int {
    return "\(name ?? "non-named")\(eventType)".hashValue
  }

  let name:String?

  let eventType:EventType

  var hourOffset:HourOffset {
    return TemporalEvent.timeOffsetsForEvent(self).hour
  }

  var minuteOffset:MinuteOffset {
    return TemporalEvent.timeOffsetsForEvent(self).minute
  }

  //todo fix broken ==
  static func ==(lhs:TemporalEvent, rhs:TemporalEvent) -> Bool{
    return lhs.name == rhs.name &&
      lhs.eventType == rhs.eventType
    //      &&
    //      lhs.hourOffset == rhs.hourOffset &&
    //      lhs.minuteOffset == rhs.minuteOffset
  }

  static func userOverridenTimeOffsetFor(_ event:TemporalEvent) -> (hour:HourOffset,minute:MinuteOffset)?{
    return nil
  }

  static let defaultEventTimes:[TemporalEvent:(HourOffset,MinuteOffset)] = [
    DefaultEvents.wakeUp: (7,30),
    DefaultEvents.breakfast: (8,00),
    DefaultEvents.morningSnack: (10,30),
    DefaultEvents.lunch: (12,00),
    DefaultEvents.afternoonSnack: (14,30),
    DefaultEvents.dinner: (18,00),
    DefaultEvents.bedTime: (22,00)
  ]
  static func timeOffsetsForEvent(_ event:TemporalEvent)->(hour:HourOffset,minute:MinuteOffset){

    return userOverridenTimeOffsetFor(event) ?? defaultEventTimes[event] ?? (9,00)
  }

  init(name:String?, eventType:EventType){
    self.name = name
    self.eventType = eventType
  }
}

enum EventType:String,Codable{
  case meal
  case sleep
  case time
}

enum DefaultEvents{
  static let breakfast = TemporalEvent(name:"Breakfast",
                                       eventType:.meal)

  static let morningSnack = TemporalEvent(name:"Morning Snack",
                                          eventType:.meal)

  static let lunch = TemporalEvent(name:"Lunch",
                                   eventType:.meal)

  static let afternoonSnack = TemporalEvent(name:"Afternoon Snack",
                                            eventType:.meal)

  static let dinner = TemporalEvent(name:"Dinner",
                                    eventType:.meal)

  static let wakeUp = TemporalEvent(name:"Wake-up",
                                    eventType:.sleep)

  static let bedTime = TemporalEvent(name:"Bedtime",
                                     eventType:.sleep)

  static var defaultSlot:TemporalEvent {
    return DefaultEvents.wakeUp
  }
}



struct DisplaySchedule{
  var name:String
  var examples:[String]
  var events:[TemporalEvent]
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
                            "First thing"], events: [DefaultEvents.wakeUp]),
  DisplaySchedule(name:"With Breakfast",
                  examples:["Once a day with food",
                            "Early in the day with food",
                            "First thing in the morning with food"], events: [DefaultEvents.breakfast]),
  DisplaySchedule(name:"With Lunch",
                  examples:["Once a day with food",
                            "Early in the day with food",
                            "Avoid taking with alcohol"], events: [DefaultEvents.lunch]),
  DisplaySchedule(name:"With Breakfast and Dinner",
                  examples:["Twice a day with food",
                            "At least 6 hours apart",
                            "At least 4 hours apart"], events: [DefaultEvents.breakfast,DefaultEvents.dinner]),
  DisplaySchedule(name:"Custom",
                  examples:["Make my own schedule",
                            "Other",
                            "Something else",
                            "Every other day",
                            "Once a week"," "], events: [])
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
  var userSpecifiedQty:Int=1 //todo move this
  var raw:MedicationPackage
}

extension DisplayDrug{
  init(_ item: MedicationPackage){
    name = item.proprietaryName
    dosageForm = item.dosageForname
    nonPropName = item.nonProprietaryName
    activeStrength = item.activeNumerator
    unit = item.activeIngrediantUnit
    raw = item
  }
}

extension PrescriptionLineEntry{
  var events:[TemporalEvent] {

    guard let text = self.searchTextField.text else {
      return []
    }

    for s in schedules{
      if s.name == text {
        return s.events
      }
    }

    return [DefaultEvents.defaultSlot]
  }
}

extension PrescriptionLineEntry{
  var intValue:Int?{
    return Int(searchTextField?.text ?? "")
  }
}

class PrescriptionEntryViewController: UITableViewController,LineHelper {

  @IBOutlet weak var nameLine: PrescriptionLineEntry!
  @IBOutlet weak var unitLine: PrescriptionLineEntry!
  @IBOutlet weak var quantityLine: PrescriptionLineEntry!
  @IBOutlet weak var scheduleLine: PrescriptionLineEntry!
  @IBOutlet weak var prescriberLine: PrescriptionLineEntry!
  @IBOutlet weak var pharmacyLine: PrescriptionLineEntry!
  @IBOutlet weak var conditionLine: PrescriptionLineEntry!





  @IBAction func doctorContactAddressButtonTapped(_ sender: Any) {
  }

  @IBAction func pharmacyContactAddressButtonTapped(_ sender: Any) {
  }


  var popupBackgroundColor:UIColor{
    return UIColor(red:0.13, green:0.22, blue:0.30, alpha:1.00)
  }

  func pillSizesMatching(name:String, partial:String, completion:@escaping ([SearchTextFieldItem])->()){
    DispatchQueue.global().async {
      let rawMatches:[MedicationPackage] = pillSizesMatch(name: name, partial: partial)
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
      let rawMatches:[MedicationPackage] = matchingMedications(str)
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




  var allSearchFields:[SearchTextField]{
    return [
      nameLine.searchTextField,
      unitLine.searchTextField,
      quantityLine.searchTextField,
      scheduleLine.searchTextField,
      prescriberLine.searchTextField,
      pharmacyLine.searchTextField,
      conditionLine.searchTextField
    ]
  }

  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
    super.scrollViewWillBeginDragging(scrollView)
    allSearchFields.forEach { (field) in
      field.hideResultsList()
    }
  }

  override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    super.scrollViewDidEndScrollingAnimation(scrollView)
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
    self.unitLine.searchTextField.showLoadingIndicator()

    let search = nameLine.searchTextField.text ?? ""
    let pillSizePartial = unitLine.searchTextField.text ?? ""
    guard !search.isEmpty else{
      nameLine.searchTextField.filterItems([])
      return
    }

    pillSizesMatching(name: search, partial: pillSizePartial){ medications in
      DispatchQueue.main.async {
        self.unitLine.searchTextField?.stopLoadingIndicator()
        self.unitLine.searchTextField?.filterItems(medications)
      }
    }
  }

  var namedDrugs:[DisplayDrug] = [] {
    didSet{
      let displayable = namedDrugs.map{SearchTextFieldItem(listable:$0)}
      self.nameLine.searchTextField?.filterItems(displayable)
    }
  }

  func updateDrugsPopup(){

    nameLine.searchTextField.showLoadingIndicator()

    let search = nameLine.searchTextField.text ?? ""
    guard !search.isEmpty else{
      nameLine.searchTextField.filterItems([])
      return
    }

    namesMatchingAsync(search){ medications in
      DispatchQueue.main.async {
        self.nameLine.searchTextField?.stopLoadingIndicator()
        self.namedDrugs = medications
      }
    }
  }

  var lastSelectedDrug:DisplayDrug?

  func nameItemSelectionHandler(_ filteredResults: [SearchTextFieldItem], _ index: Int) {
    let drugSelection = namedDrugs[index]
    dump(("Drug Selection",drugSelection))

    nameLine.searchTextField?.text = drugSelection.name
    unitLine.searchTextField?.text = [drugSelection.activeStrength,
                                      drugSelection.unit,
                                      drugSelection.dosageForm].flatMap{$0}.joined(separator:" ")
    lastSelectedDrug = drugSelection
  }

  let showPrescriptionHelpSegue = "showPrescriptionHelp"

  func showHelp(_ helpInfo:NSAttributedString){
    self.helpInfo = helpInfo
    performSegue(withIdentifier: showPrescriptionHelpSegue, sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showPrescriptionHelpSegue{
      let dst = segue.destination as! PrescriptionEntryHelpViewController
      dst.helpText = helpInfo!
    }
  }
  
  var helpInfo:NSAttributedString? = nil
  override func viewDidLoad() {
    if let rx = editRx {
      entryInfo = rx.editInfo
    }

    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(keyboardWasShown:)
     name:UIKeyboardDidShowNotification object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(keyboardWillBeHidden:)
     name:UIKeyboardWillHideNotification object:nil];
     NotificationCenter.default.addObserver(self, selector: keyboardShow, name: "keyboardWillShow", object: <#T##Any?#>)
     */
    configureSearchField(nameLine.searchTextField)
    configureHeader(nameLine.searchTextField, withText: "Tap to fill-in")

    //updateDrugsPopup()


    nameLine.searchTextField.userStoppedTypingHandler = updateDrugsPopup
    nameLine.helpInfo = RXEntryHelpText.nameHelpText.renderMarkdownAsAttributedString
    nameLine.searchTextField.itemSelectionHandler = nameItemSelectionHandler
    nameLine.helper = self


    configureSearchField(unitLine.searchTextField)
    unitLine.searchTextField.userStoppedTypingHandler = updatePillSizePopup
    unitLine.helpInfo = RXEntryHelpText.unitHelpText.renderMarkdownAsAttributedString
    unitLine.helper = self


    configureSearchField(quantityLine.searchTextField)
    quantityLine.searchTextField.userStoppedTypingHandler = {}
    quantityLine.helpInfo = RXEntryHelpText.quantityHelpText.renderMarkdownAsAttributedString
    quantityLine.helper = self


    configureSearchField(prescriberLine.searchTextField)
    configureHeader(prescriberLine.searchTextField, withText: "Type new name or tap existing")
    prescriberLine.searchTextField.filterItems(
      doctors.map{SearchTextFieldItem(listable:$0)})
    prescriberLine.helpInfo = RXEntryHelpText.prescriberHelpText.renderMarkdownAsAttributedString
    prescriberLine.helper = self


    configureSearchField(scheduleLine.searchTextField)
    configureHeader(scheduleLine.searchTextField, withText: "Tap one or type 'Custom'")
    scheduleLine.searchTextField.filterItems(
      schedules.map{SearchTextFieldItem(listable:$0)})
    scheduleLine.helpInfo = RXEntryHelpText.scheduleHelpText.renderMarkdownAsAttributedString
    scheduleLine.helper = self




    pharmacyLine.helpInfo = RXEntryHelpText.pharmacyHelpText.renderMarkdownAsAttributedString
    pharmacyLine.helper = self


    conditionLine.helpInfo = RXEntryHelpText.conditionHelpText.renderMarkdownAsAttributedString
    conditionLine.helper = self
  }


  var mapping = [
    \EntryInfo.name:\PrescriptionEntryViewController.nameLine.searchTextField.text,
    \EntryInfo.unitDescription:\PrescriptionEntryViewController.unitLine.searchTextField.text,
    \EntryInfo.quantityOfUnits:\PrescriptionEntryViewController.quantityLine.searchTextField.text,
    \EntryInfo.schedule:\PrescriptionEntryViewController.scheduleLine.searchTextField.text,
    \EntryInfo.prescribingDoctor:\PrescriptionEntryViewController.prescriberLine.searchTextField.text,
    \EntryInfo.pharmacy:\PrescriptionEntryViewController.pharmacyLine.searchTextField.text,
    \EntryInfo.condition:\PrescriptionEntryViewController.conditionLine.searchTextField.text,
  ]

  var entryInfo:EntryInfo{
    get{

      var entry = EntryInfo()
      for transform in mapping{
        entry[keyPath: transform.key] = self[keyPath:transform.value]
      }
      entry.scheduleSelection = scheduleLine.events
      entry.drugDBSelection = lastSelectedDrug?.raw

      return entry
    }
    set{
      guard nameLine != nil else {
        //prevents firing from the didSet/prepare handler before view is loaded
        return
      }

      let entry = newValue
      for transform in mapping{
        let text = entry[keyPath: transform.key]
        self[keyPath:transform.value] = text
      }
      //scheduleLine.events = entry.scheduleSelection //TODO, do something if it doesn't match one
      lastSelectedDrug = entry.drugDBSelection.flatMap{DisplayDrug($0)}
    }
  }

  let multiplicationSign = "×"


  var editRx:Prescription? = nil
  var prescription:Prescription?  {
    set{
      editRx = newValue
    }
    get{
      return Prescription(info:entryInfo)
    }
  }

  var medicationName:String?{
    return nameLine.searchTextField?.text
  }
}
