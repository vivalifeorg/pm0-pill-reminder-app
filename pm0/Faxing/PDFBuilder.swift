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
  static let hyperFine = CGSize(width:391.0,height:408.0) //standard size in 2018
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


//one of the few fax friendly typefaces on the iPhone
let faxBoldFontFaceName = "TrebuchetMS-Bold"
let faxPlainFontFaceName = "TrebuchetMS"

//These are somewhat winged
let faxBodyFontSize = 6
let faxHeaderFontSize = 12
let faxSubHeaderFontSize = 10
let faxBodyMinimumSize = 8
let faxBodyFont = UIFont(name: faxPlainFontFaceName, size: CGFloat(faxBodyFontSize))!
let faxBigHeaderFont = UIFont(name: faxBoldFontFaceName, size: CGFloat(faxHeaderFontSize))!
let faxSubHeaderFont = UIFont(name: faxBoldFontFaceName, size: CGFloat(faxSubHeaderFontSize))!

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

func addMedication (dose:String, recordedTime:String, plannedTime:String, view:UIView, y offset:CGFloat, fontOverride:UIFont? = nil) -> CGFloat{

  let frame = CGRect(x:horizontalMargin, y: offset, width: 300, height: 15)
  let entry = FaxMedlogAdministeredEntry(frame:frame, dose:dose, recordedTime:recordedTime, plannedTime:plannedTime)
  view.addSubview(entry)

  var offset = offset
  offset += entry.frame.size.height
  offset += 0

  return offset
}

func removeMedication (dose:String, recordedTime:String, plannedTime:String, view:UIView, y offset:CGFloat, fontOverride:UIFont? = nil) -> CGFloat{

  let frame = CGRect(x:horizontalMargin, y: offset, width: 300, height: 15)
  let entry = FaxMedlogRemovedEntry(frame:frame, dose:dose, recordedTime:recordedTime, plannedTime:plannedTime)
  view.addSubview(entry)

  var offset = offset
  offset += entry.frame.size.height
  offset += 0

  return offset
}


func addStandardText(text body:String, view:UIView, y offset:CGFloat, fontOverride:UIFont? = nil, textAlignment:NSTextAlignment = .left) -> CGFloat{
  let font = fontOverride ?? faxBodyFont
  let bodyHeight:CGFloat = body.height(withConstrainedWidth: standardFullWidth,
                                           font:font)
  let label = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin, y: offset),
           size: CGSize(width:standardFullWidth, height: bodyHeight)))
  label.textAlignment = textAlignment
  label.numberOfLines = 0
  label.font = font
  if debugBounding { label.showBlackBorder() }
  label.minimumScaleFactor = CGFloat(font.pointSize)/CGFloat(faxBodyMinimumSize)
  label.setTextAndAdjustSize(body)
  view.addSubview(label)

  var offset = offset
  offset += label.frame.size.height
  offset += standardVerticalSpace/2

  return offset
}

func addHipaaText(view:UIView, y offset:CGFloat) -> CGFloat{

  let body = "IMPORTANT: This facsimile transmission contains confidential information, some or all of which may be protected health information as defined by the federal Health Insurance Portability & Accountability Act (HIPAA) Privacy Rule. This transmission is intended for the exclusive use of the individual or entity to whom it is addressed and may contain information that is proprietary, privileged, confidential and/or exempt from disclosure under applicable law. If you are not the intended recipient (or an employee or agent responsible for delivering this facsimile transmission to the intended recipient), you are hereby notified that any disclosure, dissemination, distribution or copying of this information is strictly prohibited and may be subject to legal restriction or sanction. Please notify the sender by telephone (number listed above) to arrange the return or destruction of the information and all copies."

  let textHeight = body.height(withConstrainedWidth: standardFullWidth, font: faxBodyFont)
  let y = view.frame.size.height - textHeight - bottomMargin

  return addStandardText(text: body, view: view, y: y)
}

