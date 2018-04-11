//
//  SendToViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class SendToViewController:UITableViewController, SendableDocumentMetadata, PDFHandler{
  @IBOutlet weak var nextButton:UIBarButtonItem!

  var sendableDocumentTopics: [DocumentTopic] = []
  var doctors:[DoctorInfo] = []
  var selectedRows:[IndexPath] = []
  var sendableDocuments:[DocumentRef] = []

  func updateNextButton(){
    nextButton.isEnabled = selectedRows.count > 0
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    guard var handler = segue.destination as? (PDFHandler & SendableDocumentMetadata) else {
      return //for cancel, etc
    }

    handler.sendableDocuments = sendableDocuments
    handler.sendableDocumentTopics = sendableDocumentTopics
    
    let selectedDoctors:[DoctorInfo] = selectedRows.map{doctors[$0.row]}
    selectedDoctors.forEach{ handler.sendableDocumentTopics.append($0) }

    handler.sendableDocumentDestinations = isSendToScreen ?
        selectedDoctors.map{$0.fax.number} :
        sendableDocumentDestinations
  }

  var isSendToScreen:Bool {
    return self.restorationIdentifier == "SendToScreen"
  }

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
    updateNextButton()
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
    selectedRows.append(indexPath)
    updateNextButton()
  }

  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .none
    selectedRows = selectedRows.filter{ $0 != indexPath }
    updateNextButton()
  }

  static var cellIdentifier = "DoctorSelectCell"
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: DoctorListViewController.cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: DoctorListViewController.cellIdentifier)

    cell.textLabel?.text = doctors[indexPath.row].name
    cell.detailTextLabel?.text = doctors[indexPath.row].specialty

    cell.accessoryType = selectedRows.contains(indexPath) ? .checkmark : .none
    return cell
  }

  var sendableDocumentDestinations:[DocumentDestination] = []{
    didSet{
      print(sendableDocumentDestinations)
    }
  }
}

