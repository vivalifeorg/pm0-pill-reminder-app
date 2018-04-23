//
//  RestrictionsViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

extension DocumentDestination{
  var faxToLine:String{
    return "\(name) <fax://\(value)>"
  }
}

class RestrictionsViewController:UIViewController,PDFHandler, SendableDocumentMetadata{
  @IBOutlet weak var restrictionsTextView:UITextView!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocuments = sendableDocuments
    let hipaaForm = hipaaConsentForm(
      doctors: sendableDocumentTopics ,
      patient: LocalStorage.UserInfoStore.load().first ?? PatientInfo(),
      restrictions: restrictionsTextView.text.split(separator: "\n").map{String($0)})

    //TODO count pages for real
    let cover = coverPage(totalPageCountIncludingCoverPage: 2, to: sendableDocumentDestinations.first?.faxToLine ?? "DOCTOR'S OFFICE", forPatient: LocalStorage.UserInfoStore.load().first?.lastDocumentName ?? "PATIENT NAME")
    pdfs.append(hipaaForm)


    handler.sendableDocuments = [cover, hipaaForm]
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations
  }

  var sendableDocumentTopics: [DocumentTopic] = []
  var sendableDocumentDestinations:[DocumentDestination] = []
  var pdfs:[DocumentRef] = []
  var sendableDocuments: [DocumentRef] = []
}


