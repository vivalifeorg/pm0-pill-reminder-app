//
//  ScheduleList.swift
//  pm0
//
//  Created by Michael Langford on 4/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

var defaultSchedules = [
  Schedule(name:"When I wake up in the morning",
           aliases:["Once per day",
                    "Immeadiately upon awakening",
                    "Before breakfast",
                    "First thing"], timeslots: [StandardTimeslots.wakeUp]),
  Schedule(name:"With Breakfast",
           aliases:["Once a day with food",
                    "Early in the day with food",
                    "First thing in the morning with food"], timeslots: [StandardTimeslots.breakfast]),
  Schedule(name:"With Lunch",
           aliases:["Once a day with food",
                    "Early in the day with food",
                    "Avoid taking with alcohol"], timeslots: [StandardTimeslots.lunch]),
  Schedule(name:"With Breakfast and Dinner",
           aliases:["Twice a day with food",
                    "At least 6 hours apart",
                    "At least 4 hours apart"], timeslots: [StandardTimeslots.breakfast,StandardTimeslots.dinner])
]

class ScheduleListViewController:UITableViewController{
  var scheduleSelection:Schedule? = nil {
    didSet{
      guard let scheduleSelection = scheduleSelection else{
        return
      }
      entryInfo?.scheduleSelection = scheduleSelection
    }
  }

  var entryInfo:EntryInfo?

  func loadSchedules(){
     customSchedules = LocalStorage.ScheduleStore.User.load()
     standardSchedules = LocalStorage.ScheduleStore.Standard.load()
  }
  private var customSchedules:[Schedule] = []
  private var standardSchedules:[Schedule] = []

  private var scheduleDatasource:[[Schedule]] {
    if isShowingCustom {
      return [customSchedules,standardSchedules]
    }else{
      return [standardSchedules]
    }
  }

  private var isShowingCustom:Bool {
    return customSchedules.count > 0
  }

  private var sectionNameDatasource:[String] {
    if isShowingCustom {
      return ["Custom Schedules", "Standard Schedules"]
    } else {
      return ["Standard Schedules"]
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    loadSchedules()
    tableView.reloadData()
    super.viewWillAppear(animated)
  }
  override func viewDidLoad() {
    if standardSchedules.count == 0 {
      LocalStorage.ScheduleStore.Standard.save(defaultSchedules)
      standardSchedules = LocalStorage.ScheduleStore.Standard.load()
      tableView.reloadData()
    }
    
    updateDoneButton()
  }

  private func scheduleForIndexPath(_ indexPath:IndexPath) -> Schedule {
    return scheduleDatasource[indexPath.section][indexPath.row]
  }

  @IBOutlet weak var doneButton: UIBarButtonItem!
  func updateDoneButton(){
    doneButton.isEnabled = (scheduleSelection != nil)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    scheduleSelection = scheduleForIndexPath(indexPath)
    tableView.reloadData()
    updateDoneButton()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scheduleDatasource[section].count
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return isShowingCustom ? 2 : 1
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionNameDatasource[section]
  }


  func detailTextForSchedule(schedule:Schedule,
                             scheduleHeader:NSAttributedString?=nil)->NSAttributedString{

    let timeslotIndent = NSAttributedString(string:"    ")
    var zebra = Zebra()
    let sortedTimeslots = schedule.timeslots.sorted(by: { (lhs, rhs) -> Bool in
      lhs < rhs
    })
    let timeslots:[NSAttributedString] = sortedTimeslots.map{ (timeslot:Timeslot) in
      if zebra.next(){
        return timeslotIndent + timeslot.floridDescription( backgroundColor:Asset.Colors.vlZebraDarker.color)
      }else{
        return timeslotIndent + timeslot.floridDescription(backgroundColor: Asset.Colors.vlZebraLighter.color)
      }
    }
    let newline = NSAttributedString(string:"\n")

    let otherLines:[NSAttributedString]
    if let scheduleHeader = scheduleHeader {
      otherLines =  [scheduleHeader] + timeslots
    }else{
      otherLines = timeslots
    }
    guard let first = otherLines.first else{
      return NSAttributedString()
    }
    let rest = otherLines.dropFirst()
    return rest.reduce(first){$0 + newline + $1}
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let reuseIdentifier = "SubtitleSchedules"
    let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ??     UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    cell.textLabel?.textColor = Asset.Colors.vlTextColor.color
    cell.detailTextLabel?.textColor = Asset.Colors.vlTextColor.color
    cell.detailTextLabel?.numberOfLines = 0
    cell.detailTextLabel?.lineBreakMode = .byWordWrapping
    cell.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color

    let schedule = scheduleForIndexPath(indexPath)
    cell.textLabel?.text = schedule.title
    //cell.detailTextLabel?.text = schedule.timeslots.map{$0.description}.joined(separator: ", ")
    cell.detailTextLabel?.attributedText = detailTextForSchedule(schedule: schedule)

    let isChecked = (scheduleSelection != nil) &&
                      (scheduleSelection! == scheduleForIndexPath(indexPath))
    cell.accessoryType = isChecked ? .checkmark : .none

    cell.selectedBackgroundView = UIView()
    return cell
  }

  @IBAction func unwindFromEditingSchedule(segue:UIStoryboardSegue){
    customSchedules = LocalStorage.ScheduleStore.User.load()
    tableView.reloadData()
  }

  @IBAction func newScheduleTapped(_:Any){
    performSegue(withIdentifier: "newScheduleDetails", sender: self) //todo, appears to be missing
  }
}
