//
//  RXEntryHelpText.swift
//  pm0
//
//  Created by Michael Langford on 3/23/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//


enum RXEntryHelpText{
  static let nameHelpText =
  """
    # Naming your medication

    Enter in a *short* memorable name for your medication.

    If you selected your medication from the search box, you can shorten/change the name without a problem.
    """
  static let formHelpText =
  """
    # Describe the form of the medication

    Describe what a *single* pill looks like. You will input the quantity you take at one time later.

    For example, if you take two orange 200mg tablets every six hours, put "**tablet**" here.

    ### Other Examples:

     - Square Blue Pill
     - Capsule

    *****

    # Things that aren't pills

    Some types of medications do not come as pills.

     - For prepackaged, single-use items, put "**kit**" here.
     - If your medication is something liquid or powdered that you take a measured amount of, you most possibly should put nothing here.
     - If your medication is in an inhaler, put **puff** here.
    """
  static let unitHelpText =
  """
    # Describing strength of a single pill

    Describe how strong a single pill is. If you only take one pill this strength shown on the package. You will input quantity later.

    For example, if you take two, orange 200 mg tablets every six hours, put "**200 mg**" here.

    ### Other Examples:

     - 40mg
     - 100mg
     - 5ml

    *****

    # Things that aren't pills

    Some types of medications do not come as pills.

     - For prepackaged, single-use items, put the "potency" here.
     - If your medication is something liquid or powdered that you take a measured amount of put the concentration here. For example, for "10mL of 160 mg/5ml solution", put "160 mg/5ml"
     - If your medication is in an inhaler, put nothing here.
    """

  static let quantityHelpText =
  """
    # Quantity

    For most medications, this is the number of pills you take at once.

    For example, if you take two 200mg pills every six hours, you put "**2**" here, as that's how much you take at a single time.

    If your medication is something liquid or powdered that you take a measured amount of, you most likely should put the amount of units of it you take here here. For example, for "10mL of 160 mg/5ml solution", put "**10ml**"
    """

  static let prescriberHelpText =
  """
    # Prescriber

    This is the person who wrote your prescription. They are typically a doctor or nurse practitioner. This will be on the medication bottle and prescription.

    Tap the circled plus button to select a doctor formerly entered into the app.
    """

  static let scheduleHelpText =
  """
    # Describe when you take it

    Start typing how and when you need to take the medication. We will show you some patterns of possible matchups that fit common times of day that people use to remember to take their medications.

    You can select any of those shown as you type, or tap "Custom" to build your own.
    """

  static let pharmacyHelpText =
  """
    # Who Fills this Prescription

    Write where you pick up this medication from. If an over the counter drug, feel free to leave this blank.

    Tap the circled plus button to select a pharmacy formerly entered into the app.
    """

  static let conditionHelpText =
  """
    # Condition

    Write what condition or impairment that motivates you to take this medication. This helps you discuss your entire treatment plan with every doctor trying to help you.

    This also helps you clean up after recovering from something like a surgery or other intermittant occasion where you will not need many of the medications long term.
    """

  static var helpTextCSSStylesheet:String{
    let stylesheet =
    """
    * {
    font-family: system-ui;
    font-size: \(VLFonts.body.pointSize);
    line-height: 140%;
    color: white
    }

    h1 {
    font-size: \(VLFonts.h1.pointSize)
    }

    h2 {
    font-size: \(VLFonts.h2.pointSize)
    }

    h3 {
    font-size: \(VLFonts.h3.pointSize)
    }

    strong {
    color: #f2f2f2;
    font-weight: bolder
    }

    em {
    font-style: italic
    }

    hr {
    color: white
    }
    """
    return stylesheet
  }

}
