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
      setNeedsDisplay()
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
    layer.shadowColor = UIColor.black.cgColor
    setTitleColor(.black, for: .normal)
    setTitleColor(Asset.Colors.vlDisabledTextColor.color, for: .disabled)

    let disabledBG = VivaButtonA.createStandardDisabledBackgroundImage(buttonWidth: frame.width)
    setBackgroundImage(disabledBG, for: .disabled)

    let enabledBG = VivaButtonA.createStandardEnabledBackgroundImage(buttonWidth: frame.width)
    setBackgroundImage(enabledBG, for: .normal)
  }

  static func createImageForButton(buttonBackgroundColor: UIColor, borderWidth: CGFloat, cornerRadius:CGFloat, buttonSize: CGSize,backgroundBehindButtonColor:UIColor) -> UIImage  {
    UIGraphicsBeginImageContextWithOptions(buttonSize, true, 0.0)
    buttonBackgroundColor.setFill()

    //fill in the corners by painting a rect
    let backgroundPath = UIBezierPath(rect: CGRect(origin:.zero, size:buttonSize))
    backgroundBehindButtonColor.setFill()
    backgroundPath.fill()

    //fill the background by painting a rounded rect
    let bezierPath = UIBezierPath(roundedRect: CGRect(origin:.zero, size:buttonSize),
                                  cornerRadius: cornerRadius)
    buttonBackgroundColor.setFill()
    bezierPath.fill()

    let image = UIGraphicsGetImageFromCurrentImageContext()!
    return image
  }

  static func createStandardEnabledBackgroundImage(buttonWidth: CGFloat) -> UIImage  {
    return VivaButtonA.createImageForButton(buttonBackgroundColor:Asset.Colors.vlWarmTintColor.color,
                                     borderWidth:0.5,
                                     cornerRadius: 8,
                                     buttonSize: CGSize(width:buttonWidth, height: 44),
                                     backgroundBehindButtonColor: Asset.Colors.vlCellBackgroundCommon.color)
  }

  static func createStandardDisabledBackgroundImage(buttonWidth: CGFloat) -> UIImage  {
    return VivaButtonA.createImageForButton(buttonBackgroundColor:Asset.Colors.vlDisabledButtonColor.color,
                                            borderWidth:0.5,
                                            cornerRadius: 8,
                                            buttonSize: CGSize(width:buttonWidth, height: 44),
                                            backgroundBehindButtonColor: Asset.Colors.vlCellBackgroundCommon.color)
  }
}
