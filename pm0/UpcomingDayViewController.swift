//
//  SecondViewController.swift
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//

import UIKit

class UpcomingDayViewController: UITableViewController {

  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.backgroundColor = VLColors.background
    tableView.separatorColor = UIColor.lightGray
    tableView.sectionHeaderHeight = 40
  }


  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

