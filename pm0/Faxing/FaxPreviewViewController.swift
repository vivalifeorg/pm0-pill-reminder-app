//
//  FaxPreviewViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import PDFKit

class FaxPreviewViewController:UIViewController, PDFHandler, SendableDocumentMetadata, RestrictionsMetadata{
  var signature: SignatureInfo? = nil
  var restrictions: [String] = []
  var sendableDocumentTopics: [DocumentTopic] = []
  var sendableDocumentDestinations:[DocumentDestination] = []

  var sendableDocuments:[DocumentRef]=[]{
    didSet{
      guard !sendableDocuments.isEmpty else{
        return
      }


      let doc = sendableDocuments.singleDocument
      let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("unified.pdf"))
      doc.write(to: tempFileURL)
      pdfURL = tempFileURL

      let preview = sendableDocuments.singleDocumentWithMargin
      let previewUrl = URL(fileURLWithPath: NSTemporaryDirectory().appending("unified.preview.pdf"))
      preview.write(to:previewUrl)
      pdfPreviewURL = previewUrl
    }
  }

  var pdfPreviewURL:URL = Bundle.main.url(
    forResource: "PreviewUnavailable",
    withExtension: "pdf",
    subdirectory: nil,
    localization: nil)!
    {
    didSet{
      guard isViewLoaded else{
        return
      }
      pdfView.document = PDFDocument.init(url: pdfPreviewURL)
    }
  }

  var pdfURL:URL = Bundle.main.url(
    forResource: "PreviewUnavailable",
    withExtension: "pdf",
    subdirectory: nil,
    localization: nil)!
  {
    didSet{
      guard isViewLoaded else{
        return
      }
     // pdfView.document = PDFDocument.init(url: pdfURL)
    }
  }


  @IBOutlet weak var pdfView:PDFView!

  override func viewDidLoad() {
    pdfView.document = PDFDocument.init(url: pdfPreviewURL)
    pdfView.displayMode = .singlePageContinuous
    pdfView.autoScales = true
  }

  var alert = UIAlertController()
  func showSuccessfulFax(message:String){
    guard presentedViewController == nil else {
      presentedViewController?.dismiss(animated: false){
        self.showSuccessfulFax(message:message)
      }
      return
    }

    alert = UIAlertController(title: "Fax Status", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: {
        self.dismiss(animated: true, completion: nil) //go back to root
      })
    }))
    self.present(alert,animated: true)
  }

  func showFailedFax(message:String){
    guard presentedViewController == nil else {
      presentedViewController?.dismiss(animated: false){
        self.showFailedFax(message:message)
      }
      return
    }

    alert = UIAlertController(title: "Fax Failure", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: {
        self.performSegue(withIdentifier:"unwindFromFaxingAfterSend", sender:self)
      })
    }))
    self.present(alert,animated: true)
  }

  var faxNumber = "+18558237571"
  @IBAction func sendShownFax(_:AnyObject){
    //TODO: Figure out if combined pdf is bad or if API can't take single document due to the file/file[] differences
    sendFax(toNumber:faxNumber, documentPaths: sendableDocuments){ isSuccess,msg in
      if isSuccess{
        self.showSuccessfulFax(message:msg)
      }else{
        self.showFailedFax(message: msg)
      }
    }
  }
  func showStartFax(){
    alert = UIAlertController(title: "Compiling Fax...", message: "Assembling paperwork and uploading", preferredStyle: .alert)
    self.present(alert,animated: true)
  }
}

