//
//  InformationRelease.swift
//  pm0
//
//  Created by Michael Langford on 3/20/18.
//  Copyright © 2018 Rowdy Labs. All rights reserved.
//

import Foundation
import PDFGenerator

struct FaxSizes{
  static let hyperFine = CGSize(width:391.0,height:408.0)
  static let fine = CGSize(width:196.0, height:204.0)
}

extension VLColors{
  static let faxBackgroundColor = UIColor.white
  static let faxBorderColor = UIColor.black
}

extension UILabel{
  convenience init(frameForPDF:CGRect){
    self.init(frame:frameForPDF)
    self.backgroundColor = VLColors.faxBackgroundColor
    self.adjustsFontSizeToFitWidth = true
  }

  func setTextAndAdjustSize(_ text:String){
    self.adjustsFontSizeToFitWidth = true
    self.text = text
  }
}

struct Provider{
  let fax:String
  let name:String
  let address:String
}

struct Patient{
  let name:String
}

let faxBoldFontFaceName = "TrebuchetMS-Bold"
let faxPlainFontFaceName = "TrebuchetMS"
let faxBodyFont = UIFont(name: faxPlainFontFaceName, size: 7)!
let faxBigHeaderFont = UIFont(name: faxBoldFontFaceName, size:10)!


extension UILabel{
  var neededSize:CGSize{
    let maxLabelWidth: CGFloat = frame.width
    let neededSize = sizeThatFits(CGSize(width: maxLabelWidth, height: CGFloat.greatestFiniteMagnitude))
    return neededSize
  }

  var actualFontSize:CGFloat{
    let fullSizeLabel = UILabel()
    fullSizeLabel.font = self.font
    fullSizeLabel.text = self.text
    fullSizeLabel.sizeToFit()

    var actualFontSize = self.font.pointSize * (self.bounds.size.width / fullSizeLabel.bounds.size.width);

    //correct, if new font size bigger than initial
    actualFontSize = actualFontSize < self.font.pointSize ? actualFontSize : self.font.pointSize;
    return actualFontSize
  }

  var heightEstimate:CGFloat{
    return (font.pointSize+CGFloat(2.0)) * CGFloat((text ?? "").split(separator: "\n").count)
  }


}

extension String{
  var lineCount:Int{
    return split(separator:"\n").count
  }

  var heightEstimate:CGFloat{
    return faxBodyFont.pointSize * 1.3 * CGFloat(self.lineCount)
  }
}

extension UIView{
  func showBlackBorder(_ width:CGFloat = 1.0){
    layer.borderWidth = width
    layer.borderColor = UIColor.black.cgColor
  }
}

let debugBounding = false

func samplePDF() -> String {
  let pageSize = FaxSizes.hyperFine
  let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor
  backgroundView.showBlackBorder(0.33)

  let horizontalMargin:CGFloat = 10.0
  let standardVerticalSpace:CGFloat = 8.0
//  let halfStandardVerticalSpace:CGFloat = 8.0/2.0
  let topMargin:CGFloat = 13.0
  let bottomMargin:CGFloat = topMargin * 2.0
  var runningVerticalOffset = topMargin
  let standardFullWidth = pageSize.width-CGFloat(2.0*horizontalMargin)
  let titleViewHeight:CGFloat = 20.0
  let titleView = UILabel(frameForPDF: CGRect(origin:CGPoint(x:horizontalMargin,
                                                             y:runningVerticalOffset),
                                              size:CGSize(width:standardFullWidth,
                                                          height:titleViewHeight)))

  titleView.font = faxBigHeaderFont
  titleView.setTextAndAdjustSize("Patient Information Disclosure Consent Form")
  backgroundView.addSubview(titleView)
  runningVerticalOffset += titleViewHeight
  runningVerticalOffset += standardVerticalSpace


  let patient = Patient(name:"{{{patient}}}")
  let bodyText  =
  """
  This consent form goes over the Health Insurance Portability & Accountability Act of 1996, known as HIPAA. This law specifies how protected health information about you, \(patient.name), may be used and shared.

  You consent to the use of and the disclosure of protected health information for the purposes of:
    - Treatment
    - Payment
    - Health care operations
    - Coordination of care

  You have the right to revoke this Consent by sending a signed notice, in writing. Revocation shall not affect any disclosures already made in reliance on your prior Consent.

  You have the right to request that the indicated providers restrict how protected health information about you is used or disclosed. In the app that sent this document, you chose from a list of restrictions you could impose on the use of your protected health information. You agree that this form represents your indicated selections.

  Restrictions:
     \("✔️ No Additional Restrictions on Use")

  Providers authorized under this form are:
  """

  let mainTextHeight:CGFloat = bodyText.heightEstimate
  let mainText = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: runningVerticalOffset),
           size: CGSize(width:standardFullWidth, height: mainTextHeight)))
  mainText.numberOfLines = 0
  mainText.font = faxBodyFont
  if debugBounding { mainText.showBlackBorder() }
  mainText.text = bodyText
  backgroundView.addSubview(mainText)
  runningVerticalOffset += mainText.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2


  let providers = [Provider(fax: "{{{fax}}}", name: "{{{name}}}", address: "{{{address}}}"),
                   Provider(fax: "{{{fax}}}", name: "{{{name}}}", address: "{{{address}}}")]
  let allProviderText:String = providers.map{ provider in
    let providerText =
      "Provider: \t\(provider.name)\n" +
        "Fax: \t\(provider.fax)\n" +
    "Address: \t\(provider.address)\n\n"
    return providerText
    }.joined()

  let heightEstimate:CGFloat =  allProviderText.heightEstimate
  let providersView = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: runningVerticalOffset),
           size: CGSize(width:standardFullWidth, height: heightEstimate)))
  providersView.adjustsFontSizeToFitWidth = true
  providersView.numberOfLines = 0
  providersView.text = allProviderText
  if debugBounding { providersView.showBlackBorder() }
  providersView.font = faxBodyFont
  backgroundView.addSubview(providersView)
  runningVerticalOffset += providersView.frame.size.height
  runningVerticalOffset += standardVerticalSpace

  let signatureInText =
  """



  Patient: _________________________________________________________________________        Date: {{{dateSigned}}}
            {{{patient}}}

  Document Identifier: {{{DOCU}}}

  """
  let signatureAreaHeight:CGFloat = signatureInText.heightEstimate
  let signatureText = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: pageSize.height-(signatureAreaHeight + bottomMargin)),
           size: CGSize(width:standardFullWidth, height: signatureAreaHeight)))
  signatureText.numberOfLines = 0
  signatureText.font = faxBodyFont
  if debugBounding { signatureText.showBlackBorder() }
  signatureText.text = signatureInText
  backgroundView.addSubview(signatureText)
  runningVerticalOffset += signatureText.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2




  let path = NSTemporaryDirectory().appending("sample1.pdf")
  let dst = URL(fileURLWithPath: path)
  // outputs as Data
  do {
    let data = try PDFGenerator.generated(by: [backgroundView])
    try! data.write(to: dst, options: .atomic)
  } catch (let error) {
    print(error)
  }

  // writes to Disk directly.
  do {
    try PDFGenerator.generate([backgroundView], to: dst)
  } catch (let error) {
    print(error)
  }

  debugPrint("path: \(path)")

  return path
}
