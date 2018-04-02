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
    if customSchedules.count > 0 {
      return [customSchedules,standardSchedules]
    }else{
      return [standardSchedules]
    }
  }

  private var sectionNameDatasource:[String] {
    if customSchedules.count > 0 {
      return ["Custom Schedules", "Standard Schedules"]
    } else {
      return ["Standard Schedules"]
    }
  }

  private func scheduleForIndexPath(_ indexPath:IndexPath) -> Schedule {
    return scheduleDatasource[indexPath.section][indexPath.row]
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    scheduleSelection = scheduleForIndexPath(indexPath)
    tableView.reloadData()
  }

  @IBAction func newScheduleTapped(_:Any){
    performSegue(withIdentifier: "newScheduleDetails", sender: self)
  }
}
