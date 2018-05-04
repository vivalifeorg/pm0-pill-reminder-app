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
      print("FAILING EMBED")
      return
    }
    embeddedViewController = segue.destination as! OnboardingViewController

    embeddedViewController.nextButton.addTarget(self, action: #selector(OnboardingContainer1.nextButtonTapped), for: .touchUpInside)

    embeddedViewController.backButton.addTarget(self, action: #selector(OnboardingContainer1.backButtonTapped), for: .touchUpInside)

    embeddedViewController.skipButton.addTarget(self, action: #selector(OnboardingContainer1.skipButtonTapped), for: .touchUpInside)

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
    //to override
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
    Feel better about your meds. Med Manager lets your medication anxiety evaporate.

    It tracks what medications you are taking and groups them by when you need to take them.
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
    embeddedViewController.backButton.isHidden = true
    embeddedViewController.mainImageView.image = Asset.Empty.emptyMyDay.image
    embeddedViewController.mainLabel.text =
    """
    Feel better about your meds. Med Manager lets your medication anxiety evaporate.

    It tracks what medications you are taking and groups them by when you need to take them.
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
    performSegue(withIdentifier: StoryboardSegue.Onboarding.showNextOnboarding.rawValue, sender: self)
  }

  override func embedFinished(){
    embeddedViewController.backButton.isHidden = true
    embeddedViewController.mainImageView.image = Asset.Empty.emptyMyDay.image
    embeddedViewController.mainLabel.text =
    """
    Feel better about your meds. Med Manager lets your medication anxiety evaporate.

    It tracks what medications you are taking and groups them by when you need to take them.
    """
  }

  override func backButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: StoryboardSegue.Onboarding.unwindToOnboarding2.rawValue, sender: self)
  }

}

