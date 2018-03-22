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
let faxBodyMinimumSize = 8
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

extension String {
  func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

    return ceil(boundingBox.height)
  }

  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

    return ceil(boundingBox.width)
  }
}

func addStandardText(text body:String, backgroundView:UIView, y offset:CGFloat) -> CGFloat{
  let bodyHeight:CGFloat = body.height(withConstrainedWidth: standardFullWidth,
                                           font:faxBodyFont)
  let label = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: offset),
           size: CGSize(width:standardFullWidth, height: bodyHeight)))
  label.numberOfLines = 0
  label.font = faxBodyFont
  if debugBounding { label.showBlackBorder() }
  label.minimumScaleFactor = CGFloat(faxBodyFontSize)/CGFloat(faxBodyMinimumSize)
  label.setTextAndAdjustSize(body)
  backgroundView.addSubview(label)


  var offset = offset
  offset += label.frame.size.height
  offset += standardVerticalSpace/2

  return offset
}

func addHipaaText(backgroundView:UIView, y offset:CGFloat) -> CGFloat{

  let body = "IMPORTANT: This facsimile transmission contains confidential information, some or all of which may be protected health information as defined by the federal Health Insurance Portability & Accountability Act (HIPAA) Privacy Rule. This transmission is intended for the exclusive use of the individual or entity to whom it is addressed and may contain information that is proprietary, privileged, confidential and/or exempt from disclosure under applicable law. If you are not the intended recipient (or an employee or agent responsible for delivering this facsimile transmission to the intended recipient), you are hereby notified that any disclosure, dissemination, distribution or copying of this information is strictly prohibited and may be subject to legal restriction or sanction. Please notify the sender by telephone (number listed above) to arrange the return or destruction of the information and all copies."

  return addStandardText(text: body, backgroundView: backgroundView, y: offset)
}

let horizontalMargin:CGFloat = CGFloat(3 * faxHeaderFontSize)
let topMargin:CGFloat = 4
let standardVerticalSpace:CGFloat = 8
let standardFullWidth = pageSize.width-CGFloat(2.0*horizontalMargin)
let pageSize = FaxSizes.hyperFine

func addTitleText(_ text:String, backgroundView: UIView, y offset:CGFloat)->CGFloat{

  let titleViewHeight:CGFloat = text.height(withConstrainedWidth: standardFullWidth, font: faxBigHeaderFont)
  let titleView = UILabel(frameForPDF: CGRect(origin:CGPoint(x:horizontalMargin,
                                                             y:offset),
                                              size:CGSize(width:standardFullWidth,
                                                          height:titleViewHeight)))

  titleView.font = faxBigHeaderFont
  titleView.numberOfLines = 0
  titleView.setTextAndAdjustSize(text)
  backgroundView.addSubview(titleView)

  var runningVerticalOffset = offset
  runningVerticalOffset += titleViewHeight
  runningVerticalOffset += standardVerticalSpace

  return runningVerticalOffset
}

func coverPage(totalPageCountIncludingCoverPage pageCount:Int, to:String, from:String, forPatient:String) -> String {


  let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor

  var runningVerticalOffset:CGFloat = topMargin
  runningVerticalOffset = addTitleText("Cover Page\n\nDo not return fax to this number", backgroundView: backgroundView, y: runningVerticalOffset)

  let appBannerInfo = "VivALife: https://www.vivalife.care"
  let bodyText  =
  """
  To:

    \(to)


  From:

    \(from)


  For Patient:

    \(forPatient)


  Sent with:

    \(appBannerInfo)

  """

  runningVerticalOffset = addStandardText(text: bodyText, backgroundView: backgroundView, y: runningVerticalOffset)
  runningVerticalOffset = addHipaaText(backgroundView: backgroundView, y: runningVerticalOffset)

  return fileOfPDFForView(backgroundView,fileSuffix:"\(NSUUID().uuidString)-coverPage.pdf")
}

func fileOfPDFForView(_ view:UIView,fileSuffix:String)->String{
  let path = NSTemporaryDirectory().appending(fileSuffix)
  let dst = URL(fileURLWithPath: path)
  // outputs as Data
  do {
    let data = try PDFGenerator.generated(by: [view])
    try! data.write(to: dst, options: .atomic)
  } catch (let error) {
    print(error)
  }

  // writes to Disk directly.
  do {
    try PDFGenerator.generate([view], to: dst)
  } catch (let error) {
    print(error)
  }

  return path
}

func samplePDF() -> String {
  let pageSize = FaxSizes.hyperFine

  let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor

  let horizontalMargin:CGFloat = CGFloat(3 * faxHeaderFontSize)
  let standardVerticalSpace:CGFloat = 0.8 * CGFloat(faxHeaderFontSize)
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



  let allProviderText:String = "\n\nAuthorized Providers: \n\n" + providers.map{ provider in
    let providerText =
    " \(provider.name)\n" +
    "   Address: \(provider.address)\n" +
    "   Phone: \t\(provider.phone)\n" +
    "   Fax: \t\(provider.fax)\n\n"

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




  return fileOfPDFForView(backgroundView, fileSuffix: "\(NSUUID().uuidString)-hipaaReleaseDoc.pdf")
}
