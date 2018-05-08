//
//  LockViewController.swift
//  pm0
//
//  Created by Michael Langford on 5/3/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit

/// Manages the initial load screen for the app
class LockViewController:UIViewController{

  var alertController:UIAlertController?
  override func viewDidLoad() {
    self.view.backgroundColor = UIColor(patternImage: Asset.Lock.lockBG.image)
    NotificationCenter.default.addObserver(self, selector: #selector(didGetNeedsAuthAgainNotification(_:)), name: VLNeedsAuthAgainNotification.name, object: nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    if authInfo.firstRun {
      performSegue(withIdentifier: StoryboardSegue.Main.showOnboarding.rawValue, sender: self)
    } else if isFirstRunAndJustFinishedOnboarding{
      performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
    }
  }

  var authInfo:AuthenticationInfo{
    return LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
  }

  private var isFirstRunAndJustFinishedOnboarding = false
  /// record that the user used the app
  func markFirstRun(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.firstRun = false
    LocalStorage.AuthenticationStore.save([authInfo])
  }

  /// record stats when the user has authenticated successfully
  func markLogin(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.lastLogin = Date()
    authInfo.numberOfTimesLoggedIn += 1
    LocalStorage.AuthenticationStore.save([authInfo])
  }

  /// "User tried to login, and failed"
  func markFailedLogin(){
    var authInfo = LocalStorage.AuthenticationStore.load().first ?? AuthenticationInfo()
    authInfo.numberOfFailedLoginAttempts += 1
    LocalStorage.AuthenticationStore.save([authInfo])
  }

  /// Allows user to get in when it's data free
  ///
  /// - Parameter segue: storyboard segue used to get here from onboarding
  @IBAction func unwindHitFinalOnboardingButton(segue:UIStoryboardSegue){
    //On the first run, there is no data to secure, so we can let them into the app
    autologinIfPossible()
  }

  func autologinIfPossible(){
    if authInfo.firstRun {
      isFirstRunAndJustFinishedOnboarding = true
      markFirstRun()
    }
  }

  /// User tapped onboarding skip button
  ///
  /// - Parameter segue: segue from storyboard in onboarding
  @IBAction func unwindSkipOnboarding(segue:UIStoryboardSegue){
    //On the first run, there is no data to secure, so we can let them into the app
    autologinIfPossible()
  }

  /// Used to pop back out to login
  ///
  /// - Parameter segue: segue from storyboard
  @IBAction func unwindToStart(segue:UIStoryboardSegue){
    
  }

  /// Makes the app pop the user interface off
  ///   this needs to be tested a lot with popups, etc, before using it
  ///
  /// - Parameter notification: the notification that tells us that.
  @objc func didGetNeedsAuthAgainNotification(_ notification:VLNeedsAuthAgainNotification){
    debugPrint("user needs to re-auth")
    DispatchQueue.main.async {
      self.presentedViewController?.performSegue(withIdentifier: "unwindToStart", sender: self)
    }
  }


  /// Unlock button on the main screen
  ///
  /// <#Description#>
  ///
  /// - Parameter sender: <#sender description#>
  @IBAction func userTappedUnlock(_ sender:Any){
    authenticateUser(){ outcome in
      DispatchQueue.main.async{
        if outcome == .succeeded {
          self.performSegue(withIdentifier: StoryboardSegue.Main.goToApp.rawValue, sender: self)
          self.markLogin()
        }else{
          self.markFailedLogin()
        }
      }
    }
  }
}
