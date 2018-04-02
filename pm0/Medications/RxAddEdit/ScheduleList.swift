//
//  ScheduleList.swift
//  pm0
//
//  Created by Michael Langford on 4/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit



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

  private var customSchedules:[Schedule] = []
  private var standardSchedules:[Schedule] = schedules
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

  override func viewDidLoad() {
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

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = "SubtitleSchedules"
    let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ??     UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    cell.textLabel?.textColor = Asset.Colors.vlTextColor.color
    cell.detailTextLabel?.textColor = Asset.Colors.vlTextColor.color
    cell.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color

    let schedule = scheduleForIndexPath(indexPath)
    cell.textLabel?.text = schedule.title
    cell.detailTextLabel?.text = schedule.events.map{$0.description}.joined(separator: ", ")

    let isChecked = scheduleSelection != nil && scheduleSelection! == scheduleForIndexPath(indexPath)
    cell.accessoryType = isChecked ? .checkmark : .none

    cell.selectedBackgroundView = UIView()
    return cell
  }



  @IBAction func newScheduleTapped(_:Any){
    performSegue(withIdentifier: "newScheduleDetails", sender: self)
  }
}
