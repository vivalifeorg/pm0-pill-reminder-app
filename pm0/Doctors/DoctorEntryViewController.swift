//
//  DoctorEntryViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/27/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class DoctorEntryViewController:UITableViewController{
  @IBOutlet weak var nameLabel:PrescriptionLineEntry!
  @IBOutlet weak var specialtyLabel:PrescriptionLineEntry!
  @IBOutlet weak var addressLabel:PrescriptionLineEntry!
  @IBOutlet weak var addressContLabel:PrescriptionLineEntry!
  @IBOutlet weak var stateLabel:PrescriptionLineEntry!
  @IBOutlet weak var zipLabel:PrescriptionLineEntry!
  @IBOutlet weak var phoneLabel:PrescriptionLineEntry!
  @IBOutlet weak var faxLabel:PrescriptionLineEntry!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    updateDoctorItem()
  }


  func hideHelpers(){
    let entryLabels = [
      nameLabel,specialtyLabel,addressLabel,addressContLabel,stateLabel,
      zipLabel,phoneLabel,faxLabel
    ]
    for entry in entryLabels{
      entry?.showHelpButton.isHidden = true
    }
  }

  override func viewDidLoad() {
    updateView()
    hideHelpers()
  }

  var doctor:DoctorInfo = DoctorInfo() {
    didSet{
      guard isViewLoaded else{
        return
      }
      updateView()
    }
  }

  func updateView(){
    nameLabel?.searchTextField.text = doctor.name
    specialtyLabel?.searchTextField.text = doctor.specialty
    addressLabel?.searchTextField.text = doctor.address.street
    addressContLabel?.searchTextField.text = doctor.address.streetCont
    stateLabel?.searchTextField.text = doctor.address.state
    zipLabel?.searchTextField.text = doctor.address.ZIP
  }

  func updateDoctorItem(){
    var newDoctor = DoctorInfo()
    newDoctor.name = nameLabel?.searchTextField.text ?? ""
    newDoctor.specialty = specialtyLabel?.searchTextField.text ?? ""
    newDoctor.address.street = addressLabel?.searchTextField.text ?? ""
    newDoctor.address.streetCont = addressContLabel?.searchTextField.text ?? ""
    newDoctor.address.state = stateLabel?.searchTextField.text ?? ""
    newDoctor.address.ZIP = zipLabel?.searchTextField.text ?? ""
    newDoctor.phone.number = phoneLabel?.searchTextField.text ?? ""
    newDoctor.fax.number = faxLabel?.searchTextField.text ?? ""
    doctor = newDoctor
  }
}
