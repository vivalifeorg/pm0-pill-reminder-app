//
//  DoctorListViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class DoctorListViewController:UITableViewController{
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.tableFooterView = UIView() //remove excess lines

  }

  @IBAction func plusTapped(_ sender: Any) {
    showUnimplemented()
  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
    return UITableViewAutomaticDimension
  }

  var alert:UIAlertController! = nil

  func showUnimplemented(){
    alert = UIAlertController(title: "Not Implemented", message: "Feature to come", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: nil)
    }))
    self.present(alert,animated: true)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    showUnimplemented()
  }


}
