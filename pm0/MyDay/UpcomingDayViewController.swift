//
//  SecondViewController.swift
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import AVFoundation

func loadDeviceID()->DeviceIdentifier{
  guard let devId = LocalStorage.DeviceStore.load().first else {
    let newDevId = "\(UIDevice.current.localizedModel):\(UUID())"
    LocalStorage.DeviceStore.save([newDevId])
    return newDevId
  }
  return devId
}

extension Date{
  var relevantDateString:String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: self)
  }
}

struct MedicationLogEvent:Codable{
  enum MedicationLogEventType:String,Codable{
    case markedMedicationTaken
    case unmarkedMedicationTaken
  }
  var relevantDate:String{
    return dateOfAdministration.relevantDateString
  }
  var eventType:MedicationLogEventType
  var dosage:Dosage
  var timestamp:Date
  var dateOfAdministration:Date{
    return timestamp //may eventually diverge as we allow editing of past
  }
  var deviceId:DeviceIdentifier
  var eventId:EventIdentifier
  var sectionName:String
  var timezone:TimeZone
}

extension MedicationLogEvent{
  var isToday:Bool{
    return matchesDay(date: Date())
  }

  func matchesDay(date:Date)->Bool{
    return Calendar.current.startOfDay(for:timestamp) == Calendar.current.startOfDay(for:date)
  }
}

extension MedicationLogEvent{
  static func markedTaken(dosage:Dosage,date:Date,sectionName:String)->MedicationLogEvent{
    return MedicationLogEvent(eventType: .markedMedicationTaken,
                       dosage: dosage,
                       timestamp: date,
                       deviceId: loadDeviceID(),
                       eventId: UUID().uuidString,
                       sectionName:sectionName,
                       timezone: Calendar.current.timeZone)
  }

  static func unmarkedTaken(dosage:Dosage, date:Date, sectionName:String)->MedicationLogEvent{
    return MedicationLogEvent(eventType: .unmarkedMedicationTaken,
                       dosage: dosage,
                       timestamp: date,
                       deviceId: loadDeviceID(),
                       eventId: UUID().uuidString,
                       sectionName:sectionName,
                       timezone: Calendar.current.timeZone )
  }

}


typealias DeviceIdentifier = String
typealias EventIdentifier = String


class MyDayTableSectionHeaderView:UITableViewHeaderFooterView{

  @IBOutlet weak var titleLabel:UILabel!
  @IBOutlet weak var remainingLabel:UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    let backgroundView = UIView(frame: bounds)
    backgroundView.backgroundColor = VLColors.tableViewSectionHeaderBackgroundColor
    self.backgroundView = backgroundView
  }
}

@objc class UpcomingDayViewControllerDoseCell:UITableViewCell{

  @IBOutlet weak var nextDoseIndicator:UILabel!
  @IBOutlet weak var prescriptionView:PrescriptionDisplayView!

  enum Opacity{
    case bright
    case dim
  }

  var isIndicated:Bool{
    get{
      return !nextDoseIndicator.isHidden
    }
    set{
      nextDoseIndicator.isHidden = !newValue
    }
  }

  static var defaultReuseIdentifier: String {
    return NSStringFromClass(self)
  }

  var isTaken:Bool{
    get{
      return accessoryType == .checkmark
    }
    set{
      return accessoryType = newValue ? .checkmark : .none
    }
  }
}

extension UIColor {

  convenience init(hexString : String)
  {
    if let rgbValue = UInt(hexString, radix: 16) {
      let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
      let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
      let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
      self.init(red: red, green: green, blue: blue, alpha: 1.0)
    } else {
      self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
  }

  var colorProxy:ColorProxy{
    return ColorProxy(self)
  }
}

struct ColorProxy:ExpressibleByStringLiteral{
  typealias StringLiteralType = String
  var stringColorSpec:String

  init(stringLiteral extendedGraphemeClusterLiteral:String){
    stringColorSpec = extendedGraphemeClusterLiteral
  }
}

extension ColorProxy{

  private static func proxyStringFromUIColor(_ aUIColor:UIColor)->String!{
    guard let comp =  aUIColor.cgColor.components else{
      return nil
    }
    return String(format:"%02X%02X%02X",comp[0],comp[1],comp[2])
  }

