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

  @IBAction func unwindFromFaxingAfterCancel(segue:UIStoryboardSegue){

  }

  @IBAction func unwindFromFaxingAfterSend(segue:UIStoryboardSegue){

  }



  @IBAction func export(_ sender: Any) {
    return 
  }


  @IBAction func exportMedicationLog(_ sender: Any) {
    performSegue(withIdentifier: "sendMedicationLog", sender: self)

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
    if indexPath.row == 1 {
      performSegue(withIdentifier: sendInfoFaxSegueIdentifier, sender: self)
    } else if indexPath.row == 0 {
      exportMedicationLog(self)
    }else{
      showUnimplemented()
    }
  }
  let sendInfoFaxSegueIdentifier = "sendInfoFaxSegue"

  var pdfsToSend:[URL] = []





  @objc func cancelFax(){
    presentedViewController?.performSegue(withIdentifier: "unwindFromFaxingAfterCancel", sender: presentedViewController!)
  }

  
 
}

protocol DocumentTopic{
  var topicText:String {get}
}

protocol SendableDocumentMetadata{
  var sendableDocumentDestinations:[DocumentDestination] {get set}
  var sendableDocumentTopics:[DocumentTopic] {get set}
}

protocol PDFHandler{
  var sendableDocuments:[DocumentRef] {get set}
}
