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

    tableView.register(UpcomingDayViewControllerDoseCell.self,
                       forCellReuseIdentifier: UpcomingDayViewControllerDoseCell.defaultReuseIdentifier)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  struct Section{
    var headerText:String
    var footerText:String
    var rowCount:Int{return medications.count}
    var medications:[TimeSlotItem]
    var firstUntakenItemIndex:Int?{
      for i in 0..<rowCount{
        if !(medications[i].isTaken){
          return i
        }
      }
      return nil
    }
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

  func calculateSectionFooter(timeSlot:TimeSlot)->String{
    let total = timeSlot.items.reduce(0){
      $1.isTaken ? $0 : $0 + 1
    }
    return "           ^ \(total) remaining"
  }

  func sectionsForSchedule(timeSlots:[TimeSlot])->[Section]{
    return timeSlots.map{
      Section(headerText: $0.slotDescription,
              footerText: calculateSectionFooter(timeSlot: $0),
              medications: $0.items)
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
    for item in hardcodedSectionInfo{
      let hour = item.2
      let minute = item.3
      let offset = minuteOffset(hour:hour,minute:minute)
      names[offset] = item.0
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

  var hardcodedSectionInfo:[(String,String,Int,Int)] = [
    ("Wake-up","7 am",7,0),
    ("Breakfast","8 am",8,0),
    ("Morning Snack", "10 am",10,0),
    ("Lunch","Noon",12,0),
    ("Afternoon Snack","3 pm",15,0),
    ("Dinner","6 pm",18,0),
    ("Bedtime","10 pm",22,0)
  ]

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
    cell.opacity = .bright //TODO set
    cell.isIndicated = (section.firstUntakenItemIndex == indexPath.row)
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

}