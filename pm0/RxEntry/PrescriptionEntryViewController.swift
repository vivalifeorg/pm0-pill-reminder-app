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
    let styles =
    """
    * {
      font-family: system-ui;
      font-size: \(VLFonts.body.pointSize);
      line-height: 140%;
      color: white
    }

    h1 {
      font-size: \(VLFonts.h1.pointSize)
    }

    h2 {
      font-size: \(VLFonts.h2.pointSize)
    }

    h3 {
      font-size: \(VLFonts.h3.pointSize)
    }

    strong {
      color: #f2f2f2;
      font-weight: bolder
    }

    em {
      font-style: italic
    }

    hr {
      color: white
    }

    code, pre {
      font-family: Menlo
    }
    """

    if debugMarkdown {
      debugPrint("--css--")
      debugPrint(styles)
      debugPrint("--css -> html--")
      debugPrint(try! rendered.toHTML(DownOptions.default))
      debugPrint("--endhtml---")
    }
    return try! rendered.toAttributedString(
      DownOptions.default,
      stylesheet: styles)
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

class PrescriptionEntryViewController: UIViewController,UIScrollViewDelegate,LineHelper {



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


  @IBOutlet weak var scrollView: UIScrollView!


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
    configureSearchField(nameLine.searchTextField)
    configureHeader(nameLine.searchTextField, withText: "Tap to fill-in")

    //updateDrugsPopup()

    let nameHelpText =
    """
    # Naming your medication

    Enter in a *short* memorable name for your medication.

    Feel free to shorten the text the search box inserted for you if you selected one from the list that shows up after you start typing. Selecting an item from that list will also insert starting values in the quantity and unit fields.
    """
    


    nameLine.searchTextField.userStoppedTypingHandler = updateDrugsPopup
    nameLine.helpInfo = nameHelpText.renderMarkdownAsAttributedString
    nameLine.searchTextField.itemSelectionHandler = nameItemSelectionHandler
    nameLine.helper = self


    let unitHelpText =
    """
    # Describing a "Unit"

    Describe what a *single* pill looks like. You will input quantity later.

    For example, if you take two orange 200mg pills every six hours, put "**200mg orange pill**" here.

    ### Other Examples:

     - 40mg Square Blue Pill
     - 100mg Capsule

    *****

    # Things that aren't pills

    Some types of medications do not come as pills.

     - For prepackaged, single-use items, put "**kit**" here.
     - If your medication is something liquid or powdered, put "**g**" or "**ml**" or whatever unit measurement uses.
     - If your medication is in an inhaler, put **puff** here.
    """

    configureSearchField(unitLine.searchTextField)
    unitLine.searchTextField.userStoppedTypingHandler = updatePillSizePopup
    unitLine.helpInfo = unitHelpText.renderMarkdownAsAttributedString
    unitLine.helper = self


    let quantityHelpText =
    """
    # Quantity

    For most medications, this is the number of pills you take at once.

    For example, if you take two 200mg pills every six hours, you put "**2**" here, as that's how much you take at a single time.

    If you take a liquid, take how many "units" of that medication you take. So if you take 10ml of a tylenol solution, put "**10**" here.
    """
    configureSearchField(quantityLine.searchTextField)
    quantityLine.searchTextField.userStoppedTypingHandler = {}
    quantityLine.helpInfo = quantityHelpText.renderMarkdownAsAttributedString
    quantityLine.helper = self


    let prescriberHelpText =
    """
    # Prescriber

    This is the person who wrote your prescription. They are typically a doctor or nurse practitioner. This will be on the medication bottle and prescription.

    Tap the circled plus button to select a doctor formerly entered into the app.
    """
    configureSearchField(prescriberLine.searchTextField)
    configureHeader(prescriberLine.searchTextField, withText: "Type new name or tap existing")
    prescriberLine.searchTextField.filterItems(
      doctors.map{SearchTextFieldItem(listable:$0)})
    prescriberLine.helpInfo = prescriberHelpText.renderMarkdownAsAttributedString
    prescriberLine.helper = self

    let scheduleHelpText =
    """
    # Describe when you take it

    Start typing how and when you need to take the medication. We will show you some patterns of possible matchups that fit common times of day that people use to remember to take their medications.

    You can select any of those shown as you type, or tap "Custom" to build your own.
    """
    configureSearchField(scheduleLine.searchTextField)
    configureHeader(scheduleLine.searchTextField, withText: "Tap one or type 'Custom'")
    scheduleLine.searchTextField.filterItems(
      schedules.map{SearchTextFieldItem(listable:$0)})
    scheduleLine.helpInfo = scheduleHelpText.renderMarkdownAsAttributedString
    scheduleLine.helper = self

    let pharmacyHelpText =
    """
    # Who Fills this Prescription

    Write where you pick up this medication from. If an over the counter drug, feel free to leave this blank.

    Tap the circled plus button to select a pharmacy formerly entered into the app.
    """
    pharmacyLine.helpInfo = pharmacyHelpText.renderMarkdownAsAttributedString
    pharmacyLine.helper = self

    let conditionHelpText =
    """
    # Condition

    Write what condition or impairment that motivates you to take this medication. This helps you discuss your entire treatment plan with every doctor trying to help you.

    This also helps you clean up after recovering from something like a surgery or other intermittant occasion where you will not need many of the medications long term.
    """
    conditionLine.helpInfo = conditionHelpText.renderMarkdownAsAttributedString
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
