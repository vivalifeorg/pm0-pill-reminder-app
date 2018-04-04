//
//  RestrictionsViewController.swift
//  pm0
//
//  Created by Michael Langford on 4/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class RestrictionsViewController:UIViewController{

  var pdfs:[DocumentRef] = []

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let handler = segue.destination as? PDFHandler
    handler?.addPDFs(pdfs)
  }
}

extension RestrictionsViewController:PDFHandler{
  func addPDFs(_ toAdd:[DocumentRef]){
    pdfs.append(contentsOf: toAdd)
  }
}

