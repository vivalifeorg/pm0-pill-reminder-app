//
//  HistoryLengthViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/27/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class HistoryLengthViewController:UITableViewController, SendableDocumentMetadata, PDFHandler{
  var sendableDocuments: [DocumentRef] = []

  var sendableDocumentDestinations: [DocumentDestination] = []

  var sendableDocumentTopics: [DocumentTopic] = []

  let daySeconds:Double =  24 * 60 * 60
  func selectedPeriod(_ period:Int){

    switch period{
    case 0:
      timePeriod = 30.0 * daySeconds
    case 1:
      timePeriod = 90.0 * daySeconds
    case 2:
      timePeriod = 10000.0 * daySeconds
    default:
      print("wierd case")
    }
  }
  lazy var timePeriod:TimeInterval = daySeconds * 30

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations

    let rawLog = LocalStorage.MedicationLogStore.load()
    let today = Date()
    let filteredLog = Array(rawLog.filter{ $0.timestamp.addingTimeInterval(timePeriod) > today }.reversed())
    let medlog = medlogForm(events: filteredLog, patient: LocalStorage.UserInfoStore.loadSingle()!)
    sendableDocuments = [medlog]

    handler.sendableDocuments = sendableDocuments
  }

  override func viewDidLoad() {
    tableView.tableFooterView = UIView()
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let indexPaths = [IndexPath(item: 0, section: 0),
                      IndexPath(item: 1, section: 0),
                      IndexPath(item: 2, section: 0)].filter{indexPath.row != $0.row}

    indexPaths.forEach{
      tableView.cellForRow(at: $0)?.accessoryType = .none

    }
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
  }

}
