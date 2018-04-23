//
//  Signature.swift
//  pm0
//
//  Created by Michael Langford on 4/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class SignatureViewController:UIViewController, PDFHandler, SendableDocumentMetadata,RestrictionsMetadata{
  var restrictions: [String] = []

  var sendableDocumentDestinations: [DocumentDestination] = []

  var sendableDocumentTopics: [DocumentTopic]  = []

  var sendableDocuments: [DocumentRef]  = []


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    let hipaaForm = hipaaConsentForm(
      doctors: sendableDocumentTopics ,
      patient: LocalStorage.UserInfoStore.load().first ?? PatientInfo(),
      restrictions: restrictions)

    //TODO count pages for real
    let cover = coverPage(totalPageCountIncludingCoverPage: 2, to: sendableDocumentDestinations.first?.faxToLine ?? "DOCTOR'S OFFICE", forPatient: LocalStorage.UserInfoStore.load().first?.lastDocumentName ?? "PATIENT NAME")
    

    handler.sendableDocuments = [cover, hipaaForm]
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations
  }
}
