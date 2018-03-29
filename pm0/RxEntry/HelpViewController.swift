//
//  PrescriptionEntryHelpViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/22/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//
import UIKit

class HelpViewController:UIViewController {
  @IBOutlet weak var helpLabel:UILabel!

  var helpText:NSAttributedString = NSAttributedString() {
    didSet{
      helpLabel?.attributedText = helpText
    }
  }

  override func viewDidLoad() {
    helpLabel.attributedText = helpText
  }
}
