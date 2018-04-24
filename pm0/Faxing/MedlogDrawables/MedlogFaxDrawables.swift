//
//  MedlogFaxDrawables.swift
//  pm0
//
//  Created by Michael Langford on 4/24/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class FaxMedlogAdministeredEntry:UIView{

  let dose:String
  let recordedTime:String
  let plannedTime:String
  override func draw(_ rect: CGRect) {
    MedlogFaxDrawables.drawFaxMedlogMarkedTaken(dose: dose, recordedTime: recordedTime, plannedTime: plannedTime)
  }

  init(frame:CGRect, dose:String, recordedTime:String, plannedTime:String){
    self.dose = dose
    self.recordedTime = recordedTime
    self.plannedTime = plannedTime
    super.init(frame:frame)
    self.backgroundColor = UIColor.white
  }

  required init?(coder:NSCoder){
    self.dose = "ERROR CLASS NEEDS FIX"
    self.recordedTime = "ERROR CLASS NEEDS FIX"
    self.plannedTime = "ERROR CLASS NEEDS FIX"
    super.init(coder:coder)
  }
}
