//
//  RestrictionsViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class RestrictionsViewController:UIViewController,PDFHandler, SendableDocumentMetadata{
  @IBOutlet weak var restrictionsTextView:UITextView!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocuments = sendableDocuments
    let hipaaForm = hipaaConsentForm(doctors: sendableDocumentTopics , restrictions: restrictionsTextView.text.split(separator: "\n").map{String($0)})

    //TODO count pages for real
    let cover = coverPage(totalPageCountIncludingCoverPage: 2, to: sendableDocumentDestinations.first!, forPatient: "PATIENT NAME HERE")
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


