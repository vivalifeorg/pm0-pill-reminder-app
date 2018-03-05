//
//  SecondViewController.swift
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit

class UpcomingDayViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.backgroundColor = VLColors.background
    tableView.separatorColor = UIColor.lightGray
    tableView.sectionHeaderHeight = 40
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  struct Section{
    var name:String
    var headerText:String
    var footerText:String
    var rowCount:Int{return medications.count}
    var medications:[Drug]
  }

  var drugs:[Drug]=[] {
    didSet{
      let appliedSchedule = scheduleForDate(Date(),drugs:drugs)
      debugPrint(appliedSchedule)
    }
  }

  func minuteOffset(hour:Int,minute:Int)->Int{
    return hour * 60 + minute
  }

  struct TimeSlot{
    let name:String?
    let date:Date
    var items:[TimeSlotItem]
    var description:String{
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
    var debugDescription:String{
      return description + ": " + items.debugDescription
    }
  }

  struct TimeSlotItem{
    let name:String
    var isTaken:Bool
  }

  func scheduleForDate(_ date:Date, drugs:[Drug]) -> [TimeSlot] {


    var times:[Int:[Drug]] = [:]
    for drug in drugs{
      for time in drug.timesTaken(for: date){
        var currentListOfDrugsAtTime = times[minuteOffset(hour: time.hour, minute: time.minute)] ?? []
        currentListOfDrugsAtTime.append(drug)
        times[minuteOffset(hour: time.hour, minute: time.minute)] = currentListOfDrugsAtTime
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
  var sections:[Section]=[]

  override func viewDidAppear(_ animated: Bool) {
    drugs = global_allDrugs
  }
}


//UITableView DataSource
extension UpcomingDayViewController{
  override func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingDayViewControllerDoseCell", for: indexPath)
    cell.textLabel?.text = sections[indexPath.section].medications[indexPath.row].name
    return UITableViewCell()
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
