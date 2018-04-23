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




extension UIImage {
  func convertedToGrayImage() -> UIImage? {
    let width = self.size.width
    let height = self.size.height
    let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

    guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
      return nil
    }
    guard let cgImage = cgImage else { return nil }

    context.draw(cgImage, in: rect)
    guard let imageRef = context.makeImage() else { return nil }
    let newImage = UIImage(cgImage: imageRef.copy()!)

    return newImage
  }

    func invertedImage() -> UIImage? {
      guard let cgImage = self.cgImage else { return nil }
      let ciImage = CoreImage.CIImage(cgImage: cgImage)
      guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
      filter.setDefaults()
      filter.setValue(ciImage, forKey: kCIInputImageKey)
      let context = CIContext(options: nil)
      guard let outputImage = filter.outputImage else { return nil }
      guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
      return UIImage(cgImage: outputImageCopy)
    }

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
    guard let signature = signature,
      let correctedImage = signature.image.convertedToGrayImage()?.invertedImage() else{
      return
    }
    latestSignature = SignatureInfo(image:correctedImage, date:signature.date)
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
    signatureView.lineColor = UIColor.white
    signatureView.lineOpacity = 0.85
    signatureView.delegate = self
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let signature = latestSignature else {
      return
    }

    var handler = segue.destination as! PDFHandler & SendableDocumentMetadata  & RestrictionsMetadata
    let hipaaForm = hipaaConsentForm(
      doctors: sendableDocumentTopics ,
      patient: LocalStorage.UserInfoStore.load().first ?? PatientInfo(),
      signatureInfo: signature,
      restrictions: restrictions)

    //TODO count pages for real
    let cover = coverPage(totalPageCountIncludingCoverPage: 2, to: sendableDocumentDestinations.first?.faxToLine ?? "DOCTOR'S OFFICE", forPatient: LocalStorage.UserInfoStore.load().first?.lastDocumentName ?? "PATIENT NAME")

    handler.sendableDocuments = [cover, hipaaForm]
    handler.restrictions = restrictions
    handler.sendableDocumentTopics = sendableDocumentTopics
    handler.sendableDocumentDestinations = sendableDocumentDestinations
  }
}
