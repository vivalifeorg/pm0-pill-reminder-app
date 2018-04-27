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

let searchCellHeight:CGFloat = 80.0
extension SearchTextField{
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return searchCellHeight
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


typealias MinuteOffset = Int
typealias HourOffset = Int


extension String {
  func leftPadding(toLength: Int, withPad character: Character) -> String {
    let stringLength = count
    if stringLength < toLength {
      return String(repeatElement(character, count: toLength - stringLength)) + self
    } else {
      return String(self.suffix(toLength))
    }
  }
}

extension Array where Element == Timeslot {
  var sorted:[Timeslot]{
    return self.sorted { (lhs, rhs) -> Bool in
      return lhs < rhs
    }
  }
}

struct Timeslot:Hashable,Codable{
  let itemRef:UUID = UUID()
  var hashValue: Int {
    return "\(fauxName ?? "non-named")\(slotType)".hashValue
  }

  static func >(lhs:Timeslot, rhs:Timeslot)->Bool{
    if lhs.offsetFromDayStart != rhs.offsetFromDayStart{
      return lhs.offsetFromDayStart > rhs.offsetFromDayStart
    }else{
      return lhs.fauxName ?? "" > rhs.fauxName ?? ""
    }
  }

  static func <(lhs:Timeslot, rhs:Timeslot)->Bool{
    return !(lhs > rhs) && (lhs != rhs)
  }

  var fauxName:String?{
    return name
  }
  var name:String

  var slotType:SlotType

  var hourOffset:HourOffset

  var minuteOffset:MinuteOffset

  var offsetFromDayStart:MinuteOffset{
    return (hourOffset * 60) + minuteOffset
  }
  /*

   */

  var timeString:String{
    var today = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: Date())
    today.second = 0
    today.nanosecond = 0

    today.hour = hourOffset
    today.minute = minuteOffset
    let dateFormatter = DateFormatter()

    dateFormatter.timeZone = Calendar.current.timeZone
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short

    return dateFormatter.string(from: today.date!)
  }
  
  var description:String{
    let timeStr = timeString
    if name != "" {
      return "\(name)@\(timeStr)"
    } else {
      return timeStr
    }
  }


  //todo fix broken ==
  static func ==(lhs:Timeslot, rhs:Timeslot) -> Bool{
    return lhs.name == rhs.name &&
      lhs.slotType == rhs.slotType &&
      lhs.offsetFromDayStart == rhs.offsetFromDayStart
  }

  static func userOverridenTimeOffsetFor(_ event:Timeslot) -> (hour:HourOffset,minute:MinuteOffset)?{
    return nil
  }

  static var sortedStandardTimeslots:[Timeslot]{
    StandardTimeslots.ensureStandardsExist()

    return LocalStorage.TimeslotStore.Standard.load().sorted(by: { (lhs, rhs) -> Bool in
      lhs.offsetFromDayStart < rhs.offsetFromDayStart
    })
  }



  init(name:String, slotType:SlotType, hourOffset:HourOffset, minuteOffset:MinuteOffset){
    self.name = name
    self.slotType = slotType
    self.hourOffset = hourOffset
    self.minuteOffset = minuteOffset
  }
}

enum SlotType:String,Codable{
  case meal
  case sleep
  case time
  case custom
}

enum StandardTimeslots{
  static let breakfast = Timeslot(name:"Breakfast",
                                  slotType:.meal, hourOffset:8, minuteOffset:00)

  static let morningSnack = Timeslot(name:"Morning Snack",
                                          slotType:.meal, hourOffset:8, minuteOffset:00)

  static let lunch = Timeslot(name:"Lunch",
                                   slotType:.meal, hourOffset:12, minuteOffset:00)

  static let afternoonSnack = Timeslot(name:"Afternoon Snack",
                                            slotType:.meal, hourOffset:14, minuteOffset:30)

  static let dinner = Timeslot(name:"Dinner",
                                    slotType:.meal, hourOffset:17, minuteOffset:30)

