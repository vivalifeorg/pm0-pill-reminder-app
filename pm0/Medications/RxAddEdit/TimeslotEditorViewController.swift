//
//  TimeslotEditorViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit


class TimeslotEditorViewController:UITableViewController{
  @IBAction func didSelectTimeItem(){
    datePicker?.datePickerMode = .time
   // alert.add
  }

  var datePicker:UIDatePicker? = nil
  var timeslots:[[Timeslot]] = [LocalStorage.Timeslot.User.load(),
                                LocalStorage.Timeslot.System.load()]


  var timeslotActionSheet = UIAlertController()
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let slotName = "Wake-up test"
    timeslotActionSheet = UIAlertController(title:"Change time of day for \"\(slotName)\"",
      message:nil,
      preferredStyle: .actionSheet
    )
    timeslotActionSheet.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.timeslotActionSheet.dismiss(animated: true, completion: nil)
    }))
    let midnight = Date()
    let slotDate = Date()
    let secondBeforeMidnight = Date()
    alert.addDatePicker(mode: .time, date: slotDate, minimumDate: midnight, maximumDate: secondBeforeMidnight) { (date:Date) in
      print("date: \(date)")
      let components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date)
      self.timeslots[indexPath.section][indexPath.row].hourOffset = components.hour ?? 12
      self.timeslots[indexPath.section][indexPath.row].minuteOffset = components.minute ?? 00
    }
    present(alert, animated:true)
  }

  func showUnimplemented(){
    alert = UIAlertController(title: "Not Implemented", message: "Feature to come", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: nil)
    }))
    alert.addDatePicker(mode: .time, date: Date(), minimumDate: Date(), maximumDate: Date().addingTimeInterval(1000000.0)) { (date) in
      print("date: \(date)")
    }
    self.present(alert,animated: true)
  }

  var alert = UIAlertController()
  @IBAction func notImplementedTapped(_ sender:UIButton!){
    showUnimplemented()
  }
}