//These are roughtly "What looks good" and looks alright once faxed on a crappy machine
let horizontalMargin:CGFloat = 25 //CGFloat(3 * faxHeaderFontSize)
let topMargin:CGFloat = 25
let bottomMargin:CGFloat = 25
let standardVerticalSpace:CGFloat = 8
let standardFullWidth = pageSize.width-CGFloat( 2.0 * horizontalMargin)
let pageSize = FaxSizes.hyperFine

func addSubheader(_ text:String, view: UIView, y offset:CGFloat)->CGFloat{

  var runningVerticalOffset = offset
  runningVerticalOffset += standardVerticalSpace/2 //#subheaders almost always are in the middle but need space

  let titleViewHeight:CGFloat = text.height(withConstrainedWidth: standardFullWidth, font: faxSubHeaderFont)
  let titleView = UILabel(frameForPDF: CGRect(origin:CGPoint(x:horizontalMargin,
                                                             y:runningVerticalOffset),
                                              size:CGSize(width:standardFullWidth,
                                                          height:titleViewHeight)))

  titleView.font = faxSubHeaderFont
  titleView.numberOfLines = 0
  titleView.setTextAndAdjustSize(text)
  view.addSubview(titleView)

  runningVerticalOffset += titleViewHeight
  runningVerticalOffset += standardVerticalSpace/2

  return runningVerticalOffset
}

func addHeader(_ text:String, view: UIView, y offset:CGFloat)->CGFloat{

  let titleViewHeight:CGFloat = text.height(withConstrainedWidth: standardFullWidth, font: faxBigHeaderFont)
  let titleView = UILabel(frameForPDF: CGRect(origin:CGPoint(x:horizontalMargin,
                                                             y:offset),
                                              size:CGSize(width:standardFullWidth,
                                                          height:titleViewHeight)))

  titleView.font = faxBigHeaderFont
  titleView.numberOfLines = 0
  titleView.setTextAndAdjustSize(text)
  view.addSubview(titleView)

  var runningVerticalOffset = offset
  runningVerticalOffset += titleViewHeight
  runningVerticalOffset += standardVerticalSpace

  return runningVerticalOffset
}

func coverPage(totalPageCountIncludingCoverPage pageCount:Int, to:String, forPatient:String) -> DocumentRef {

  let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor




  var runningVerticalOffset:CGFloat = topMargin
  runningVerticalOffset = addHeader("Cover Page", view: backgroundView, y: runningVerticalOffset)

  //The uppercase A is intentional
  let appBannerInfo = "VivALife: https://www.vivalife.care"
  let bodyText  =
  """
  Total Pages:

    \(pageCount)


  To:

    \(to)


  From:

    \(forPatient) [Sent from Patient]


  For Patient:

    \(forPatient)


  Sent with:

    \(appBannerInfo)

  """

  runningVerticalOffset = addStandardText(text: bodyText, view: backgroundView, y: runningVerticalOffset)

  //warn the dr office to not assume return communication is secure
  runningVerticalOffset = addSubheader("Do not send a return fax to this number", view: backgroundView, y: runningVerticalOffset)

  runningVerticalOffset += standardVerticalSpace
  runningVerticalOffset += standardVerticalSpace

  //Add a link to the website of the app
  let QRIconHeight:CGFloat = 50
  let qrView = UIImageView(frame:
    CGRect(origin:
      CGPoint(x: (backgroundView.frame.size.width - QRIconHeight)/CGFloat(2),
              y: runningVerticalOffset),
           size: CGSize(
            width:QRIconHeight,
            height: QRIconHeight)))
  qrView.image = Asset.Fax.qrCodeForCover.image
  qrView.contentMode = .scaleAspectFit
  backgroundView.addSubview(qrView)
  runningVerticalOffset += QRIconHeight
  runningVerticalOffset += 2

  //add a note to make the office staff to feel safe to go to the QR code on their phone
  runningVerticalOffset += addStandardText(text: "No Patient Data in QR Code", view: backgroundView, y: runningVerticalOffset, fontOverride: nil, textAlignment: .center)
  runningVerticalOffset += standardVerticalSpace

  //add a note stating this text is HIPAA related
  runningVerticalOffset = addHipaaText(view: backgroundView, y: runningVerticalOffset)


  // Place a branding icon in the top right corner (written last = written atop)
  let vivaLifeIconHeight:CGFloat = 50
  let iconView = UIImageView(frame:
    CGRect(origin:
      CGPoint(x:backgroundView.frame.size.width - horizontalMargin - vivaLifeIconHeight,
              y:topMargin),
           size: CGSize(
            width:vivaLifeIconHeight,
            height: vivaLifeIconHeight)))
  iconView.image = Asset.Fax.blackAndWhiteLogo.image
  iconView.contentMode = .scaleAspectFit
  backgroundView.addSubview(iconView)

  return fileOfPDFForViews([backgroundView],fileSuffix:"\(NSUUID().uuidString)-coverPage.pdf")
}

