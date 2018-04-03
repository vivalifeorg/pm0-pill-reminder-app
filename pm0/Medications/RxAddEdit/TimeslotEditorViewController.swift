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


func timeConfigurationSheet(currentDate:Date,width:CGFloat, title:String? = "", message:String? = "", completion:@escaping ((HourOffset?,MinuteOffset?)->())) -> UIAlertController {

  //Sizes from experimentation/web quotes about current sizes
  let datePicker = UIDatePicker(frame: CGRect(x:0, y:27, width:width, height: 216))
  datePicker.datePickerMode = .time
  datePicker.timeZone = Calendar.current.timeZone
  datePicker.clipsToBounds = true
  datePicker.date = currentDate

  let alertSheet = UIAlertController(title:title,
                                     message:"",
                                     preferredStyle: .alert)
  alertSheet.view.addSubview(datePicker)
  alertSheet.addAction( UIAlertAction(title: "Done", style: UIAlertActionStyle.default) { _ in
    let components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: datePicker.date)
    completion(components.hour, components.minute)
  })

  let height:NSLayoutConstraint = NSLayoutConstraint(item: alertSheet.view,
                                                     attribute: NSLayoutAttribute.height,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: nil,
                                                     attribute: NSLayoutAttribute.notAnAttribute,
                                                     multiplier: 1,
                                                     constant: 300)
  alertSheet.view.addConstraint(height);
  return alertSheet
}


class TimeslotEditorViewController:UITableViewController{
  @IBAction func didSelectTimeItem(){
    datePicker?.datePickerMode = .time
   // alert.add
  }

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

    saveTimeslotChanges(indexPath: newTimeslotPath)
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

  func saveTimeslotChanges(indexPath:IndexPath){

    if areTimeslotsOrderedMonotonically{
      tableView.reloadRows(at: [indexPath], with: .automatic)
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
    let sheet = timeConfigurationSheet(currentDate:currentDate,
                                       width:view.frame.size.width-20.0,
                                       title:"Editing \(timeslot.name ?? "Slot")",
    message:"Use this to change when you do things (eat, sleep, etc)"){ hourOffset, minuteOffset in
      self.timeslots[indexPath.section][indexPath.row].hourOffset = hourOffset ?? 12
      self.timeslots[indexPath.section][indexPath.row].minuteOffset = minuteOffset ?? 00
      self.saveTimeslotChanges(indexPath:indexPath)
    }
    sheet.addTextField { textField in
      textField.placeholder = "Name of Timeslot"
      textField.text = self.timeslots[indexPath.section][indexPath.row].name

      //TODO fix leak
      _ =  NotificationCenter.default.addObserver(
        forName: NSNotification.Name.UITextFieldTextDidChange,
        object: textField,
        queue: OperationQueue.main) { notification in

          var text = textField.text
          if text == "" {
            text = "Timeslot-\(UUID().uuidString.dropLast(31))"
          }
          self.timeslots[indexPath.section][indexPath.row].name = text
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
