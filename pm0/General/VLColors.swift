//
//  VLColors.swift
//  pm0
//
//  Created by Michael Langford on 3/5/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//


//Move to https://medium.com/bobo-shone/how-to-use-named-color-in-xcode-9-d7149d270a16
import UIKit.UIColor

struct VLColors{
  static var primaryText:UIColor{
    return UIColor.white
  }

  static var footerMissedMeds:UIColor{
    return warmHighlight
  }

  static var footerInfoPertinent:UIColor{
    return UIColor.lightGray
  }

  static var footerAllGood:UIColor{
    return UIColor.darkGray
  }

  static var highlightedPrimaryText:UIColor{
    return VLColors.sipChathamsBlue
  }
  static var secondaryText:UIColor{
    return UIColor.gray
  }
  static var background:UIColor{
    return UIColor.black
  }

  static var sipPorche:UIColor{
    return UIColor(red:0.92, green:0.60, blue:0.34, alpha:1.00)
  }

  static var sipPictonBlue:UIColor{
    return UIColor.init(named: "sipPictonBlue")!
  }
  static var warmHighlight:UIColor{
    return sipPorche
  }
  static var coolHighlight:UIColor{
    return sipPictonBlue
  }
  static var cellBackground:UIColor{
    return UIColor.init(named: "sipTarawera")!
  }
  static var sipChathamsBlue:UIColor{
    return UIColor(red:0.19, green:0.34, blue:0.45, alpha:1.00)
  }
  static var sipMirage:UIColor{
    return UIColor(red:0.06, green:0.11, blue:0.15, alpha:1.00)
  }

  static var tableViewSectionHeaderBackgroundColor:UIColor{
    return UIColor.darkGray
  }
//  static var sipTarawera:UIColor{
 //   return UIColor(red:0.13, green:0.22, blue:0.30, alpha:1.00)
  //}

  static var sipPatternsBlue:UIColor{
    return UIColor(red:0.89, green:0.95, blue:0.98, alpha:1.00)
  }

  static var selectedCellBackground:UIColor{
    return sipPatternsBlue
  }

  static var tintColor:UIColor{
    return sipPatternsBlue
  }
}
