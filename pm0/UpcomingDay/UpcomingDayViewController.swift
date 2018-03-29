//
//  SecondViewController.swift
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

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
    var remaining:String{
      let remaining = medications.reduce(0){
        $1.isTaken ? $0 : $0 + 1
      }
      let leader = "           "
      if remaining == 0 {
        return "\(leader)Completed!"
      }
      return "\(leader)(\(remaining)/\(medications.count))"
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

  func minuteOffset(hour:Int,minute:Int)->Int{
    return hour * 60 + minute
  }

  struct TimeSlot{
    let name:String?
    let date:Date
    var items:[TimeSlotItem]

    var slotDescription:String{
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = Calendar.current.timeZone
      dateFormatter.dateStyle = .none
      dateFormatter.timeStyle = .short
      let time = dateFormatter.string(from: date)
      if let name = name {
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



  func sectionsForSchedule(timeSlots:[TimeSlot])->[Section]{
    return timeSlots.map{
      let startTime = $0.date
      let minutesBefore = 60.0
      let minutesAfterSlotStart = 60.0
      let activeStart = startTime.addingTimeInterval(-minutesBefore * 60.0)
      let activeStop = startTime.addingTimeInterval(minutesAfterSlotStart * 60.0)
      //debugPrint("\(activeStart) \(activeStop) for \(startTime)")
      return Section(title: $0.slotDescription,
              medications: $0.items,
              isActive:{ (now:Date) in
                activeStart <= now &&
                now < activeStop
              })
    }
  }

  func scheduleForDate(_ date:Date, drugs:[Dosage]) -> [TimeSlot] {
    var times:[Int:[Dosage]] = [:]
    for dose in drugs{
      for time in dose.timesTaken(for: date){
        var dosesAtTime = times[minuteOffset(hour: time.hour, minute: time.minute)] ?? []
        dosesAtTime.append(dose)
        times[minuteOffset(hour: time.hour, minute: time.minute)] = dosesAtTime
      }
    }

    var thisDay = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)

    //zero out the sub-hour fields because we don't want those showing up
    thisDay.hour = 0
    thisDay.second = 0
    thisDay.minute = 0
    thisDay.nanosecond = 0


    var names:[Int:String] = [:]
    let defaultEvents = TemporalEvent.defaultEventTimes.keys
    for item in defaultEvents{
      guard let name = item.name else{ continue}

      names[minuteOffset(hour: item.hourOffset, minute: item.minuteOffset)] = name
    }

    var timeSlots:[TimeSlot] = []
    for minuteOffset in times.keys.sorted(){
      let dosesAtTime = times[minuteOffset] ?? []
      guard dosesAtTime.count != 0 else {continue}

      var thisTime = thisDay
      thisTime.hour = minuteOffset / 60
      thisTime.minute = minuteOffset % 60
      let timeSlotDate = Calendar.current.date(from: thisTime)!

      let displayable = dosesAtTime.map{ TimeSlotItem(dosage:$0,isTaken:false) }
      let timeSlot = TimeSlot(name:names[minuteOffset],
                             date:timeSlotDate,
                             items:displayable)
      timeSlots.append(timeSlot)

      //debugPrint("\(thisTime.hour!):\(thisTime.minute!) \(timeSlot)")
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
    scheduledDosages = LocalStorage.prescriptions.load().flatMap{$0.dosage}
  }

  override func viewWillAppear(_ animated: Bool) {
    loadDosages()
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
  }

  override func tableView(_ tableView:UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView{
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MyDayTableSectionHeaderView") as! MyDayTableSectionHeaderView
    return header
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

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let wasPreviouslyChecked = sections[indexPath.section].medications[indexPath.row].isTaken
    sections[indexPath.section].medications[indexPath.row].isTaken = !wasPreviouslyChecked
    if !wasPreviouslyChecked {
      UIImpactFeedbackGenerator().impactOccurred() // They are checking they took a pill, give feedback
    }
  }

  func alertUserOfFirstSave(){
    onboardingAlert = UIAlertController(title: "You've added your first Rx", message: "This checklist shows when to take your medications each day. As you take each medication, tap the dose here to check it off. If you tap the wrong one, tap again to uncheck it.\n\nTo add more prescriptions, tap the 'Prescriptions' tab on the bottom", preferredStyle: .alert)
    onboardingAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
      self.onboardingAlert.dismiss(animated:true)
    }))
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      //get past wierdness with unwind segue timing
      self.present(self.onboardingAlert, animated: true, completion: nil)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let helpVC = segue.destination as? HelpViewController {
      helpVC.helpText =
        """
          This screen is a checklist of doses to take. Here is how to ensure you take all your medication as the day goes on:

          As you take each dose, tap the dose here to check it off. If you tap the wrong one, tap again to uncheck it.

          The >>> indicator points at your next dose today. If you have a lot of doses, this helps you keep track that you didn't miss one early on.

          Each time of day says how many items are remaining for that time.

          ## Related Screens

          More medications and prescriptions can be added in the Medications tab.

          These logs can be exported in the Faxing tab.
        """.renderMarkdownAsAttributedString
      helpVC.title = "\(tabBarItem.title ?? "") Tab Help"
      return
    }
  }


  @IBAction func unwindToPrescriptionList(segue:UIStoryboardSegue){
    //If we're getting this, it's from the inital onboarding add, so we need to tell the user to add further elsewhere.
    alertUserOfFirstSave()


    let rxEntryVC = segue.source as! PrescriptionEntryViewController
    var prescriptions = LocalStorage.prescriptions.load()
    prescriptions.append(rxEntryVC.prescription!)
    LocalStorage.prescriptions.save(prescriptions)

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

  func createImage(borderColor: UIColor, borderWidth: CGFloat, cornerRadius:CGFloat, buttonSize: CGSize,backgroundColor:UIColor) -> UIImage  {
    UIGraphicsBeginImageContextWithOptions(buttonSize, true, 0.0)
    backgroundColor.setFill()
    let rect = CGRect(origin:.zero, size:buttonSize)
    let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    borderColor.setStroke()
    backgroundColor.setFill()
    bezierPath.fill()
    bezierPath.stroke()
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    return image
  }
  
  func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {

    return createImage(borderColor:Asset.Colors.vlWarmTintColor.color,
                       borderWidth:0.5,
                       cornerRadius: 4,
                       buttonSize: CGSize(width:scrollView.frame.size.width-20, height: 50),
                       backgroundColor: Asset.Colors.vlCellBackgroundCommon.color)
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return emptyStateAttributedString("Your daily checklist of medications is shown here after you've added a medication to the app")
  }

  func verticalOffset(forEmptyDataSet scrollView:UIScrollView)->CGFloat{
    return -110
  }


  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    performSegue(withIdentifier: "addPrescriptionSegue", sender: self)
  }

  func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
    return true
  }
}

