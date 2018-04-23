//
//  Signature.swift
//  pm0
//
//  Created by Michael Langford on 4/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import SwiftySignature

struct SignatureInfo{
  var image:UIImage
  var date:Date
}
class SignatureViewController:UIViewController, PDFHandler, SendableDocumentMetadata,RestrictionsMetadata, SignatureViewDelegate{
  func SignatureViewIsDrawing(view: SignatureView) {
    //no-op
  }

  func SignatureViewDidCancelDrawing(view: SignatureView) {
   // no-op
  }


  @IBOutlet weak var signatureView:SignatureView!
  func SignatureViewDidBeginDrawing(view:SignatureView){
    nextButton.isEnabled = true
  }

  func SignatureViewDidFinishDrawing(view:SignatureView){
    signatureView.captureSignature()
  }

  func SignatureViewDidCaptureSignature(view: SignatureView, signature: Signature?){
    guard let signature = signature else{
      return
    }
    latestSignature = SignatureInfo(image:signature.image,date:signature.date)
  }
  
  var latestSignature:SignatureInfo?

  @IBAction func signatureClear(_:UIControl){
    nextButton.isEnabled = false
    signatureView.clearCanvas()
  }

  @IBOutlet weak var nextButton:UIBarButtonItem!

  var restrictions: [String] = []

  var sendableDocumentDestinations: [DocumentDestination] = []

  var sendableDocumentTopics: [DocumentTopic]  = []

  var sendableDocuments: [DocumentRef]  = []

  override func viewDidLoad() {
    signatureView.lineColor = UIColor.lightGray
    signatureView.lineOpacity = 0.85
    signatureView.delegate = self
  }

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