  init(_ aUIColor:UIColor){
    stringColorSpec = ColorProxy.proxyStringFromUIColor(aUIColor)
  }

  var uicolor:UIColor {
    get{
      return UIColor.init(hexString: stringColorSpec)
    }
    set{
      stringColorSpec = ColorProxy.proxyStringFromUIColor(newValue)
    }
  }
}

class UpcomingDayViewController: UITableViewController {

  var medicationTakenEventLog:[MedicationLogEvent] = []



  func updateDateDisplay(forDay displayDay:Date){
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .ordinal
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE,  MMMM "

    let day:Int = Calendar.current.component(.day, from: displayDay)
    let dayNumber = NSNumber(value:day)
    let dateString = "\(dateFormatter.string(from:displayDay))\(numberFormatter.string(from:dayNumber) ?? day.description)"

    //Only set the *top* bar, leave the tab bar as "My Day"
    self.navigationItem.title = dateString
  }

  func updateData(){
    let possiblyUpdatedDosages = LocalStorage.PrescriptionStore.load().compactMap{$0.dosage}
    if possiblyUpdatedDosages != scheduledDosages{
      scheduledDosages = possiblyUpdatedDosages
    }
    loadMedicationLog()
  }

  override func viewDidAppear(_ animated: Bool) {
    updateData()
    super.viewDidAppear(animated)
  }