///Convert PDF to view
func fileOfPDFForViews(_ views:[UIView],fileSuffix:String)->DocumentRef{
  let path = NSTemporaryDirectory().appending(fileSuffix)
  let dst = URL(fileURLWithPath: path)
  do {
    try PDFGenerator.generate(views, to: dst)
  } catch (let error) {
    print(error)
  }

  return dst
}

//used to format some pages that indent
extension String{
  func addingIndentation(_ n: Int) -> String{
    let indentation = String(repeating:" ", count:n)
    return "\(indentation)\(self.replacingOccurrences(of: "\n", with: "\n\(indentation)"))"
  }
}

///filters out address/title fluff on lines we should not output if the patient didn't enter them
func omitIfAllWhitespace(_ s:String)->String{
  let labels = ["Phone", "Fax"]
  let detitledString = labels.reduce(s){$0.replacingOccurrences(of:$1, with:"")}
  let bannedCharacters = CharacterSet.whitespacesAndNewlines.union(
      CharacterSet.init(charactersIn: ",.:"))
  let trimmedString = detitledString.trimmingCharacters(in: bannedCharacters)

  guard trimmedString != "" else {
    return ""
  }

  return s
}

extension DoctorInfo:DocumentTopic{
  ///Turns doctors into addresses
  var topicText:String{
    let provider = self
    let providerText =
      omitIfAllWhitespace("\(provider.name)\n") +
      omitIfAllWhitespace("\(provider.address.displayable.addingIndentation(2))\n") +
      omitIfAllWhitespace("  Phone: \t\(provider.phone.number)\n") +
      omitIfAllWhitespace("  Fax: \t\(provider.fax.number)\n\n")
    return providerText
  }
}


extension Array{
///Used to paginate things, this finds discrete sized chunks of collections

  func chunk(firstChunkSize:Int, otherChunkSize:Int) -> [[Element]]{
    let firstChunk = first(n:firstChunkSize)
    let rest = Array(dropFirst(firstChunkSize))
    let chunks:[[Element]] = [firstChunk] + rest.chunk(otherChunkSize)
    return chunks
  }

  func chunk(_ chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: self.count, by: chunkSize).map({ (startIndex) -> [Element] in
      let endIndex = (startIndex.advanced(by: chunkSize) > self.count) ?
          self.count-startIndex :
          chunkSize
      return Array(self[startIndex..<startIndex.advanced(by: endIndex)])
    })
  }

  func first(n:Int)->Array{
    if count > n{
      return Array<Element>(dropLast(count-n))
    }
    return self
  }
}

///Advances to the next page
func newPage( backgroundView:inout UIView, viewList:inout [UIView], header:String)->CGFloat{
  backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  viewList.append(backgroundView)
  return addHeader(header, view: backgroundView, y: topMargin)
}


