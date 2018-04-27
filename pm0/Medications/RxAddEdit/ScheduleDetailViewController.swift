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

  var textFieldDidChange:(UITextField)->() = { _ in }

  @objc func textFieldDidChangeHandler(_ textField:UITextField){
    textFieldDidChange(textField)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    nameField.addTarget(
      self,
      action: #selector(ScheduleDetailNameCell.textFieldDidChangeHandler(_:)),
      for: UIControlEvents.editingChanged
    )
  }
}

class ScheduleDetailViewController:UITableViewController{

  @IBOutlet weak var saveButton:UIBarButtonItem!
  func textFieldDidChange(_ textField:UITextField){
    schedule.name = textField.text ?? ""
  }

  var isShowingCustom:Bool{
    return !userTimeslots.isEmpty
  }

  private var userTimeslots:[Timeslot] = LocalStorage.TimeslotStore.User.load()
  private var defaultTimeslots:[Timeslot] = LocalStorage.TimeslotStore.System.load()

  // Custom timeslots are above system timeslots so the user is more likely to see them
  private var timeslotDatasource:[[Timeslot]] {
    if isShowingCustom {
      return [[], userTimeslots, defaultTimeslots]
    }else{
      return [[], defaultTimeslots]
    }
  }

  var schedule:Schedule = Schedule(name:"",aliases:[],timeslots:[])

  func accessoryFor(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCellAccessoryType {
    guard indexPath.section != 0 else{
      return .none
    }
    
    let timeslot = timeslotDatasource[indexPath.section][indexPath.row]
    return schedule.timeslots.reduce(false){$0 || $1 == timeslot} ? .checkmark : .none
  }

  func updateSave(){
    saveButton.isEnabled = !schedule.timeslots.isEmpty
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    guard indexPath.section != 0 else{
      return
    }

    if accessoryFor(tableView,indexPath:indexPath) == .checkmark {
      let timeslot = timeslotDatasource[indexPath.section][indexPath.row]
      schedule.timeslots = schedule.timeslots.filter{$0 != timeslot}
    }else{
      schedule.timeslots.append(timeslotDatasource[indexPath.section][indexPath.row])
    }
    updateSave()
    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : timeslotDatasource[section].count
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return timeslotDatasource.count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section{
    case 0:
      return ""
    case 1:
      return "Custom Timeslots"
    case 2:
      return "Standard Timeslots"
    default:
      return ""
    }
  }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
      switch section{
      case 0:
        return ""
      case 1:
        return ""
      case 2:
        return ""
      default:
        return ""
      }
  }


  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleDetailNameCell", for: indexPath)  as! ScheduleDetailNameCell
      cell.nameField?.text = schedule.name
      cell.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      cell.nameField?.textColor = Asset.Colors.vlEditableTextColor.color
      cell.nameField?.backgroundColor = Asset.Colors.vlCellBackgroundCommon.color
      cell.nameField?.placeholder = "e.g. Before Meetings"
      cell.nameField?.placeholderColor = UIColor.darkGray
      cell.textFieldDidChange = self.textFieldDidChange(_:)
      cell.selectionStyle = .none
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
      cell.accessoryType = accessoryFor(tableView, indexPath: indexPath)
      cell.selectedBackgroundView = UIView()
      return cell
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == StoryboardSegue.PrescriptionEntryViewController.savingScheduleSegue.rawValue {
      schedule.ensureNonEmptyName()

      var userSchedules = LocalStorage.ScheduleStore.User.load()
      userSchedules.insert(schedule, at: 0)
      LocalStorage.ScheduleStore.User.save(userSchedules)
    }
  }
  
}

extension UITextField {
  @IBInspectable var placeholderColor: UIColor {
    get {
      return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? UIColor.clear
    }
    set {
      guard  attributedPlaceholder != nil else { return }
      let attributes: [NSAttributedStringKey : UIColor] = [.foregroundColor : newValue]
      attributedPlaceholder = NSAttributedString(string: attributedPlaceholder!.string, attributes: attributes)
    }
  }
}
