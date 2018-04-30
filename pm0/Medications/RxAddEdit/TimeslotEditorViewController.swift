//
//  TimeslotEditorViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit


@objc class DoubleEditableTimeslotCell:UITableViewCell{
  @IBOutlet weak var name:UILabel!
  @IBOutlet weak var time:UILabel!
}

@objc class SinglyEditableTimeslotCell:UITableViewCell{
  @IBOutlet weak var name:UILabel!
  @IBOutlet weak var time:UILabel!
}


func timeConfigurationSheet(currentDate:Date,width:CGFloat, editText:String? = nil, title:String? = "", message:String? = "", updatedValues:@escaping ((HourOffset?,MinuteOffset?,String?)->())) -> UIAlertController {

  let alertSheet = UIAlertController(title:title,
                                     message:"",
                                     preferredStyle: .alert)
  var runningTop:CGFloat = 30 //avoids titleText
  if let startingName = editText {

    alertSheet.addTextField { textField in
      textField.placeholder = "Name of Timeslot"
      textField.text = startingName


      //TODO fix leak
      _ =  NotificationCenter.default.addObserver(
        forName: NSNotification.Name.UITextFieldTextDidChange,
        object: textField,
        queue: OperationQueue.main) { notification in
          updatedValues(nil,nil,textField.text)

      }
    }

    let textFieldSpace:CGFloat = 60.0
    runningTop += (textFieldSpace + 20.0)
  }

  //Sizes from experimentation/web quotes about current sizes
  let datePickerHeight:CGFloat = 216
  let datePicker = UIDatePicker(frame: CGRect(x:0, y:runningTop, width:width, height: datePickerHeight))
  runningTop += datePickerHeight
  datePicker.datePickerMode = .time
  datePicker.timeZone = Calendar.current.timeZone
  datePicker.clipsToBounds = true
  datePicker.date = currentDate


  alertSheet.view.addSubview(datePicker)

  alertSheet.addAction( UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { _ in
    let components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: datePicker.date)
    updatedValues(components.hour, components.minute, nil)
  })



  let height:NSLayoutConstraint = NSLayoutConstraint(item: alertSheet.view,
                                                     attribute: NSLayoutAttribute.height,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: nil,
                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                     multiplier: 1,
                                                     constant: runningTop + 44)
  alertSheet.view.addConstraint(height)


  return alertSheet
}

extension Optional where Wrapped == String{

  func followedByIfNotNil(_ text:String)->String{
    guard let some = self else {
      return ""
    }
    return "\(some)\(text)"
  }

  func appendingIfNotNil(_ text:String?)->String{
    guard let text = text,
          let selftext = self else{
      return ""
    }
    return "\(text)\(selftext)"
  }

  ///This returns an empty string if the string is nil, or the string preceeded by a space if the string if the string is not nil.  Useful for constructing user-facing strings out of String? instances.
  ///  ex: "This is a\(adjective.spaceBeforeValueOrEmpty) dog\(itemName.spaceBeforeValueOrEmpty)"
  ///  will produce these kinds of output: "This is a good dog", "This is a dog",
  ///    "This is a dog bowl, "This is a blue dog bowl"
  var spaceBeforeOrEmpty:String{
    guard self != nil else {
      return ""
    }
    return " \(self!)"
  }

  ///This returns an empty string if the string is nil, or the string followed by a space if the string if the string is not nil.  Useful for constructing user-facing strings out of String? instances.
  ///  ex: "\(dogName.spaceAfterValueOrEmpty)Stats"
  ///  will produce these kinds of output: "Sport Stats", "Spot Status",
  ///    "Mary Stats", "Stats"
  var spaceAfterOrEmpty:String{
    guard self != nil else {
      return ""
    }
    return self.followedByIfNotNil(" ")
  }


}

class TimeslotEditorViewController:UITableViewController{


  var datePicker:UIDatePicker? = nil
  var timeslots:[[Timeslot]] = [LocalStorage.TimeslotStore.User.load(),
                                Timeslot.sortedStandardTimeslots]

  let customSectionIndex = 0

