//
//  VivaButtonA.swift
//  pm0
//
//  Created by Michael Langford on 3/29/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class VivaButtonA:UIButton{

  override func awakeFromNib() {
    layer.cornerRadius = 8.0
    layer.masksToBounds = true
    layer.borderColor = Asset.Colors.vlWarmTintColor.color.cgColor
    layer.borderWidth = 0.5
  }
}
