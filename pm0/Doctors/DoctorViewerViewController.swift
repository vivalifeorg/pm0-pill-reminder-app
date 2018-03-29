//
//  DoctorViewerViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/29/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import MapKit



extension Address{
  var isMappable:Bool{
    return false
  }
  var annotation:MKPlacemark{
    return MKPlacemark()
  }
  var isDisplayable:Bool{
    return !(street + streetCont + city + state + ZIP).isEmpty
  }

  var displayable:String{
    let street2 = streetCont.count > 0 ? "\(streetCont)\n" : ""

    let result =
    """
    \(street+street2)
    \(city), \(state). \(ZIP)
    """
    return result
  }
}

class DoctorViewerViewController:UITableViewController{

  @IBOutlet weak var map:MKMapView!
  @IBOutlet weak var mapCell:UITableViewCell!
  @IBOutlet weak var faxButtonCell:UITableViewCell!

  @IBOutlet weak var nameLabel:UILabel!

  @IBOutlet weak var drivingDirectionsButton:UIButton!

  @IBOutlet weak var faxLabel:UILabel!
  @IBOutlet weak var faxCell:UITableViewCell!

  @IBOutlet weak var phoneLabel:UILabel!
  @IBOutlet weak var phoneCell:UITableViewCell!

  @IBOutlet weak var addressLabel:UILabel!
  @IBOutlet weak var addressCell:UITableViewCell!

  @IBOutlet weak var specialityLabel:UILabel!
  @IBOutlet weak var specialityCell:UITableViewCell!

  var doctor:DoctorInfo?{
    didSet{
      guard let newDoctor = doctor else{
        return
      }

      loadDoctor(newDoctor)
    }
  }

  func loadDoctor(_ doctor:DoctorInfo){
    guard isViewLoaded else {
      return
    }


    if doctor.address.isMappable {
      map.showAnnotations([doctor.address.annotation], animated: false)
    }
    map.isUserInteractionEnabled = doctor.address.isMappable
    drivingDirectionsButton.isEnabled = doctor.address.isMappable


    nameLabel.text = doctor.name

    addressLabel.text = doctor.address.displayable
    //addressCell.isHidden = !doctor.address.isDisplayable

    phoneLabel.text = doctor.phone.number
    //phoneCell.isHidden = !(doctor.phone.number.count > 0)

    specialityLabel.text = doctor.specialty
    //specialityCell.isHidden = !(doctor.specialty.count > 0)

    faxLabel.text = doctor.fax.number
  //  faxCell.isHidden = !(doctor.fax.number.count > 0)
 //   faxButtonCell.isHidden = !(doctor.fax.number.count > 0)
  }

  override func viewDidLoad() {
    guard let doctor = doctor else {
      return
    }

    loadDoctor(doctor)
  }
}
