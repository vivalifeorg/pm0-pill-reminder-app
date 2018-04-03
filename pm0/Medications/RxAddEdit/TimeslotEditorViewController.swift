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
  var runningTop:CGFloat = 27 //avoids titleText
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


class TimeslotEditorViewController:UITableViewController{


  var datePicker:UIDatePicker? = nil
  var timeslots:[[Timeslot]] = [LocalStorage.Timeslot.User.load(),
                                LocalStorage.Timeslot.System.load()]

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
    guard userProposedName != "" else {
      return "Timeslot-\(UUID().uuidString.dropLast(31))"
    }

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

  func saveTimeslotChanges(indexPath:IndexPath){

    if areTimeslotsOrderedMonotonically{
      tableView.reloadRows(at: [indexPath], with: .none)
    }else{
      timeslots[indexPath.section] = timeslots[indexPath.section].sorted
      let rowIndexes = 0..<(tableView.numberOfRows(inSection: indexPath.section))
      let sectionIndexPaths = rowIndexes.map{ IndexPath(indexes: [indexPath.section, $0])}
      tableView.reloadRows(at: sectionIndexPaths, with: .automatic)
    }

    LocalStorage.Timeslot.User.save(timeslots[0])
    LocalStorage.Timeslot.System.save(timeslots[1])
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
                                       title:"Editing Timeslot \"\(timeslot.name ?? "Slot")\"",
    message:""){ hourOffset, minuteOffset, nameUpdate in

      if let hourOffset=hourOffset,
        let minuteOffset=minuteOffset{
        self.timeslots[indexPath.section][indexPath.row].hourOffset = hourOffset
        self.timeslots[indexPath.section][indexPath.row].minuteOffset = minuteOffset
        self.saveTimeslotChanges(indexPath: indexPath)
      }else if let nameUpdate=nameUpdate {
        self.timeslots[indexPath.section][indexPath.row].name = self.fixedTimeslotName(nameUpdate,at:indexPath)
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

extension TimeslotEditorViewController: UIPickerViewDelegate{


  func showDatePicker(){
    let message = "\n\n\n\n\n\n"
    let alert = UIAlertController(title: "Please Select City", message: message, preferredStyle: UIAlertControllerStyle.actionSheet)

    let okAction = UIAlertAction(title: "OK", style: .default, handler: {
      (alert: UIAlertAction!) -> Void in
      //Perform Action
    })
    alert.addAction(okAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    alert.addAction(cancelAction)
    self.parent!.present(alert, animated: true, completion:nil)
 }

}
