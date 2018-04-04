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

  var pdfURL:URL = Bundle.main.url(
    forResource: "PreviewUnavailable",
    withExtension: "pdf",
    subdirectory: nil,
    localization: nil)!
  {
    didSet{
      pdfView.document = PDFDocument.init(url: pdfURL)
    }
  }


  @IBOutlet weak var pdfView:PDFView!

  override func viewDidLoad() {
    pdfView.document = PDFDocument.init(url: pdfURL)
    pdfView.displayMode = .twoUpContinuous
    pdfView.autoScales = true
  }

}