  @objc func refreshDateAndData(_ sender:Any){
    updateData()
    updateDateDisplay(forDay:Date())
    tableView.reloadData()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.tableView?.refreshControl?.endRefreshing()
    }
  }


  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.backgroundColor = VLColors.background
    tableView.separatorColor = UIColor.lightGray
    tableView.allowsSelection = true
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44
    tableView.emptyDataSetSource = self;
    tableView.emptyDataSetDelegate = self;
    tableView.tintColor = UIColor.white

    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refreshDateAndData(_:)), for: .valueChanged)
    



    tableView.register(UpcomingDayViewControllerDoseCell.self,
                       forCellReuseIdentifier: UpcomingDayViewControllerDoseCell.defaultReuseIdentifier)

    tableView.register(UINib(nibName: "MyDayTableSectionHeaderView", bundle: nil),
                       forHeaderFooterViewReuseIdentifier: "MyDayTableSectionHeaderView")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  var onboardingAlert:UIAlertController! = nil

  var firstUntakenItem:IndexPath?{
    for sectionComponent in 0..<sections.count{
      for rowComponent in 0..<sections[sectionComponent].medications.count{

        let medication = sections[sectionComponent].medications[rowComponent]
        guard !medication.isTaken else {continue}

        return IndexPath(indexes: [sectionComponent,rowComponent])

      }
    }
    return nil
  }

  struct Section{
    func footerColorAtTime(_ date:Date)->UIColor {

      let aFewMinutes = 30.0*60.0
      let isSomewhatLate = date.timeIntervalSinceNow < aFewMinutes
      let allTaken = medications.reduce(true){$0 && $1.isTaken}

      if allTaken { return VLColors.footerAllGood }
      if isSomewhatLate { return VLColors.footerMissedMeds }
      return VLColors.footerInfoPertinent
    }


    var title:String
    var footnote:String
    var remaining:String{
      let remaining = medications.reduce(0){
        $1.isTaken ? $0 : $0 + 1
      }
      let leader = "           "
      if remaining == 0 {
        return "\(leader)✓"
      }
      return "\(leader)\(remaining)/\(medications.count)"
    }
    var rowCount:Int{return medications.count}
    var medications:[TimeSlotItem]
    var isActive:(Date)->Bool
  }

  var scheduledDosages:[Dosage]=[] {
    didSet{
      let appliedSchedule = scheduleForDate(Date(),drugs:scheduledDosages)
      sections = sectionsForSchedule(timeSlots: appliedSchedule)
    }
  }

  struct DisplayTimeslot{
    let name:String?
    let date:Date
    var items:[TimeSlotItem]
    var footnote:String = ""

    var slotDescription:String{
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = Calendar.current.timeZone
      dateFormatter.dateStyle = .none
      dateFormatter.timeStyle = .short
      let time = dateFormatter.string(from: date)

      if let name = name, name != ""{
        return "\(name) @ \(time)"
      }else{
        return "\(time)"
      }
    }

    var description:String{
      return "\(slotDescription): \(items)"
    }
    var debugDescription:String{
      return description
    }
  }

  struct TimeSlotItem{
    var dosage:Dosage
    var isTaken:Bool
  }



  func sectionsForSchedule(timeSlots:[DisplayTimeslot])->[Section]{
    return timeSlots.map{
      let startTime = $0.date
      let minutesBefore = 60.0
      let minutesAfterSlotStart = 60.0
      let activeStart = startTime.addingTimeInterval(-minutesBefore * 60.0)
      let activeStop = startTime.addingTimeInterval(minutesAfterSlotStart * 60.0)

      return Section(title: $0.slotDescription, footnote: $0.footnote,
              medications: $0.items,
              isActive:{ (now:Date) in
                activeStart <= now &&
                now < activeStop
              })
    }
  }

  func scheduleForDate(_ date:Date, drugs:[Dosage]) -> [DisplayTimeslot] {
    var times:[Int:[Dosage]] = [:]
    var timeNames:[Int:[String]] = [:]
    for dose in drugs{
      for slot in dose.schedule.timeslots{
        //debugPrint("Timeslot: \(slot.name) \(slot.hourOffset):\(slot.minuteOffset)")
        var dosesAtTime = times[slot.offsetFromDayStart] ?? []
        dosesAtTime.append(dose)
        times[slot.offsetFromDayStart] = dosesAtTime
        let name = slot.name
        if name != "" {
          var nameList = timeNames[slot.offsetFromDayStart] ?? []
          nameList.append(name)
          timeNames[slot.offsetFromDayStart] = nameList
        } else {
          print("\(slot.offsetFromDayStart) missing name, \(slot.description)")
        }
      }
    }

    var thisDay = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)

    //zero out the sub-hour fields because we don't want those showing up
    thisDay.hour = 0
    thisDay.second = 0
    thisDay.minute = 0
    thisDay.nanosecond = 0

    var timeSlots:[DisplayTimeslot] = []
    for minuteOffset in times.keys.sorted(){
      let dosesAtTime = times[minuteOffset] ?? []
      guard dosesAtTime.count != 0 else {continue}

      var thisTime = thisDay
      thisTime.hour = minuteOffset / 60
      thisTime.minute = minuteOffset % 60
      let timeSlotDate = Calendar.current.date(from: thisTime)!

      let displayable = dosesAtTime.map{ TimeSlotItem(dosage:$0,isTaken:false) }

      var footnote = ""
      let sortedNames = (timeNames[minuteOffset] ?? []).sorted()
      var name = sortedNames.first ?? ""
      if sortedNames.count > 1{
        name = sortedNames.reduce(name){ $0.count > $1.count ? $0 : $1 } //longest name
        if name != sortedNames.first{
          footnote = "*also: \(sortedNames.filter{name != $0}.joined(separator: "/"))"
          name = "\(name)*" //show there are multiple names going on
        }
      }

      let timeSlot = DisplayTimeslot(name:name,
                             date:timeSlotDate,
                             items:displayable, footnote:footnote)
      timeSlots.append(timeSlot)
    }

    return timeSlots
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
    return UITableViewAutomaticDimension
  }


  var sections:[Section] = [] {
    didSet{
      self.tableView?.reloadData()
    }
  }

  func loadDosages(){
    scheduledDosages = LocalStorage.PrescriptionStore.load().compactMap{$0.dosage}
  }

  func loadMedicationLog(){
    medicationTakenEventLog = LocalStorage.MedicationLogStore.load(relevantDate: Date().relevantDateString)
    print("Found \(medicationTakenEventLog.count) medlog events")
    let todaysActions = medicationTakenEventLog.filter{ $0.isToday }.sorted {
      $0.timestamp < $1.timestamp
    }

    for logItem in todaysActions {
      for sectionIndex in 0..<sections.count{
        for medicationIndex in 0..<sections[sectionIndex].medications.count{
          let item = sections[sectionIndex].medications[medicationIndex]
          if item.dosage == logItem.dosage &&
            sections[sectionIndex].title == logItem.sectionName {
            switch logItem{
            case let x where x.eventType == .markedMedicationTaken:
           //   print("checked, \(logItem.sectionName), \(medicationIndex) ")
              sections[sectionIndex].medications[medicationIndex].isTaken = true
            case let x where x.eventType == .unmarkedMedicationTaken:
          //    print("unchecked, \(logItem.sectionName), \(medicationIndex) ")
              sections[sectionIndex].medications[medicationIndex].isTaken = false
            default:
              print("ERROR")
            }
          }
        }
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    updateDateDisplay(forDay:Date())
    loadDosages()
    loadMedicationLog()
    tableView.reloadData()
  }

  static let cellIdentifier = "UpcomingDayViewControllerDoseCell"
}


//UITableView DataSource
extension UpcomingDayViewController{
  func dequeueDoseCellForIndexPath(_ tableView:UITableView, indexPath:IndexPath)->UpcomingDayViewControllerDoseCell{
    return tableView.dequeueReusableCell(withIdentifier: UpcomingDayViewController.cellIdentifier, for: indexPath) as! UpcomingDayViewControllerDoseCell
  }

  override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    let cell = dequeueDoseCellForIndexPath(tableView,indexPath:indexPath)
    let section = sections[indexPath.section]
    let timeSlotItem = section.medications[indexPath.row]

    cell.prescriptionView?.dosage = timeSlotItem.dosage
    cell.isTaken = timeSlotItem.isTaken
    cell.selectionStyle = .none

    if let firstUntakenItem = firstUntakenItem {
      cell.isIndicated = (firstUntakenItem == indexPath)
    }else{
      cell.isIndicated = false
    }

    return cell
  }

  override func numberOfSections(in tableView: UITableView) -> Int{
    return sections.count
  }

  override func tableView(_ tableView:UITableView, numberOfRowsInSection sectionIndex: Int) -> Int{
    return sections[sectionIndex].rowCount
  }

  override func tableView(_ tableView: UITableView,
                          willDisplayHeaderView view: UIView,
                          forSection section: Int){
    let customHeader = view as! MyDayTableSectionHeaderView
    customHeader.titleLabel.text = sections[section].title
    customHeader.remainingLabel.text = sections[section].remaining
    customHeader.remainingLabel.textColor = Asset.Colors.vlTextColor.color
  }

  override func tableView(_ tableView:UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView{
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MyDayTableSectionHeaderView") as! MyDayTableSectionHeaderView
    return header
  }
  override func tableView(_ tableView:UITableView, titleForFooterInSection sectionIndex: Int) -> String{
    return sections[sectionIndex].footnote
  }


  override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

}

//UITableView Delegate
extension UpcomingDayViewController{

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }

  override func tableView(_ tableView: UITableView,
                          willDisplayFooterView view: UIView,
                          forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.textColor = sections[section].footerColorAtTime(Date())
    header.textLabel?.frame = header.frame
  }


  func recordMedicationEvent(_ event:MedicationLogEvent){

    /*
    ///To quickly make this save tons
    for _ in 0..<1000{
      medicationTakenEventLog.append(event)
    }
     */
    print("Appending: \(event.eventType.rawValue)")
    medicationTakenEventLog.append(event)
    LocalStorage.MedicationLogStore.append([event], relevantDate: event.relevantDate)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let wasPreviouslyChecked = sections[indexPath.section].medications[indexPath.row].isTaken
    let shouldNowBeChecked = !wasPreviouslyChecked
    
    sections[indexPath.section].medications[indexPath.row].isTaken = shouldNowBeChecked

    let dosage = sections[indexPath.section].medications[indexPath.row].dosage
    let event:MedicationLogEvent = shouldNowBeChecked ?
      MedicationLogEvent.markedTaken(dosage: dosage,date: Date(),sectionName:sections[indexPath.section].title) :
      MedicationLogEvent.unmarkedTaken(dosage: dosage, date: Date(),sectionName:sections[indexPath.section].title)
    recordMedicationEvent(event)

    if shouldNowBeChecked {
      AudioServicesPlaySystemSound (4095)
    }
  }

  

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let helpVC = segue.destination as? HelpViewController {
      helpVC.helpText =
        """
          This screen shows what doses of medication you need to take.

          Check off your medication every time you administer it each day.

          Medications are grouped by time of day in which you said you wanted to take them them.

          Each group shows you how many items are remaining for that group after the name, or a white checkmark if you've taken them all at that time.

          If you tap a dose you did not take yet, you can tap again to uncheck it.

          The ➙ indicator points at your next dose. (If you have a lot of doses, this makes sure you don't miss one early in the day).


          ## Related Screens

          More medications and prescriptions can be added in the Medications tab.

          These logs can be exported in the Faxing tab for all days that you've entered information into the app.
        """.renderMarkdownAsAttributedString
      helpVC.title = "\(tabBarItem.title.spaceAfterOrEmpty) Help"
      return
    }
  }


  @IBAction func unwindToMyDay(segue:UIStoryboardSegue){
    //If we're getting this, it's from the inital onboarding add, so we need to tell the user to add further elsewhere.

    let rxEntryVC = segue.source as! ScheduleListViewController
    LocalStorage.PrescriptionStore.save([rxEntryVC.entryInfo!.prescription])

    loadDosages()
  }
}