  static let wakeUp = Timeslot(name:"Wake-up",
                                    slotType:.sleep, hourOffset:7, minuteOffset:30)

  static let bedTime = Timeslot(name:"Bedtime",
                                     slotType:.sleep, hourOffset:21, minuteOffset:30)

  static let allStandardTimeslots:[Timeslot] = [
    StandardTimeslots.wakeUp,
    StandardTimeslots.breakfast,
    StandardTimeslots.morningSnack,
    StandardTimeslots.lunch,
    StandardTimeslots.afternoonSnack,
    StandardTimeslots.dinner,
    StandardTimeslots.bedTime
  ]

  static var defaultTimeslot:Timeslot {
    return StandardTimeslots.wakeUp
  }

  static func ensureStandardsExist(){
    guard LocalStorage.TimeslotStore.Standard.load().isEmpty else{
      return
    }

    LocalStorage.TimeslotStore.Standard.save(StandardTimeslots.allStandardTimeslots)
  }
}

func ==(lhs:Schedule,rhs:Schedule)->Bool{
  return lhs.name == rhs.name &&
    lhs.aliases == rhs.aliases &&
    lhs.timeslots == rhs.timeslots
}

func ==(lhs:Schedule?, rhs:Schedule?)->Bool{
  if lhs == nil && rhs == nil{
    return true
  }

  guard let lhs = lhs, let rhs = rhs else{
    return false //one is not nil, one is
  }

  return lhs == rhs
}

struct Schedule:Codable,Equatable {
  var name:String
  var aliases:[String]
  var timeslots:[Timeslot]
  let itemRef:UUID = UUID()

  mutating func ensureNonEmptyName(){
    let savingScheduleName = (self.name == "") ? "Schedule-\(UUID().uuidString.dropLast(31))" : self.name
    self.name = savingScheduleName
  }
}

extension Schedule:Listable{
  var title:String{
    return name
  }

  var list:[String]{
    return aliases
  }
}



struct DisplayDoctor{
  var name:String
  var specialities:[String]
}

extension DoctorInfo:Listable{
  var title:String{ return name}
  var list:[String] {return [specialty]}
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
  var intValue:Int?{
    return Int(searchTextField?.text ?? "")
  }
}

class PrescriptionEntryViewController: UITableViewController,LineHelper {

  @IBOutlet weak var nameLine: PrescriptionLineEntry!
  @IBOutlet weak var formLine: PrescriptionLineEntry!
  @IBOutlet weak var unitLine: PrescriptionLineEntry!
  @IBOutlet weak var quantityLine: PrescriptionLineEntry!
  //@IBOutlet weak var scheduleLine: PrescriptionLineEntry!
  @IBOutlet weak var prescriberLine: PrescriptionLineEntry!
  @IBOutlet weak var pharmacyLine: PrescriptionLineEntry!
  @IBOutlet weak var conditionLine: PrescriptionLineEntry!

  @IBOutlet weak var nextButton:UIBarButtonItem!

