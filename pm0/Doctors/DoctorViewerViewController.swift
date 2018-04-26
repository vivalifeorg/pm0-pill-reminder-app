//
//  DoctorViewerViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/29/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import MapKit

import CoreTelephony

extension Address{
  var isMappable:Bool{
    return true
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

  var url:URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "maps.apple.com"
    urlComponents.path = "/"

    let addressItem = URLQueryItem(name: "daddr", value: displayable)
    let tItem = URLQueryItem(name: "t", value: "m") //t=m&dirflag=d
    let dirflagItem = URLQueryItem(name: "dirflag", value: "d")
    urlComponents.queryItems = [addressItem,tItem,dirflagItem]

    return urlComponents.url
  }
}


class DoctorAnnotation:NSObject, MKAnnotation{
  public var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
  public var title:String? = ""
  public var subtitle:String? = ""
  override init(){}
}

class DoctorViewerViewController:UITableViewController{

  @IBOutlet weak var map:MKMapView!
  @IBOutlet weak var mapCell:UITableViewCell!
  @IBOutlet weak var faxButtonCell:UITableViewCell!

  @IBOutlet weak var nameLabel:UILabel!

  @IBOutlet weak var drivingDirectionsButton:VivaButtonA!
  @IBOutlet weak var faxHipaaButton :VivaButtonA!
  @IBOutlet weak var faxMedLogButton:VivaButtonA!
 // @IBOutlet weak var faxPatientHistoryButton:VivaButtonA!

  @IBOutlet weak var faxLabel:UILabel!
  @IBOutlet weak var faxCell:UITableViewCell!

  @IBOutlet weak var phoneLabel:UILabel!
  @IBOutlet weak var phoneCell:UITableViewCell!

  @IBOutlet weak var addressLabel:UILabel!
  @IBOutlet weak var addressCell:UITableViewCell!

  @IBOutlet weak var specialityLabel:UILabel!
  @IBOutlet weak var specialityCell:UITableViewCell!

  var geocoder:CLGeocoder? = nil

  var addressPlacemarks:[CLPlacemark] = []{
    didSet{
      
      map.removeAnnotations(map.annotations)
      guard !addressPlacemarks.isEmpty else{
        return
      }

      map.addAnnotations(
        addressPlacemarks.map{ placemark in
          let coordinate = placemark.location?.coordinate ?? CLLocationCoordinate2D()

          let ann = DoctorAnnotation()
          ann.coordinate = coordinate
          ann.title = placemark.name
          ann.subtitle = placemark.thoroughfare
          return ann
          })
      (addressPlacemarks.first?.location?.coordinate).ifNotNil{
        map.setCenter($0, animated: true)
        let region = MKCoordinateRegion(center: $0, span: MKCoordinateSpanMake(0.0675,0.0675) )
        map.setRegion(region, animated: true)
        drivingDirectionsButton.isEnabled = true
        drivingDirectionsButton.setNeedsDisplay()
      }
    }
  }

  var doctor:DoctorInfo?{
    didSet{
      guard let newDoctor = doctor else{
        return
      }

      loadDoctor(newDoctor)
    }
  }

  func showUnimplemented(){
    alert = UIAlertController(title: "Not Implemented",
                              message: "Feature to come",
                              preferredStyle: .alert)

    alert.addAction(UIAlertAction(
      title: "Ok",
      style: .default,
      handler: { (_) in self.alert.dismiss(animated: true,completion: nil)}))
    present(alert, animated: true)
  }

  var alert = UIAlertController()
  @IBAction func notImplementedTapped(_ sender:UIButton!){
    showUnimplemented()
  }

  @objc func cancelFax(){
    presentedViewController?.performSegue(
      withIdentifier: "unwindFromFaxingAfterCancel",
      sender: presentedViewController!
    )
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier{

    case "editDoctor":
      let editor = segue.destination as! DoctorEntryViewController
      editor.doctor = doctor!

    case "sendHipaaReleaseFromDoctorViewer":
      let nav = segue.destination as! UINavigationController

      let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DoctorViewerViewController.cancelFax))