  @IBAction func addCustomTimeslot(_sender:UIBarButtonItem){
    let newTimeslot = Timeslot(name: "", slotType: SlotType.custom, hourOffset: 12, minuteOffset: 00)

    let newTimeslotPath = IndexPath(indexes:[customSectionIndex,timeslots[customSectionIndex].count])
    tableView.beginUpdates()
    timeslots[customSectionIndex].append(newTimeslot)
    tableView.insertRows(at: [newTimeslotPath], with:.right )
    tableView.endUpdates()
    editTimeslotAt(at: newTimeslotPath)
  }

  var areTimeslotsOrderedMonotonically:Bool{
    for section in 0..<numberOfSections(in: tableView){
      if timeslots[section].sorted != timeslots[section]{
        return false
      }
    }
    return true
  }

  override func viewDidLoad() {
    tableView.tableFooterView = UIView() //remove lines
  }


  //prevent timeslots being named the same thing as other things
  func fixedTimeslotName(_ userProposedName:String, at indexPath:IndexPath)->String{

    for section in 0..<numberOfSections(in: tableView){
      for row in 0..<tableView(tableView, numberOfRowsInSection: section){
        if indexPath.row == row && indexPath.section == section {
          continue
        }

        let slotName = timeslots[section][row].name
        if slotName == userProposedName {
          return fixedTimeslotName("\(userProposedName)'", at:indexPath)
        }
      }
    }
    return userProposedName
  }

  func saveTimeslotChanges(indexPath:IndexPath,oldName:String?, newName:String?){

    if areTimeslotsOrderedMonotonically{
      tableView.reloadRows(at: [indexPath], with: .none)
    }else{
      timeslots[indexPath.section] = timeslots[indexPath.section].sorted
      let rowIndexes = 0..<(tableView.numberOfRows(inSection: indexPath.section))
      let sectionIndexPaths = rowIndexes.map{ IndexPath(indexes: [indexPath.section, $0])}
      tableView.reloadRows(at: sectionIndexPaths, with: .automatic)
    }

    LocalStorage.TimeslotStore.User.save(timeslots[0])
    LocalStorage.TimeslotStore.Standard.save(timeslots[1])

    var timeslotsByName:[String:Timeslot] = [:]
    let allTimeslots = timeslots[0] + timeslots[1]
    for timeslot in allTimeslots{
      //changing names
      if timeslot.name == newName,
        let oldName = oldName,
        let newName = newName{
        var updatedTimeslot = timeslot
        updatedTimeslot.name = newName
        timeslotsByName[oldName] = updatedTimeslot // We have to index using the old name to find it
      }else{
        //changing times/other part of changing names for non-changed items
        timeslotsByName[timeslot.name] = timeslot
      }
    }

    //Update old user schedules
    let oldUserSchedules:[Schedule] = LocalStorage.ScheduleStore.User.load()
    let newUserSchedules:[Schedule] = oldUserSchedules.map{ (oldSchedule:Schedule) in
      var newSchedule = oldSchedule //make a copy
      newSchedule.timeslots = oldSchedule.timeslots.map{timeslotsByName[$0.name] ?? $0} //replace them by name
      return newSchedule
    }
    LocalStorage.ScheduleStore.User.save(newUserSchedules)

    //Update old standard schedules
    let oldStandardSchedules:[Schedule] = LocalStorage.ScheduleStore.Standard.load()
    let newStandardSchedules:[Schedule] = oldStandardSchedules.map{ (oldSchedule:Schedule) in
      var newSchedule = oldSchedule //make a copy
      newSchedule.timeslots = oldSchedule.timeslots.map{timeslotsByName[$0.name] ?? $0} //replace them by name
      return newSchedule
    }
    LocalStorage.ScheduleStore.Standard.save(newStandardSchedules)

    var schedulesByName:[String:Schedule] = [:]
    let allSchedules = newUserSchedules + newStandardSchedules
    for schedule in allSchedules{
      schedulesByName[schedule.name] = schedule
    }

    //update old prescriptions with new schedules/timeslots
    let oldUserPrescriptions:[Prescription] = LocalStorage.PrescriptionStore.load()
    let newUserPrescriptions:[Prescription] = oldUserPrescriptions.map{ (oldPrescription:Prescription) in
      var newPrescription = oldPrescription //make a copy
      if var dosage = oldPrescription.dosage{
        if let schedule = schedulesByName[dosage.schedule.name] {
          dosage.schedule = schedule
          newPrescription.dosage = dosage
        }
      }
      return newPrescription
    }
    LocalStorage.PrescriptionStore.save(newUserPrescriptions)


  }