  func updateNextButton(){
    guard let nameLength = nameLine.searchTextField?.text?.count,
      let quantityLength = quantityLine?.searchTextField?.text?.count else{
      return
    }
    nextButton.isEnabled = nameLength > 0 && quantityLength > 0
  }

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
   //   scheduleLine.searchTextField,
      prescriberLine.searchTextField,
      pharmacyLine.searchTextField,
      conditionLine.searchTextField
    ]
  }

  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
    allSearchFields.forEach { (field) in
      field.hideResultsList()
    }
  }

  override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    allSearchFields.filter{$0.isFocused}.forEach { (field) in
      field.layoutSubviews()
    }
  }

  let searchMainTextSize = 20.0 as CGFloat

  func configureSearchField(_ field:SearchTextField){
    field.theme = SearchTextFieldTheme.darkTheme()
    field.theme.font  = UIFont.systemFont(ofSize: 20)
    field.theme.cellHeight = searchCellHeight
    field.theme.bgColor = popupBackgroundColor
    field.highlightAttributes =  [
      NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):
        UIFont.boldSystemFont(ofSize: searchMainTextSize),
      NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue):
        VLColors.warmHighlight,
    ]
    field.theme.separatorColor = UIColor.darkGray
    field.tableBottomMargin = 0
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
    updateNextButton()
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

  func formLinePopup(){
    updateNextButton()
    self.formLine.searchTextField.showLoadingIndicator()

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
    updateNextButton()
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
                                      drugSelection.unit].compactMap{$0}.joined(separator:" ")
    formLine.searchTextField?.text = drugSelection.dosageForm
    lastSelectedDrug = drugSelection
  }

  let showPrescriptionHelpSegue = StoryboardSegue.PrescriptionEntryViewController.showPrescriptionHelp.rawValue

  func showHelp(_ helpInfo:NSAttributedString){
    self.helpInfo = helpInfo
    performSegue(withIdentifier: showPrescriptionHelpSegue, sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showPrescriptionHelpSegue{
      let dst = segue.destination as! HelpViewController
      dst.helpText = helpInfo!
    } else if let scheduleList = segue.destination as? ScheduleListViewController {
      scheduleList.entryInfo = entryInfo
    }
  }

  var doctors:[DoctorInfo] = []

  var helpInfo:NSAttributedString? = nil
  override func viewDidLoad() {
    updateNextButton()

    if let rx = editRx {
      entryInfo = rx.editInfo
    }


    configureSearchField(nameLine.searchTextField)
    //configureHeader(nameLine.searchTextField, withText: "Tap to fill-in")

    //updateDrugsPopup()


    nameLine.searchTextField.userStoppedTypingHandler = updateDrugsPopup
    nameLine.helpInfo = RXEntryHelpText.nameHelpText.renderMarkdownAsAttributedString
    nameLine.searchTextField.itemSelectionHandler = nameItemSelectionHandler
    nameLine.helper = self


    configureSearchField(unitLine.searchTextField)
    unitLine.searchTextField.userStoppedTypingHandler = updatePillSizePopup
    unitLine.helpInfo = RXEntryHelpText.unitHelpText.renderMarkdownAsAttributedString
    unitLine.helper = self

    configureSearchField(formLine.searchTextField)
    formLine.searchTextField.userStoppedTypingHandler = formLinePopup
    formLine.helpInfo = RXEntryHelpText.formHelpText.renderMarkdownAsAttributedString
    formLine.helper = self


    configureSearchField(quantityLine.searchTextField)
    quantityLine.searchTextField.userStoppedTypingHandler = {self.updateNextButton()}
    quantityLine.helpInfo = RXEntryHelpText.quantityHelpText.renderMarkdownAsAttributedString
    quantityLine.helper = self


    doctors = LocalStorage.DoctorStore.load()
    configureSearchField(prescriberLine.searchTextField)
    prescriberLine.searchTextField.filterItems(
      doctors.map{SearchTextFieldItem(listable:$0)})
    prescriberLine.helpInfo = RXEntryHelpText.prescriberHelpText.renderMarkdownAsAttributedString
    prescriberLine.helper = self
    prescriberLine.searchTextField.startSuggestingInmediately = true


    pharmacyLine.helpInfo = RXEntryHelpText.pharmacyHelpText.renderMarkdownAsAttributedString
    pharmacyLine.helper = self


    conditionLine.helpInfo = RXEntryHelpText.conditionHelpText.renderMarkdownAsAttributedString
    conditionLine.helper = self
  }


  var mapping = [
    \EntryInfo.name:\PrescriptionEntryViewController.nameLine.searchTextField.text,
    \EntryInfo.unitDescription:\PrescriptionEntryViewController.unitLine.searchTextField.text,
    \EntryInfo.form:\PrescriptionEntryViewController.formLine.searchTextField.text,
    \EntryInfo.quantityOfUnits:\PrescriptionEntryViewController.quantityLine.searchTextField.text,
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