      var dataFrom = nav.viewControllers.first! as! SendableDocumentMetadata & UIViewController
      dataFrom.navigationItem.leftBarButtonItem = cancelButton
      dataFrom.sendableDocumentDestinations = [doctor!].map{
        DocumentDestination(name:$0.name, value:$0.fax.number)
      }

    case "sendMedlogFromDoctorViewer":
      let nav = segue.destination as! UINavigationController

      let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DoctorViewerViewController.cancelFax))

      var dataFrom = nav.viewControllers.first! as! SendableDocumentMetadata & UIViewController
      dataFrom.navigationItem.leftBarButtonItem = cancelButton
      dataFrom.sendableDocumentDestinations = [doctor!].map{
        DocumentDestination(name:$0.name, value:$0.fax.number)
      }

    default:
      print("another segue")
    }
  }

  @IBAction func drivingDirectionsButtonTapped(_ sender:UIButton!){

    guard drivingDirectionsButton.isEnabled else{
      return
    }
    
    guard let url = doctor?.address.url else{
      return
    }
    UIApplication.shared.open(url, options: [:]) { (success) in
      print("It worked? \(success)")
    }
  }

  @IBAction func unwindFromFaxingAfterCancel(segue:UIStoryboardSegue){

  }

  @IBAction func unwindFromFaxingAfterSend(segue:UIStoryboardSegue){

  }

  @IBAction func callPhone(_ sender:UIControl){
    let telUrl:URL? = (doctor?.phone.telURL)
    telUrl.ifNotNil{UIApplication.shared.open($0, options: [:], completionHandler:nil)}
  }

  func canCall(_ telURL:URL?)->Bool{
    guard telURL != nil, UIApplication.shared.canOpenURL(telURL!) else{
      debugPrint("Can't call because open")
      return false
    }

    //is phone able to be used now
    guard let _ = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode else{
      debugPrint("Can't call because no mobile network code")
      return false
    }

    return true
  }

  func loadDoctor(_ doctor:DoctorInfo){
    guard isViewLoaded else {
      return
    }

    map.isUserInteractionEnabled = doctor.address.isMappable
    drivingDirectionsButton.isEnabled = false
    drivingDirectionsButton.setNeedsDisplay()
    nameLabel.text = doctor.name
    addressLabel.text = doctor.address.displayable
    phoneLabel.text = doctor.phone.number
    if canCall(doctor.phone.telURL){
      phoneLabel.textColor = Asset.Colors.vlWarmTintColor.color
      phoneLabel.tintColor = Asset.Colors.vlWarmTintColor.color

      let tap = UITapGestureRecognizer(target: self, action: #selector(DoctorViewerViewController.callPhone))
      tap.numberOfTapsRequired = 1
      phoneLabel.addGestureRecognizer(tap)
    }else{
      phoneLabel.textColor = Asset.Colors.vlTextColor.color
      phoneLabel.tintColor = Asset.Colors.vlTextColor.color
      phoneLabel.gestureRecognizers = nil
    }

    specialityLabel.text = doctor.specialty
    faxLabel.text = doctor.fax.number
    title = doctor.name

    geocoder = CLGeocoder()
    geocoder?.geocodeAddressString(doctor.address.displayable){ placemarks, error in
        error.ifNotNil{ print("Error geocoding: \($0.localizedDescription)") }
        self.addressPlacemarks = placemarks ?? []
    }
  }


  override func viewDidLoad() {
    guard let doctor = doctor else {
      return
    }

    drivingDirectionsButton.setTitleColor(.black, for: .normal)
 drivingDirectionsButton.setBackgroundImage(VivaButtonA.createStandardDisabledBackgroundImage(buttonWidth: drivingDirectionsButton.frame.size.width), for: .disabled)
    drivingDirectionsButton.setNeedsDisplay()
    faxHipaaButton.setTitleColor(.black, for: .normal)
    faxMedLogButton.setTitleColor(.black, for: .normal)
    //faxPatientHistoryButton.setTitleColor(.black, for: .normal)

    loadDoctor(doctor)
  }
}