///Creates a signature block
func signatureBlock(_ signatureInfo:SignatureInfo, patient:PatientInfo)->UIView{
  let view=UIView()

  var runningVerticalOffset:CGFloat = 0

  //This is a small drawing above the signature to call attention to it
  let signatureHeaderLabelText = "▼ Patient Signature (\(patient.lastDocumentName)) ▼ "
  let signatureHeaderHeight:CGFloat = signatureHeaderLabelText.heightEstimate
  let signatureHeaderLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:0, y: 0),
           size: CGSize(width:standardFullWidth, height: signatureHeaderHeight)))
  signatureHeaderLabel.minimumScaleFactor = 1.0
  signatureHeaderLabel.layer.borderWidth = 0
  signatureHeaderLabel.numberOfLines = 0
  signatureHeaderLabel.font = faxBodyFont
  if debugBounding { signatureHeaderLabel.showBlackBorder() }
  signatureHeaderLabel.text = signatureHeaderLabelText
  view.addSubview(signatureHeaderLabel)
  runningVerticalOffset += signatureHeaderLabel.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2

  //Signature Images are currently coming out at 335:150 on the iPhone x
  let signatureHeight:CGFloat = 50
  let signatureImageX = horizontalMargin * 0.25
  let signatureImageView = UIImageView(frame:
    CGRect(origin:CGPoint(x:signatureImageX, y: runningVerticalOffset),
           size: CGSize(width:CGFloat(335/3), height: signatureHeight)))
  signatureImageView.image = signatureInfo.image
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
  view.addSubview(signatureBufferView)
  runningVerticalOffset += signatureBufferView.bounds.size.height


  let signatureDateFormatter = DateFormatter()
  signatureDateFormatter.dateStyle = .medium
  let signingDate = signatureDateFormatter.string(from: Date())

  let signatureSuffixText = "Signed: \(signingDate)\n \n \n \n"
  //Adds signature file and date signed.
  let signatureSuffixHeight:CGFloat = signatureSuffixText.heightEstimate
  let signatureSuffixLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:0, y: runningVerticalOffset),
           size: CGSize(width: signatureBufferView.bounds.width, height: signatureSuffixHeight)))
  signatureSuffixLabel.numberOfLines = 0
  signatureSuffixLabel.font = faxBodyFont
  if debugBounding { signatureSuffixLabel.showBlackBorder() }
  signatureSuffixLabel.text = signatureSuffixText
  view.addSubview(signatureSuffixLabel)
  runningVerticalOffset += signatureSuffixLabel.frame.size.height
  runningVerticalOffset += standardVerticalSpace/2


  let width = view.subviews.map{
      $0.frame.size.width+$0.frame.origin.x
    }.reduce(CGFloat(0)){ (lhs:CGFloat,rhs:CGFloat) in
        max(lhs,rhs)
    }
  let height = view.subviews.map{
    $0.frame.size.height+$0.frame.origin.y
    }.reduce(CGFloat(0)){ (lhs:CGFloat,rhs:CGFloat) in
      max(lhs,rhs)
  }
  view.frame = CGRect(origin:CGPoint(x:0,y:0),
                      size:CGSize(width:width, height:height))
  return view
}

/**
 Generates a general HIPAA conscent form to allow the patient to allow
    the doctor to use their data for operational purposes,
    as well as share it among other care professionals.
 */