extension UIImage {
  static func from(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }

  func drawBorder(color:UIColor){
    let context = UIGraphicsGetCurrentContext()!

    /// Rectangle
    let rectangle = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: 60), cornerRadius: 8)
    context.saveGState()
    context.translateBy(x: 0, y: 0)
    context.saveGState()
    rectangle.lineWidth = 1
    context.beginPath()
    context.addPath(rectangle.cgPath)
    context.clip(using: .evenOdd)
    color.setStroke()
    rectangle.stroke()
    context.restoreGState()
  }

  func drawRoundRectButtonBackground(color:UIColor){
    let context = UIGraphicsGetCurrentContext()!

    /// Rectangle
    let rectangle = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: 60), cornerRadius: 8)
    context.saveGState()
    context.translateBy(x: 0, y: 0)
    context.saveGState()
    rectangle.lineWidth = 1
    context.beginPath()
    context.addPath(rectangle.cgPath)
    context.clip(using: .evenOdd)
    color.setStroke()
    rectangle.fill()
    context.restoreGState()
  }

  var roundedCornerButton: UIImage {
      let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
      UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
      UIBezierPath(
        roundedRect: rect,
        cornerRadius: 8.0
        ).addClip()
    draw(in: rect)
    return UIGraphicsGetImageFromCurrentImageContext()!
  }
}

