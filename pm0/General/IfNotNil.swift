//
//  IfNotNil.swift
//  pm0
//
//  Created by Michael Langford on 4/11/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation

extension Optional{
  func ifNotNil<U>(_ action:(Wrapped)->(U?))->U?{
    guard let nonOptionalSelf = self else{
      return nil
    }
    return action(nonOptionalSelf) ?? nil
  }
}