func hipaaConsentForm(doctors:[DocumentTopic],
                      patient:PatientInfo,
                      signatureInfo:SignatureInfo,
                      restrictions:[String] = ["No Restrictions Added by Patient"]) -> DocumentRef {
  let pageSize = FaxSizes.hyperFine

  var backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor

  let title = "Patient Information Disclosure Consent Form"
  var runningVerticalOffset = addHeader(title, view: backgroundView, y: topMargin)

  //This is parsed down from the documents provided by Hampton in Jan/Feb 2018 from Oconee Heath (sp?).
  let bodyText  =
  """
  This consent form goes over the Health Insurance Portability & Accountability Act of 1996, known as HIPAA. This law specifies how protected health information about you, \(patient.lastDocumentName), may be used and shared.

  You consent to the use of and the disclosure of protected health information for the purposes of:
    - Treatment
    - Payment
    - Health care operations
    - Coordination of care

  You have the right to revoke this Consent by sending a signed notice, in writing. Revocation shall not affect any disclosures already made in reliance on your prior Consent.

  You have the right to request that the indicated providers restrict how protected health information about you is used or disclosed. In the app that sent this document, you had an opportunity to request restrictions on use of your personal health information. You agree that this form represents your indicated restrictions.
  """
  runningVerticalOffset = addStandardText(text: bodyText, view: backgroundView, y: runningVerticalOffset)

  ///I am not sure we really need to have a restrictions section, but why not
  runningVerticalOffset = addSubheader("Restrictions", view: backgroundView, y: runningVerticalOffset)
  let allRestrictions = restrictions.map{
  """
    \("✔️ \($0)")
  """}.joined(separator: "\n")
  runningVerticalOffset = addStandardText(text: allRestrictions,
                                          view: backgroundView,
                                          y: runningVerticalOffset)

  ///Perhaps the title needs work
  let titleOfListOfDoctorsSection = "Authorized Providers"
  runningVerticalOffset = addSubheader(titleOfListOfDoctorsSection,
                                       view: backgroundView,
                                       y: runningVerticalOffset)

  let dedupedDoctors = Array(Set(doctors.map{$0.topicText}))


  //pagination
  var viewList = [backgroundView]
  let countOnFirstPage = 2
  let countOnSubsequentPages = 3
  let paginatedProvider:[[String]] =
    dedupedDoctors.chunk(firstChunkSize:countOnFirstPage,
                         otherChunkSize:countOnSubsequentPages)
  let pageCount = paginatedProvider.count
  for sheetIndex in 0..<pageCount{
      //we have multiple pages

    if sheetIndex != 0 {
        //make a new page
      let title = "\(titleOfListOfDoctorsSection) (Continued)"
      runningVerticalOffset = newPage(backgroundView: &backgroundView,
                                      viewList: &viewList,
                                      header: title)
    }

    for medicalProvider in paginatedProvider[sheetIndex]{
      runningVerticalOffset = addStandardText(text: medicalProvider, view: backgroundView, y: runningVerticalOffset, fontOverride: nil, textAlignment: .left)
    }
  }
  runningVerticalOffset += standardVerticalSpace

  //Add the signature, ensure it doesn't go past margin by making a new page if so
  let sigBlock = signatureBlock(signatureInfo, patient: patient)
  let sigBlockSpace = (runningVerticalOffset + sigBlock.bounds.size.height + standardVerticalSpace)
  if sigBlockSpace > pageSize.height - bottomMargin {
    runningVerticalOffset = newPage(backgroundView: &backgroundView, viewList: &viewList, header: "")
  }
  sigBlock.frame = CGRect(origin: CGPoint(x:horizontalMargin,
                                          y:runningVerticalOffset),
                          size: sigBlock.bounds.size)
  backgroundView.addSubview(sigBlock)
  runningVerticalOffset += sigBlock.bounds.size.height
  runningVerticalOffset += standardVerticalSpace

  let documentId = "VL-HIPAA-RELEASE-000001-A"
  addStandardFooters(viewList: viewList, documentId: documentId )
  return fileOfPDFForViews(viewList, fileSuffix: "\(NSUUID().uuidString)-\(documentId).pdf")
}

extension MedicationLogEvent{
  var timeRendering:String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    let tz:TimeZone = timezone
    return "\(dateFormatter.string(from: timestamp)) \(tz.abbreviation(for:timestamp) ?? "")"
  }

  var doseRendering:String{
    return "\(dosage.name), \(dosage.bodyString)"
  }
}


///Stamps a footer on the bottom of the document page
func addFooter(view:inout UIView,leftText:String="",centerText:String="",rightText:String=""){

  let labelWidth = (pageSize.width/3.0)-8.0
  let labelTop = pageSize.height-bottomMargin+2.0 //In the bottom margin

  let leftFooterLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:horizontalMargin,
                          y:labelTop),
           size: CGSize(width:labelWidth,
                        height: leftText.heightEstimate)))
  leftFooterLabel.textAlignment = .left
  leftFooterLabel.text = leftText


  let centerFooterLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x:pageSize.width/2-((pageSize.width/3)/2), y:labelTop),
           size: CGSize(width:labelWidth,
                        height: centerText.heightEstimate)))
  centerFooterLabel.textAlignment = .center
  centerFooterLabel.text = centerText

  let rightFooterLabel = UILabel(frameForPDF:
    CGRect(origin:CGPoint(x: pageSize.width-labelWidth-horizontalMargin,
                          y: labelTop),
           size: CGSize(width:labelWidth,
                        height: rightText.heightEstimate)))
  rightFooterLabel.textAlignment = .right
  rightFooterLabel.text = rightText

  [leftFooterLabel,centerFooterLabel,rightFooterLabel].forEach{ footerLabel in
    footerLabel.numberOfLines = 0
    footerLabel.font = faxBodyFont
    if debugBounding { footerLabel.showBlackBorder() }
    view.addSubview(footerLabel)
  }
}