extension UIImage {
  convenience init(view: UIView) {
    let scale = UIScreen.main.scale
    let scaledSize = CGSize(width: view.frame.size.width * scale,
                            height: view.frame.size.height * scale)
    UIGraphicsBeginImageContext(scaledSize)
    view.layer.render(in:UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
  }
}


extension UpcomingDayViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    return Asset.Empty.emptyMyDay.image
  }

  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return emptyStateAttributedString("Your Daily Medication Schedule")
  }

  func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
    let animation  = CABasicAnimation(keyPath:"opacity")
    animation.fromValue = 0.8
    animation.toValue = 1.0
    animation.duration = 3.0
    animation.repeatCount = 5
    animation.autoreverses = true
    animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)

    return animation
  }

  func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {

    return emptyStateButtonText("Add Medication")
  }

  
  
  func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {

    return VivaButtonA.createImageForButton(buttonBackgroundColor:Asset.Colors.vlWarmTintColor.color,
                       borderWidth:0.5,
                       cornerRadius: 8,
                       buttonSize: CGSize(width:scrollView.frame.size.width-20, height: 44),
                       backgroundBehindButtonColor: Asset.Colors.vlCellBackgroundCommon.color)
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return emptyStateAttributedString("Add your medications to the app to see a checklist of what to take each day here.")
  }

  func verticalOffset(forEmptyDataSet scrollView:UIScrollView)->CGFloat{
    return -110
  }


  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    performSegue(withIdentifier: StoryboardSegue.UpcomingDay.addPrescriptionSegue.rawValue, sender: self)
  }

  func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
    return true
  }
}

