//
//  VivaButtonA.swift
//  pm0
//
//  Created by Michael Langford on 3/29/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class VivaButtonA:UIButton{

  override var isEnabled: Bool{
    didSet{
      backgroundColor = bgColor
    }
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
  }

  var color:CGColor{
    return isEnabled ? Asset.Colors.vlWarmTintColor.color.cgColor:   Asset.Colors.vlDisabledButtonColor.color.cgColor
  }

  var fgColor:UIColor{
    return isEnabled ? Asset.Colors.vlTextColor.color:
      Asset.Colors.vlDisabledTextColor.color
  }

  var bgColor:UIColor{
    return isEnabled ?
      Asset.Colors.vlWarmTintColor.color:
      Asset.Colors.vlDisabledButtonColor.color
  }

  override func awakeFromNib() {
    layer.cornerRadius = 8.0
    layer.masksToBounds = true
    setTitleColor(Asset.Colors.vlTextColor.color, for: .normal)
    setTitleColor(Asset.Colors.vlDisabledTextColor.color, for: .disabled)
  }
}
