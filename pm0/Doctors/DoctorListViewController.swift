//
//  DoctorListViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit


class DoctorListViewController:UITableViewController{

  var doctors = [DoctorInfo]()
  let editSegueIdentifier = "editDoctorSegue"
  var lastTappedDoctorIndex:Int? = nil

  override func viewWillAppear(_ animated: Bool) {
    doctors = LocalStorage.LoadDoctors()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //remove excess lines
  }

  @IBAction func plusTapped(_ sender: Any) {
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

  func prepareToEdit(segue:UIStoryboardSegue, doctorInfoAtIndex:Int){
    guard segue.identifier == editSegueIdentifier,
          let doctorEntryViewController = segue.destination as? DoctorEntryViewController else {
      return
    }
    doctorEntryViewController.doctor = doctors[doctorInfoAtIndex]
  }



  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == editSegueIdentifier{
      guard let lastTappedDoctorIndex = lastTappedDoctorIndex else{
        return
      }
      prepareToEdit(segue: segue, doctorInfoAtIndex: lastTappedDoctorIndex)
    }
    else{
      lastTappedDoctorIndex = nil
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return doctors.count
  }

  static var cellIdentifier = "DoctorSubtitleCell"
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DoctorListViewController.cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: DoctorListViewController.cellIdentifier)

    cell.textLabel?.text = doctors[indexPath.row].name
    cell.detailTextLabel?.text = doctors[indexPath.row].specialty
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    lastTappedDoctorIndex = indexPath.row
    performSegue(withIdentifier: editSegueIdentifier, sender: self)
  }

  @IBAction func unwindToDoctorList(segue:UIStoryboardSegue){
    guard segue.identifier == "savedDoctorEditOrNew" else{
      return
    }
    let doctorItem = (segue.source as! DoctorEntryViewController).doctor
    if let lastTappedDoctorIndex = lastTappedDoctorIndex {
      doctors[lastTappedDoctorIndex] = doctorItem
    } else {
      doctors.append(doctorItem)
    }
    LocalStorage.SaveDoctors(doctors)
    tableView.reloadData()
  }

}
