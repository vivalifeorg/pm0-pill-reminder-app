//
//  FaxableDocumentsViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/20/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import PDFKit

class FaxableDocumentsViewController:UITableViewController{

  func showPDF(){
    let pdfView = PDFView()
    pdfView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(pdfView)

    pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    if let document = PDFDocument(url: URL(fileURLWithPath:samplePDF())) {
      pdfView.document = document
    }
  }

  override func viewDidLoad() {
   // showPDF()
  }


  var alert = UIAlertController()
  func showSuccessfulFax(message:String){
    alert = UIAlertController(title: "Fax Status", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: nil)
    }))
    self.present(alert,animated: true)
  }

  var pdfPreview = UIAlertController()
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0{
      let pdf = samplePDF()
      
      sendFax(toNumber:"+18558237571", documentPaths: [pdf]){ isSuccess,msg in
        self.showSuccessfulFax(message:msg)
      }
    }
  }
}
