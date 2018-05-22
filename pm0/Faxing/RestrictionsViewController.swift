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

protocol RestrictionsMetadata{
  var restrictions:[String] {set get}
}

class RestrictionsViewController:UITableViewController,PDFHandler, SendableDocumentMetadata{
  @IBOutlet weak var restrictionsTextView:UITextView!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata & RestrictionsMetadata
    handler.sendableDocuments = sendableDocuments
    handler.restrictions = restrictionsTextView.text.split(separator: "\n").map{String($0)}
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations
  }

  var sendableDocumentTopics: [DocumentTopic] = []
  var sendableDocumentDestinations:[DocumentDestination] = []
  var sendableDocuments: [DocumentRef] = []
}


