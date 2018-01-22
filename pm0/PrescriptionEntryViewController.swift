//
//  PrescriptionEntryViewController.swift
//  pm0
//
//  Created by Michael Langford on 1/22/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class PrescriptionEntryViewController: UIViewController {

  @IBOutlet weak var medicationNameField:UITextField!

  var medicationName:String?{
    return medicationNameField?.text
  }
}
