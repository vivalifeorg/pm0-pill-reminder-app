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

  func selectedPeriod(_ period:Int){

    switch period{
    case 0:
      timePeriod = 30
    case 1:
      timePeriod = 90
    case 2:
      timePeriod = 366 // "all" is now "a year", we can fix this, but not right now
    default:
      print("wierd case")
    }
  }
  lazy var timePeriod:Int = 30

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations

    let filteredLog = LocalStorage.MedicationLogStore.loadLastDays(timePeriod)
    let combinedFilteredLog = filteredLog.keys.flatMap{filteredLog[$0]!}
    let medlog = medlogForm(events: combinedFilteredLog, patient: LocalStorage.UserInfoStore.loadSingle()!)
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