func medlogForm(events: [MedicationLogEvent],
                patient:PatientInfo) -> DocumentRef {
  let pageSize = FaxSizes.hyperFine

  var backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: pageSize))
  backgroundView.backgroundColor = VLColors.faxBackgroundColor

  let title = "Patient Medication Log"
  var runningVerticalOffset = addHeader(title, view: backgroundView, y: topMargin)

  let bodyText  =
  """
  \(patient.lastDocumentName) indicates they took these medications at these times.

  Patients sometimes remove checkmarks. This removal is indicated with the word "!REMOVED".

  This indicates an earlier entry that matches that name and scheduled time did not occur.

  These are provided for purposes of completeness.

  """
  runningVerticalOffset = addStandardText(text: bodyText, view: backgroundView, y: runningVerticalOffset)


  var viewList:[UIView] = [backgroundView]
  if events.count == 0 {
    runningVerticalOffset = addStandardText(text: "No medication log to report", view: backgroundView, y: runningVerticalOffset)
  }else{

    //pagination
    let eventSheets = events.chunk(firstChunkSize:16, otherChunkSize: 20)
    runningVerticalOffset = addSubheader("\(events.count) Total Entries: [\(eventSheets[0].count) entries on this page]", view: backgroundView, y: runningVerticalOffset)
    for sheetIndex in 0..<eventSheets.count{

      //different header for subsequent pages
      if sheetIndex != 0 {
        let title = "Patient Medication Log Continued: [\(eventSheets[sheetIndex].count) entries on this page]"
        runningVerticalOffset = newPage(backgroundView: &backgroundView,
                                        viewList: &viewList,
                                        header: title)
      }

      //we assume we have at least 1 entry for the page, because the chunking algorithm shouldn't
        //have spit out a chunk otherwise
      runningVerticalOffset = addMedication(dose: "DOSAGE", recordedTime: "TIME RECORDED", plannedTime: "SCHEDULED TIME", view: backgroundView, y: runningVerticalOffset)
      eventSheets[sheetIndex].forEach{ entry in
        if entry.eventType == .markedMedicationTaken{
          runningVerticalOffset = addMedication(dose: entry.doseRendering,
                                              recordedTime: entry.timeRendering,
                                              plannedTime: entry.sectionName,
                                              view: backgroundView,
                                              y: runningVerticalOffset)
        } else if entry.eventType == .unmarkedMedicationTaken {
          runningVerticalOffset = removeMedication(dose: entry.doseRendering,
                                                 recordedTime: entry.timeRendering,
                                                 plannedTime: entry.sectionName,
                                                 view: backgroundView,
                                                 y: runningVerticalOffset)
        }
      }
    }
  }


  let documentId = "VL-MEDICATION-LOG-000002-B"
  addStandardFooters(viewList: viewList, documentId: documentId )
  return fileOfPDFForViews(viewList, fileSuffix: "\(NSUUID().uuidString)-\(documentId).pdf")
}

//adds footers to bottom of inner documents, counts pages per document
func addStandardFooters(viewList:[UIView], documentId:String){
  let exportDate = footerDateFormatter.string(from: Date())
  for pageIndex in 0..<viewList.count {
    var page = viewList[pageIndex]
    let pageNumber = pageIndex + 1
    addFooter(view:&page,
              leftText: "\(documentId)",
      centerText: "Page \(pageNumber)/\(viewList.count)",
      rightText: "Exported \(exportDate)")
  }
}

fileprivate let footerDateFormatter:DateFormatter={
  let dateFormatter = DateFormatter()
  dateFormatter.dateStyle = .medium
  dateFormatter.timeStyle = .medium
  return dateFormatter
}()
