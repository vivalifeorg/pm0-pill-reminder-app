//
//  NameViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class NameViewController:UIViewController, PDFHandler, SendableDocumentMetadata{
  @IBOutlet weak var nameField:UITextField!

  var sendableDocumentDestinations: [DocumentDestination] = []

  var sendableDocumentTopics: [DocumentTopic] = []

  var sendableDocuments: [DocumentRef] = []

  override func viewDidLoad() {
    nameField.text = LocalStorage.UserInfoStore.load().first?.lastDocumentName
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var user = LocalStorage.UserInfoStore.load().first ?? PatientInfo()
    user.lastDocumentName = nameField.text ?? ""
    LocalStorage.UserInfoStore.save([user])

    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations

    if restorationIdentifier == medlogFlowRestorationNameController {
      let medlog = medlogForm(events: LocalStorage.MedicationLogStore.load().reversed(), patient: LocalStorage.UserInfoStore.loadSingle()!)
      let cover = coverPage(totalPageCountIncludingCoverPage: sendableDocuments.singleDocument.pageCount + 1, to: handler.sendableDocumentDestinations.first?.faxToLine ?? "DOCTOR'S OFFICE", forPatient: LocalStorage.UserInfoStore.load().first?.lastDocumentName ?? "PATIENT NAME")
      sendableDocuments = [cover,medlog]
    }
    handler.sendableDocuments = sendableDocuments
  }
  let medlogFlowRestorationNameController = "medlogFlowRestorationNameController"
}
