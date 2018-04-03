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

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    didSelectTimeItem()
    showUnimplemented()
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
