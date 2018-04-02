//
//  VivaButtonA.swift
//  pm0
//
//  Created by Michael Langford on 3/29/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class VivaButtonA:UIButton{

  override func draw(_ rect: CGRect) {
    layer.borderColor = color
    super.draw(rect)
  }

  var color:CGColor{
    return isEnabled ? Asset.Colors.vlWarmTintColor.color.cgColor:   Asset.Colors.vlDisabledButtonColor.color.cgColor
  }

  override func awakeFromNib() {
    layer.cornerRadius = 8.0
    layer.masksToBounds = true
    layer.borderColor =
      isEnabled ? Asset.Colors.vlWarmTintColor.color.cgColor:   Asset.Colors.vlDisabledButtonColor.color.cgColor
    layer.borderWidth = 0.5
    setTitleColor(Asset.Colors.vlWarmTintColor.color, for: .normal)
    setTitleColor(Asset.Colors.vlDisabledButtonColor.color, for: .disabled)
  }
}
