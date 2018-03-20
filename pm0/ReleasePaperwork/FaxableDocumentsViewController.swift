//
//  FaxableDocumentsViewController.swift
//  pm0
//
//  Created by Michael Langford on 3/20/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit
import PDFKit

class FaxableDocumentsViewController:UITableViewController,UIDocumentInteractionControllerDelegate{

  var documentInteractionController:UIDocumentInteractionController? = nil

  @IBAction func export(_ sender: Any) {

    let sample = samplePDF()
    let url = URL(fileURLWithPath: sample)
    self.documentInteractionController = UIDocumentInteractionController(url: url)
    self.documentInteractionController?.delegate = self
    self.documentInteractionController?.presentPreview(animated: true )
  }


  func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
      return self
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
