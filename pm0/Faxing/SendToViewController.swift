//
//  SendToViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class SendToViewController:UITableViewController{

  var pdfs:[DocumentRef] = []

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as? (PDFHandler & SendableDocumentMetadata)
    handler?.addPDFs(pdfs)
    handler?.sendableDocumentDestinations.append(
      contentsOf:selectedDoctors.map{doctors[$0.row].fax.number}
    )
  }

  var doctors:[DoctorInfo] = []

  var selectedDoctors:[IndexPath] = []

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return doctors.count
  }

  override func viewWillAppear(_ animated: Bool) {
    doctors = LocalStorage.DoctorStore.load()
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //remove excess lines
  }


  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    selectedDoctors.append(indexPath)
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .none
    selectedDoctors = selectedDoctors.filter{ $0 != indexPath }
  }

  static var cellIdentifier = "DoctorSelectCell"
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DoctorListViewController.cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: DoctorListViewController.cellIdentifier)

    cell.textLabel?.text = doctors[indexPath.row].name
    cell.detailTextLabel?.text = doctors[indexPath.row].specialty

    cell.accessoryType = selectedDoctors.contains(indexPath) ? .checkmark : .none
    return cell
  }

  var documentDestinations:[DocumentDestination] = []
  func addDestinations(_ destinations:[DocumentDestination]){
    documentDestinations.append(contentsOf: destinations)
  }
}

extension SendToViewController:PDFHandler{
  func addPDFs(_ toAdd:[DocumentRef]){
    pdfs.append(contentsOf: toAdd)
  }


}