  func editTimeslotAt(at indexPath:IndexPath){
    let timeslot = timeslots[indexPath.section][indexPath.row]
    var components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: Date())
    components.hour = timeslot.hourOffset
    components.minute = timeslot.minuteOffset
    let currentDate = components.date!
    let editableName = (indexPath.section == customSectionIndex) ? timeslot.name : nil
    let sheet = timeConfigurationSheet(currentDate:currentDate,
                                       width:view.frame.size.width-20.0,
                                       editText:editableName,
                                       title:"Editing \"\(timeslot.name)\"",
    message:""){ hourOffset, minuteOffset, nameUpdate in

      if let hourOffset=hourOffset,
        let minuteOffset=minuteOffset{
        self.timeslots[indexPath.section][indexPath.row].hourOffset = hourOffset
        self.timeslots[indexPath.section][indexPath.row].minuteOffset = minuteOffset
        self.saveTimeslotChanges(indexPath: indexPath,oldName:nil, newName:nil)
      }else if let nameUpdate=nameUpdate {
        let oldName = self.timeslots[indexPath.section][indexPath.row].name
        let newName = self.fixedTimeslotName(nameUpdate,at:indexPath)
        self.timeslots[indexPath.section][indexPath.row].name = newName
        self.saveTimeslotChanges(indexPath: indexPath,
                                 oldName:oldName,
                                 newName:newName)
      }
    }


    present(sheet,animated:true)
  }
  var timeslotActionSheet = UIAlertController()
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    editTimeslotAt(at:indexPath)
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return timeslots.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timeslots[section].count
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section{
    case customSectionIndex where timeslots[customSectionIndex].isEmpty:
      return ""
    case customSectionIndex:
      return "Custom Timeslots"
    default:
      return "Standard Timeslots"
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let timeslot = timeslots[indexPath.section][indexPath.row]
    if indexPath.section == customSectionIndex{
      let cell = tableView.dequeueReusableCell(withIdentifier: "DoubleEditableTimeslotCell", for: indexPath) as! DoubleEditableTimeslotCell
      cell.name.text = timeslot.name
      cell.time.text = timeslot.timeString
      return cell
    }else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "SinglyEditableTimeslotCell", for: indexPath) as! SinglyEditableTimeslotCell
      cell.name.text = timeslot.name
      cell.time.text = timeslot.timeString
      return cell
    }
  }

  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    guard indexPath.section == customSectionIndex else{
      return []
    }

    return [
      UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteTimeslotTableRowAction),
    ]
  }

  var deleteConfirmController:UIAlertController? = nil
  func deleteTimeslotTableRowAction(_ action:UITableViewRowAction, indexPath:IndexPath){
    // delete item at indexPath
    let timeslot = timeslots[indexPath.section][indexPath.row]
    let alert = UIAlertController(title: "Delete Timeslot?",                                  message: "Are you sure you want to delete \(timeslot.name)?",
                                  preferredStyle: .alert)

    alert.addAction(
      UIAlertAction(title: NSLocalizedString("Keep Timeslot",
                                             comment: "Keep Timeslot"),
                    style: .cancel,
                    handler:nil)
    )

    alert.addAction(
      UIAlertAction(title: NSLocalizedString("Delete Timeslot",
                                             comment: "Delete it"),
                    style: .destructive){ _ in
                      self.timeslots[indexPath.section].remove(at: indexPath.row)
                      self.tableView.deleteRows(at: [indexPath], with: .fade)
      }
    )

    self.deleteConfirmController = alert
    self.present(deleteConfirmController!, animated: true, completion: nil)
  }




  func showUnimplemented(){
    alert = UIAlertController(title: "Not Implemented", message: "Feature to come", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: nil)
    }))

    self.present(alert,animated: true)
  }

  var alert = UIAlertController()
  @IBAction func notImplementedTapped(_ sender:UIButton!){
    showUnimplemented()
  }
}

