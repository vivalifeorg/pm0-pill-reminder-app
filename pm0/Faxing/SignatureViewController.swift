//
//  Signature.swift
//  pm0
//
//  Created by Michael Langford on 4/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class SignatureViewController:UIViewController, PDFHandler, SendableDocumentMetadata{
  var sendableDocumentDestinations: [DocumentDestination] = []

  var sendableDocumentTopics: [DocumentTopic]  = []

  var sendableDocuments: [DocumentRef]  = []


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata
    handler.sendableDocuments = sendableDocuments
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations
  }
}
