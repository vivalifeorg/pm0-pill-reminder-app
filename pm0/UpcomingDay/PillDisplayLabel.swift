//
//  PillDisplayLabel.swift
//  pm0
//
//  Created by Michael Langford on 3/2/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class PillDisplayLabel: UILabel{

  override func awakeFromNib() {
    layer.cornerRadius = 4
    clipsToBounds = true 
  }
}
