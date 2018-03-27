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

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    updateDoctorItem()
  }

  override func viewDidLoad() {
    updateView()
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
    doctor = newDoctor
  }
}
