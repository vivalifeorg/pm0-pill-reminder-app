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
    return isEnabled ? .black:
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
    setTitleColor(.black, for: .normal)
    setTitleColor(Asset.Colors.vlDisabledTextColor.color, for: .disabled)
  }

  static func createImageForButton(borderColor: UIColor, borderWidth: CGFloat, cornerRadius:CGFloat, buttonSize: CGSize,backgroundColor:UIColor) -> UIImage  {
    UIGraphicsBeginImageContextWithOptions(buttonSize, true, 0.0)
    backgroundColor.setFill()


    let backgroundPath = UIBezierPath(rect: CGRect(origin:.zero, size:buttonSize))
    Asset.Colors.vlCellBackgroundCommon.color.setFill()
    backgroundPath.fill()

    let bezierPath = UIBezierPath(roundedRect: CGRect(origin:.zero, size:buttonSize),
                                  cornerRadius: cornerRadius)
    Asset.Colors.vlWarmTintColor.color.setFill()
    bezierPath.fill()

    let image = UIGraphicsGetImageFromCurrentImageContext()!
    return image
  }

  static func createStandardEnabledBackgroundImage(buttonWidth: CGFloat) -> UIImage  {
    return VivaButtonA.createImageForButton(borderColor:Asset.Colors.vlWarmTintColor.color,
                                     borderWidth:0.5,
                                     cornerRadius: 8,
                                     buttonSize: CGSize(width:buttonWidth, height: 44),
                                     backgroundColor: Asset.Colors.vlCellBackgroundCommon.color)
  }

  static func createStandardDisabledBackgroundImage(buttonWidth: CGFloat) -> UIImage  {
    return VivaButtonA.createImageForButton(borderColor:Asset.Colors.vlDisabledButtonColor.color,
                                            borderWidth:0.5,
                                            cornerRadius: 8,
                                            buttonSize: CGSize(width:buttonWidth, height: 44),
                                            backgroundColor: Asset.Colors.vlCellBackgroundCommon.color)
  }
}
