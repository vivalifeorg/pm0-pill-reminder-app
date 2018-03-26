//
//  PrescriptionDisplayView.swift
//  pm0
//
//  Created by Michael Langford on 3/26/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//
import UIKit

class PrescriptionDisplayView:UIView{
  @IBOutlet weak var title:UILabel!
  @IBOutlet weak var body:UILabel!

  override func awakeFromNib(){
    super.awakeFromNib()
    updateLabels()
  }

  private func updateLabels(){
    guard title != nil, body != nil else {return}

    title?.attributedText = dosage?.attributedTitle
    body?.attributedText = dosage?.attributedBody
  }

  var dosage:Dosage? = nil{
    didSet{
      updateLabels()
    }
  }

  override init(frame: CGRect) {
    super.init(frame:frame)
    xibSetup()
  }

  required init?(coder: NSCoder){
    super.init(coder:coder)
    xibSetup()
  }
}

