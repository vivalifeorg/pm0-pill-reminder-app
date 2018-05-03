//
//  LockViewController.swift
//  pm0
//
//  Created by Michael Langford on 5/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class LockViewController:UIViewController{

  @IBAction func userTappedUnlock(_ sender:Any){
    authenticateUser(){ success in
      if success{
        self.performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
      }
    }
  }
}
