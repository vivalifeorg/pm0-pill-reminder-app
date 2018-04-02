//
//  ScheduleDetailListViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit



@objc class ScheduleDetailNameCell:UITableViewCell{
  @IBOutlet weak var nameField:UITextField!
}

class ScheduleDetailViewController:UITableViewController{

  override func viewDidLoad() {

  }

  var name = "tbd"
  var isShowingCustom:Bool{
    return userTimeslots.count > 0
  }
  private var userTimeslots:[Timeslot] = []
  private var defaultTimeslots:[Timeslot] = Timeslot.sortedDefaultTimeslots
  private var timeslotDatasource:[[Timeslot]] {
    if isShowingCustom {
      return [[],userTimeslots,defaultTimeslots]
    }else{
      return [[],defaultTimeslots]
    }
  }


  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : timeslotDatasource[section].count
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return timeslotDatasource.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section == 0 ? "" : "Timeslots (select multiple as needed)"
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleDetailNameCell", for: indexPath)  as! ScheduleDetailNameCell
      cell.nameField?.text = name
      cell.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      cell.nameField?.textColor = Asset.Colors.vlEditableTextColor.color
      cell.nameField?.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      return cell
    }else {
      let timeslot = timeslotDatasource[indexPath.section][indexPath.row]
      let reuseIdentifier = "ScheduleDetailTimeslotCell"
      let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ??     UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
      cell.textLabel?.text = timeslot.name
      cell.detailTextLabel?.isHidden = false
      cell.detailTextLabel?.text = timeslot.timeString
      cell.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      cell.textLabel?.textColor = Asset.Colors.vlTextColor.color
      cell.textLabel?.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      cell.detailTextLabel?.textColor = Asset.Colors.vlTextColor.color
      cell.detailTextLabel?.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      return cell
    }
  }


  
}
