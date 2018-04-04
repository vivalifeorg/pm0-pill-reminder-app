//
//  FaxPreviewViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import PDFKit

class FaxPreviewViewController:UIViewController{


  var listOfPdfs:[DocumentRef]=[]{
    didSet{
      guard !listOfPdfs.isEmpty else{
        return
      }


      let doc = listOfPdfs.singleDocument
      let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("unified.pdf"))
      doc.write(to: tempFileURL)
      pdfURL = tempFileURL
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
      pdfView.document = PDFDocument.init(url: pdfURL)
    }
  }


  @IBOutlet weak var pdfView:PDFView!

  override func viewDidLoad() {
    pdfView.document = PDFDocument.init(url: pdfURL)
    pdfView.displayMode = .singlePageContinuous
    pdfView.autoScales = true
  }

}

extension FaxPreviewViewController:PDFHandler{
  func addPDFs(_ pdfsToAdd: [DocumentRef]) {
    listOfPdfs = pdfsToAdd
  }
}
