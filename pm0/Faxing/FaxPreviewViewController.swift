//
//  FaxPreviewViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import PDFKit


import AVFoundation

// create a sound ID, in this case its the tweet sound.
let systemSoundID: SystemSoundID = 1016

// to play sound


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

      let insertedDocs = sendableDocuments
      let totalPageCount = sendableDocuments.singleDocument.pages.count + 1
      let destination = sendableDocumentDestinations.first?.faxToLine ?? "DOCTOR'S OFFICE"

        let patientName =  LocalStorage.UserInfoStore.load().first?.lastDocumentName ?? "PATIENT NAME"
        let cover:DocumentRef = coverPage(totalPageCountIncludingCoverPage:totalPageCount,
                                          to: destination,
                                          forPatient:patientName)

        let realDocs:[DocumentRef] = [cover] + insertedDocs
        let preview = realDocs.singleDocument
        let previewUrl = URL(fileURLWithPath: NSTemporaryDirectory().appending("unified.preview.pdf"))
        preview.write(to:previewUrl)
            self.pdfPreviewURL = previewUrl


    }
  }

  var pdfPreviewURL:URL = Bundle.main.url(
    forResource: "PreviewUnavailable",
    withExtension: "pdf",
    subdirectory: nil,
    localization: nil)!
    {
    didSet{
        pdfView?.document = PDFDocument.init(url: pdfPreviewURL)
    }
  }



  @IBOutlet weak var pdfView:PDFView!

  override func viewDidLoad() {
    pdfView.document = PDFDocument.init(url: pdfPreviewURL)
    pdfView.displayMode = .singlePageContinuous
    pdfView.autoScales = true
    view.backgroundColor = .white
    pdfView.backgroundColor = .white
  }

  var alert = UIAlertController()
  func showSuccessfulFax(message:String){
    guard let faxStatusVC = self.presentedViewController as? FaxStatusViewController else{
      return
    }

    if "Fax queued for sending" == message {
      faxStatusVC.updateStatus(message: "Great Job! \n\n Your fax should arrive at your doctor's office shortly. \n\n This screen will close automatically.",
                               cancelButtonEnabled: false)
          faxStatusVC.stopAnimations()
      AudioServicesPlaySystemSound (systemSoundID)
    }else{
      faxStatusVC.updateStatus(message: message, cancelButtonEnabled: false)

    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      self.performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.unwindFromFaxingAfterSend.rawValue, sender: self)
    }
  }

  func showFailedFax(message:String){

    guard let faxStatusVC = self.presentedViewController as? FaxStatusViewController else{
      return
    }
    faxStatusVC.updateStatus(message: "Fax failed to send:\n \(message)", cancelButtonEnabled: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.unwindFromFaxingAfterSend.rawValue, sender: self)
    }
  }

  @IBAction func unwindFromFaxingAfterSend(segue:UIStoryboardSegue){
    self.performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.unwindFromFaxingAfterSend.rawValue, sender: self)
  }

  var faxNumber = "+18558237571"
  @IBAction func sendShownFax(_:AnyObject){
    self.performSegue(withIdentifier: StoryboardSegue.FaxableDocuments.showFaxStatus.rawValue, sender: self)
    sendFax(toNumber:sendableDocumentDestinations.first!.value, documentPaths: [pdfPreviewURL]){ isSuccess,msg in
      DispatchQueue.main.async{
        if isSuccess{
          self.showSuccessfulFax(message:msg)
        }else{
          self.showFailedFax(message: msg)
        }
      }
    }
  }
  func showStartFax(){
    alert = UIAlertController(title: "Compiling Fax...", message: "Assembling paperwork and uploading", preferredStyle: .alert)
    self.present(alert,animated: true)
  }
}

