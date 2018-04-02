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

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

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

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
      return UITableViewAutomaticDimension
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
      self.alert.dismiss(animated: true, completion: nil)
    }))
    self.present(alert,animated: true)
  }


  func showStartFax(){
    alert = UIAlertController(title: "Compiling Fax...", message: "Assembling paperwork and uploading", preferredStyle: .alert)
    self.present(alert,animated: true)
  }

  func showUnimplemented(){
    alert = UIAlertController(title: "Not Implemented", message: "Feature to come", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      self.alert.dismiss(animated: true, completion: nil)
    }))
    self.present(alert,animated: true)
  }

  var pdfPreview = UIAlertController()
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0{

      showStartFax()

      let cover = coverPage(totalPageCountIncludingCoverPage: 2, to: "Dr Ableton's Office", from: "Patient Directly (Marv Jones)", forPatient: "Marv Jones")
      let pdf = samplePDF()

      
      sendFax(toNumber:"+18558237571", documentPaths: [cover,pdf]){ isSuccess,msg in
        self.showSuccessfulFax(message:msg)
      }
    }
    else{
      showUnimplemented()
    }
  }
}
