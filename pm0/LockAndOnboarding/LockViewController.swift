//
//  LockViewController.swift
//  pm0
//
//  Created by Michael Langford on 5/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

class LockViewController:UIViewController{

  var alertController:UIAlertController?
  override func viewDidLoad() {
    NotificationCenter.default.addObserver(self, selector: #selector(didGetNeedsAuthAgainNotification(_:)), name: VLNeedsAuthAgainNotification.name, object: nil)
    let alert = UIAlertController(title: "Intro Slides Go Here", message:
"""
This lock screen wouldn't show on the first run.

Onboarding screens will go here for the first run (still WIP).
"""
    , preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (a) in
      alert.dismiss(animated: true, completion: nil)
    }))
    alertController = alert
    present(alertController!, animated: true) {

    }
  }


  @IBAction func unwindSkipOnboarding(segue:UIStoryboardSegue){
  }
  @IBAction func unwindToStart(segue:UIStoryboardSegue){
    
  }

  @objc func didGetNeedsAuthAgainNotification(_ notification:VLNeedsAuthAgainNotification){
    debugPrint("user needs to re-auth")
    DispatchQueue.main.async {


      self.presentedViewController?.performSegue(withIdentifier: "unwindToStart", sender: self)
    }
  }

  @IBAction func userTappedUnlock(_ sender:Any){
    authenticateUser(){ success in
      if success{
        self.performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
      }
    }
  }
}
