//
//  SecondViewController.swift
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit


class UpcomingDayViewControllerDoseCell:UITableViewCell{

  @IBOutlet weak var nextDoseIndicator:UILabel!
  @IBOutlet weak var dosageLabel: PillDisplayLabel!

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

  var opacity:Opacity {
    set{
      switch newValue{
      case .bright:
        contentView.alpha = 1.0
      case .dim:
        contentView.alpha = 0.4
      }
    }
    get{
      return (dosageLabel.alpha < 1.0) ? .dim : .bright
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
    tableView.sectionHeaderHeight = 40
    tableView.allowsSelection = true

    tableView.register(UpcomingDayViewControllerDoseCell.self,
                       forCellReuseIdentifier: UpcomingDayViewControllerDoseCell.defaultReuseIdentifier)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


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
    var headerText:String
    var footerText:String
    var rowCount:Int{return medications.count}
    var medications:[TimeSlotItem]
    var isActive:(Date)->Bool
  }

  var scheduledDosages:[Dosage]=[] {
    didSet{
      let appliedSchedule = scheduleForDate(Date(),drugs:scheduledDosages)
      debugPrint(appliedSchedule)
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
    let name:String
    var isTaken:Bool
  }

  func calculateSectionFooter(timeSlotItems:[TimeSlotItem])->String{
    let total = timeSlotItems.reduce(0){
      $1.isTaken ? $0 : $0 + 1
    }
    let leader = "           "
    if total == 0 {
      return "\(leader)^Completed!"
    }
    return "\(leader)^\(total) remaining"
  }

  func sectionsForSchedule(timeSlots:[TimeSlot])->[Section]{
    return timeSlots.map{
      let startTime = $0.date
      let minutesBefore = 60.0
      let minutesAfterSlotStart = 60.0
      let activeStart = startTime.addingTimeInterval(-minutesBefore * 60.0)
      let activeStop = startTime.addingTimeInterval(minutesAfterSlotStart * 60.0)
      //debugPrint("\(activeStart) \(activeStop) for \(startTime)")
      return Section(headerText: $0.slotDescription,
              footerText: calculateSectionFooter(timeSlotItems: $0.items),
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

      let displayable = dosesAtTime.map{ TimeSlotItem(name:$0.name,isTaken:false) }
      let timeSlot = TimeSlot(name:names[minuteOffset],
                             date:timeSlotDate,
                             items:displayable)
      timeSlots.append(timeSlot)

      debugPrint("\(thisTime.hour!):\(thisTime.minute!) \(timeSlot)")
    }

    return timeSlots
  }



  var sections:[Section] = [] {
    didSet{
      self.tableView?.reloadData()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    scheduledDosages = global_allDrugs
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
    let dosage = section.medications[indexPath.row]
    cell.dosageLabel?.text = dosage.name
    cell.isTaken = dosage.isTaken
    cell.opacity = section.isActive(Date()) ? .bright : .dim
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

  override func tableView(_ tableView:UITableView, titleForHeaderInSection sectionIndex: Int) -> String{
    return sections[sectionIndex].headerText
  }

  override func tableView(_ tableView:UITableView, titleForFooterInSection sectionIndex: Int) -> String{
    return sections[sectionIndex].footerText
  }
}

//UITableView Delegate
extension UpcomingDayViewController{

  func updateSections(_ tableView:UITableView,sectionsToUpdate:[Int]){
     tableView.reloadSections(IndexSet(sectionsToUpdate), with: UITableViewRowAnimation.automatic)

    UIView.setAnimationsEnabled(false)
    tableView.beginUpdates()

      for sectionIndex in sectionsToUpdate{

        if let containerView = tableView.footerView(forSection: sectionIndex) {
          let newFooterText = calculateSectionFooter(timeSlotItems: sections[sectionIndex].medications)
          sections[sectionIndex].footerText = newFooterText
          containerView.textLabel!.text = newFooterText
        containerView.sizeToFit()
      }
    }
    tableView.endUpdates()
    UIView.setAnimationsEnabled(true)

  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let oldIndicatorTarget = firstUntakenItem
    sections[indexPath.section].medications[indexPath.row].isTaken =
      !sections[indexPath.section].medications[indexPath.row].isTaken
    let newIndicatorTarget = firstUntakenItem
    let toReload = [oldIndicatorTarget,newIndicatorTarget].flatMap{$0?.section}

    updateSections(tableView,sectionsToUpdate: toReload)
  }
}
