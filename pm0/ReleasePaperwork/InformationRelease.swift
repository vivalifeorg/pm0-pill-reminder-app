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
    self.font = faxBodyFont
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
  let phone:String
}

struct Patient{
  let name:String
  let phoneNumber:String
}

let faxBoldFontFaceName = "TrebuchetMS-Bold"
let faxPlainFontFaceName = "TrebuchetMS"
let faxBodyFontSize = 8
let faxHeaderFontSize = 12
let faxBodyFont = UIFont(name: faxPlainFontFaceName, size: CGFloat(faxBodyFontSize))!
let faxBigHeaderFont = UIFont(name: faxBoldFontFaceName, size: CGFloat(faxHeaderFontSize))!


let providers = [Provider(fax: "{{{fax}}}", name: "{{{name}}}", address: "{{{address}}}", phone: "{{{phone}}}"),
                 Provider(fax: "{{{fax}}}", name: "{{{name}}}", address: "{{{address}}}", phone: "{{{phone}}}")]
//let patient = Patient(name:"{{{patient}}}",phoneNumber:"{{{phoneNumber}}}")

let patient = Patient(name:"Josh Ditel", phoneNumber:"(555) 555-5555")

extension String{
  var lineCount:Int{
    return split(separator:"\n").count
  }

  var heightEstimate:CGFloat{
    return faxBodyFont.pointSize * 1.5 * CGFloat(self.lineCount)
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
  //backgroundView.showBlackBorder(0.5)

  let horizontalMargin:CGFloat = CGFloat(3 * faxHeaderFontSize)
  let standardVerticalSpace:CGFloat = 0.8 * CGFloat(faxHeaderFontSize)
//  let halfStandardVerticalSpace:CGFloat = 8.0/2.0
  let topMargin:CGFloat = 4
  let bottomMargin:CGFloat = 4
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



  let bodyText  =
  """
  This consent form goes over the Health Insurance Portability & Accountability Act of 1996, known as HIPAA. This law specifies how protected health information about you, \(patient.name), may be used and shared.

  You consent to the use of and the disclosure of protected health information for the purposes of:
    - Treatment
    - Payment
    - Health care operations
    - Coordination of care

  You have the right to revoke this Consent by sending a signed notice, in writing. Revocation shall not affect any disclosures already made in reliance on your prior Consent.

  You have the right to request that the indicated providers restrict how protected health information about you is used or disclosed. In the app that sent this document, you chose from a list of restrictions you could impose on the use of your protected health information. You agree that this form represents your indicated restrictions.

  Restrictions:
     \("✔️ No Additional Restrictions on Use")
  """

  let mainTextHeight:CGFloat = bodyText.heightEstimate
  let mainText = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: runningVerticalOffset),
           size: CGSize(width:standardFullWidth, height: mainTextHeight)))
  mainText.numberOfLines = 0
  mainText.font = faxBodyFont
  if debugBounding { mainText.showBlackBorder() }
  mainText.setTextAndAdjustSize(bodyText)
  backgroundView.addSubview(mainText)
  runningVerticalOffset += mainText.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2



  let allProviderText:String = "Authorized Providers: \n\n " + providers.map{ provider in
    let providerText =
      "Provider: \t\(provider.name)\n" +
        "Fax: \t\(provider.fax)\n" +
      "Phone: \t\(provider.phone)\n" +
    "Address: \t\(provider.address)\n\n"
    return providerText
    }.joined()

  let heightEstimate:CGFloat =  allProviderText.heightEstimate
  let providersView = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: runningVerticalOffset),
           size: CGSize(width:standardFullWidth, height: heightEstimate)))
  providersView.adjustsFontSizeToFitWidth = true
  providersView.numberOfLines = 0
  providersView.setTextAndAdjustSize( allProviderText)
  if debugBounding { providersView.showBlackBorder() }
  providersView.font = faxBodyFont
  backgroundView.addSubview(providersView)
  runningVerticalOffset += providersView.frame.size.height
  runningVerticalOffset += standardVerticalSpace


  let vivaLifeIconHeight:CGFloat = 273.0/4
  let vivaIconStart = pageSize.width-vivaLifeIconHeight-(0.5 * horizontalMargin)

  let iconView = UIImageView(frame:
    CGRect(origin:CGPoint(x:pageSize.width-vivaLifeIconHeight-(0.5 * horizontalMargin), y: pageSize.height-(vivaLifeIconHeight)-(0.5 * bottomMargin)),
           size: CGSize(width:vivaLifeIconHeight, height: vivaLifeIconHeight)))
  //iconView.image = UIImage(named:"linkToApp")!
  iconView.contentMode = .scaleAspectFit
  backgroundView.addSubview(iconView)

  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .medium
  let signingDate = dateFormatter.string(from: Date())
  let signatureSuffixText =
  """
  Date: \(signingDate)

  DocumentId: \("EXAMPLE-1-A")
  """

  let signatureSuffixHeight:CGFloat = signatureSuffixText.heightEstimate
  let signatureSuffixLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: pageSize.height-(signatureSuffixHeight + bottomMargin)),
           size: CGSize(width:232, height: signatureSuffixHeight)))
  signatureSuffixLabel.numberOfLines = 0
  signatureSuffixLabel.font = faxBodyFont
  if debugBounding { signatureSuffixLabel.showBlackBorder() }
  signatureSuffixLabel.text = signatureSuffixText
  backgroundView.addSubview(signatureSuffixLabel)
  runningVerticalOffset += signatureSuffixLabel.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2

  let signatureHeight:CGFloat = 50
  let signatureImageX = horizontalMargin * 1.25
  let signatureImageView = UIImageView(frame:
    CGRect(origin:CGPoint(x:signatureImageX, y: signatureSuffixLabel.frame.origin.y - (1.0 * signatureHeight) - standardVerticalSpace),
           size: CGSize(width:116, height: signatureHeight)))
  signatureImageView.image = UIImage(named:"ExampleFaxSignature")!
  signatureImageView.contentMode = .scaleAspectFit
  signatureImageView.backgroundColor = .clear
  let buffer = standardVerticalSpace/2
  var frame = signatureImageView.frame
  frame.origin.x -= buffer
  frame.origin.y -= buffer
  frame.size.width += buffer * 2
  frame.size.height += buffer * 2
  let signatureBufferView = UIView(frame: frame)
  signatureBufferView.layer.borderWidth = 0.25
  signatureBufferView.layer.borderColor = UIColor.black.cgColor
  signatureBufferView.addSubview(signatureImageView)
  signatureImageView.frame = CGRect(origin:CGPoint(x:buffer, y:buffer),size:signatureImageView.frame.size)
  signatureBufferView.backgroundColor = .clear
  signatureBufferView.isOpaque = false
  backgroundView.addSubview(signatureBufferView)

  let signatureHeaderLabelText = "▼ Patient Signature (\(patient.name)) ▼ "
  let signatureHeaderHeight:CGFloat = signatureHeaderLabelText.heightEstimate
  let signatureHeaderLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: signatureBufferView.frame.origin.y - signatureHeaderHeight - standardVerticalSpace),
           size: CGSize(width:vivaIconStart-horizontalMargin, height: signatureHeaderHeight)))
  signatureHeaderLabel.minimumScaleFactor = 1.0
  signatureHeaderLabel.layer.borderWidth = 0
  signatureHeaderLabel.numberOfLines = 0
  signatureHeaderLabel.font = faxBodyFont
  if debugBounding { signatureHeaderLabel.showBlackBorder() }
  signatureHeaderLabel.text = signatureHeaderLabelText
  backgroundView.addSubview(signatureHeaderLabel)
  runningVerticalOffset += signatureHeaderLabel.frame.size.height
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
