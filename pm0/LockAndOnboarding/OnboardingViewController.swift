//
//  OnboardingViewController.swift
//  pm0
//
//  Created by Michael Langford on 5/4/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import UIKit




class OnboardingViewController:UIViewController{
  @IBOutlet weak var backButton:UIButton!
  @IBOutlet weak var nextButton:UIButton!
  @IBOutlet weak var skipButton:UIButton!
  @IBOutlet weak var mainImageView:UIImageView!
  @IBOutlet weak var mainLabel:UILabel!
}


class OnboardingContainerViewController:UIViewController{
  weak var embeddedViewController:OnboardingViewController!

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == StoryboardSegue.Onboarding.embedOnboarding.rawValue else {
      return
    }
    embeddedViewController = segue.destination as! OnboardingViewController
  }

  override func viewDidLoad() {
    self.navigationController?.isNavigationBarHidden = true
    embeddedViewController.nextButton.addTarget(self, action: #selector(OnboardingContainerViewController.nextButtonTapped), for: .touchUpInside)

    embeddedViewController.backButton.addTarget(self, action: #selector(OnboardingContainerViewController.backButtonTapped), for: .touchUpInside)

    embeddedViewController.skipButton.addTarget(self, action: #selector(OnboardingContainerViewController.skipButtonTapped), for: .touchUpInside)

    embedFinished()
  }

  func embedFinished(){
    //to override
  }

  @objc open func nextButtonTapped(_ sender:UIButton){
    //to override
  }

  @objc open func backButtonTapped(_ sender:UIButton){
    //to override
  }

  @objc open func skipButtonTapped(_ sender:UIButton){
    embeddedViewController.performSegue(withIdentifier: StoryboardSegue.Onboarding.skipOnboarding.rawValue, sender: self)
  }
}

class OnboardingContainer1:OnboardingContainerViewController{

  @objc override open func nextButtonTapped(_ sender:UIButton){
    performSegue(withIdentifier: StoryboardSegue.Onboarding.showNextOnboarding.rawValue, sender: self)
  }

  override func embedFinished(){
    embeddedViewController.backButton.isHidden = true
    embeddedViewController.mainImageView.image = Asset.Empty.emptyMyDay.image
    embeddedViewController.mainLabel.text =
    """
    Med Manager relieves your medication headache. It tracks what medications you are taking and groups them by when you need to take them.

    All your information is securely protected by encryption and kept on your device.
    """
  }

  @IBAction func unwindToOnboarding1(segue:UIStoryboardSegue){

  }
}

class OnboardingContainer2:OnboardingContainerViewController{

  @objc override open func nextButtonTapped(_ sender:UIButton){
    performSegue(withIdentifier: StoryboardSegue.Onboarding.showNextOnboarding.rawValue, sender: self)
  }

  override func embedFinished(){
    embeddedViewController.backButton.isHidden = false
    embeddedViewController.mainImageView.image = Asset.FaxAnim.faxAnimFaxPage.image
    embeddedViewController.mainLabel.text =
    """
    Push a button to fax your medication history to your doctor.

    Don't miss a single detail & save time filling out waiting room paperwork.
    """
  }

  override func backButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: StoryboardSegue.Onboarding.unwindToOnboarding1.rawValue, sender: self)
  }

  @IBAction func unwindToOnboarding2(segue:UIStoryboardSegue){

  }
}

class OnboardingContainer3:OnboardingContainerViewController{

  @objc override open func nextButtonTapped(_ sender:UIButton){
    performSegue(withIdentifier: StoryboardSegue.Onboarding.unwindFinalOnboardingButton.rawValue, sender: self)
  }

  override func embedFinished(){
    embeddedViewController.backButton.isHidden = false
    embeddedViewController.skipButton.isHidden = true
    embeddedViewController.mainImageView.image = Asset.Empty.emptyDoc.image
    embeddedViewController.mainLabel.text =
    """
    Get driving directions or call the doctor's office from the app.

    No passwords needed: Login to the app by logging into your \(UIDevice.current.localizedModel).
    """
    embeddedViewController.nextButton.setTitle("Begin Now", for: .normal)
  }

  override func backButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: StoryboardSegue.Onboarding.unwindToOnboarding2.rawValue, sender: self)
  }

}

