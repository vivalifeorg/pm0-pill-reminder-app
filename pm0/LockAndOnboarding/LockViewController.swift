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
  }


  var authInfo:AuthenticationInfo{
    return LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
  }

  func markFirstRun(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.firstRun = false
    LocalStorage.AuthenticationStore.save([authInfo])
  }

  func markLogin(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.lastLogin = Date()
    authInfo.numberOfTimesLoggedIn += 1
    LocalStorage.AuthenticationStore.save([authInfo])
  }
  
  func markFailedLogin(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.numberOfFailedLoginAttempts += 1
    LocalStorage.AuthenticationStore.save([authInfo])
  }

  @IBAction func unwindHitFinalOnboardingButton(segue:UIStoryboardSegue){
    //On the first run, there is no data to secure, so we can let them into the app
    guard authInfo.firstRun else {
      return
    }

    markFirstRun()
    self.performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
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
      DispatchQueue.main.async{
        if success{
          self.performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
          self.markLogin()
        }else{
          self.markFailedLogin()
        }
      }
    }
  }
}
