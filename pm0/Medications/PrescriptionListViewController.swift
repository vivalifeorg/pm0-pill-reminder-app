//
//  PrescriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//


import DZNEmptyDataSet
import UIKit


extension NSAttributedString{
  // concatenate attributed strings
  static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
  {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
  }
}

import UIKit


extension Timeslot{

  func floridDescription(maxTimeWidth:Int = 12, foregroundColor:UIColor = Asset.Colors.vlTextColor.color,
                         backgroundColor:UIColor = Asset.Colors.vlCellBackgroundCommon.color) -> NSAttributedString{

    let captionFont = UIFont.preferredFont(forTextStyle: .caption1)
    let labelAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:foregroundColor,
      .backgroundColor:backgroundColor,
      .strokeWidth:-1.0,
      .font :UIFont.monospacedDigitSystemFont(ofSize:captionFont.pointSize,weight:.black)
    ]


    var paddedTimeString = timeString
    while paddedTimeString.count < maxTimeWidth{
      paddedTimeString = " \(paddedTimeString)"
    }


    let displayCorrectedTimeString = "  \(paddedTimeString)     \t\(name)".padding(toLength: 200, withPad: " ", startingAt: 0)
    return NSAttributedString(string:displayCorrectedTimeString, attributes:labelAttributes)

  }
}

struct Zebra: IteratorProtocol {
  mutating func next() -> Bool? {
    return next()
  }

  var isDark = false

  mutating func next() -> Bool {
    let currentDark = !isDark
    isDark = currentDark
    return currentDark
  }
}

extension Dosage{

  private var titleAttributes: [NSAttributedStringKey: Any] {
    return [
      .foregroundColor:Asset.Colors.vlTextColor.color,
      .strokeWidth:-3.0 //makes it "bold" no matter what the font
    ]
  }

  var attributedTitle:NSAttributedString{
    return NSAttributedString(string:name,
                              attributes:titleAttributes)
  }

  var bodyString:String{
    return "\(quantity.followedByIfNotNil(" of "))\(unitDescription.spaceAfterOrEmpty)\(form ?? "")"
  }

  var doseAttributes: [NSAttributedStringKey: Any]{
    return  [
      .foregroundColor:Asset.Colors.vlTextColor.color,
      .obliqueness:0.2
    ]
  }
  var attributedBody:NSAttributedString{

    return NSAttributedString(string:bodyString,
                              attributes:doseAttributes)
  }


  
  var extendedAttributedBody:NSAttributedString{


    let labelAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:Asset.Colors.vlTextColor.color,
      .strokeWidth:-1.9
    ]
    let scheduleTextAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:Asset.Colors.vlSecondaryTextColor.color,
      .strokeWidth:-0.1
    ]




    let timeslotIndent = NSAttributedString(string:" ")
    var zebra = Zebra()
    let sortedTimeslots = schedule.timeslots.sorted(by: { (lhs, rhs) -> Bool in
      lhs < rhs
    })
    let timeslots:[NSAttributedString] = sortedTimeslots.map{ (timeslot:Timeslot) in
      if zebra.next(){
        return timeslotIndent + timeslot.floridDescription( backgroundColor:Asset.Colors.vlZebraDarker.color)
      }else{
        return timeslotIndent + timeslot.floridDescription(backgroundColor: Asset.Colors.vlZebraLighter.color)
      }
    }
    let newline = NSAttributedString(string:"\n")

    let take = NSAttributedString(string:" Take: ",attributes:labelAttributes) + NSAttributedString(string: bodyString)
    let scheduleHeader = NSMutableAttributedString(string:" Schedule: ",attributes:labelAttributes)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 2
    scheduleHeader.addAttributes([NSAttributedStringKey.paragraphStyle:paragraphStyle],
      range: NSRange(location: 0, length: scheduleHeader.string.count))

    let otherLines:[NSAttributedString] = [scheduleHeader] + timeslots
    return otherLines.reduce(take){$0 + newline + $1}
  }
}

extension Prescription{

  var title:String{
    return dosage?.description ?? "Drug"
  }

//  var subTitle:String{
//    return conditionPrescribedFor.map{"for \($0)"} ?? "for <Condition>"
//  }
}

struct PrescriptionListViewModel{
  var prescriptions:[Prescription] = []

  subscript(indexPath:IndexPath)->Prescription{
    return prescriptions[indexPath.row]
  }

  var editingIndex:Int?

  mutating func deleteItemAt(index:Int){
    editingIndex = nil
    prescriptions = LocalStorage.PrescriptionStore.load()
    prescriptions.remove(at:index)
    LocalStorage.PrescriptionStore.save(prescriptions)
  }

  mutating func receivedPrescription(_ rx:Prescription){
    prescriptions = LocalStorage.PrescriptionStore.load()
    if let editingIndex = editingIndex {
      prescriptions[editingIndex] = rx
    }else{
      prescriptions.append(rx)
    }
    LocalStorage.PrescriptionStore.save(prescriptions)
  }
}

class PrescriptionListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var viewModel = PrescriptionListViewModel()


  @IBAction func unwindToPrescriptionListCancel(segue:UIStoryboardSegue){}
  @IBAction func unwindToPrescriptionList(segue:UIStoryboardSegue){

    guard let rx = (segue.source as? ScheduleListViewController)?.entryInfo?.prescription else{
        return
    }

    viewModel.receivedPrescription(rx)
    guard isViewLoaded else {
      return
    }
    tableView.reloadData()
  }

  private var alertController :UIAlertController?
  func deleteRxTableRowAction(_ action:UITableViewRowAction, indexPath:IndexPath){
    // delete item at indexPath
    let alert = UIAlertController(title: "Delete Rx?",
                                  message: "Are you sure you want to delete this Rx?",
                                  preferredStyle: .alert)

    alert.addAction(
      UIAlertAction(title: NSLocalizedString("Keep Rx",
                                             comment: "Keep Rx"),
                    style: .cancel,
                    handler:nil)
    )

    alert.addAction(
      UIAlertAction(title: NSLocalizedString("Delete Rx",
                    comment: "Delete Rx"),
        style: .destructive){ _ in
          self.viewModel.deleteItemAt(index: indexPath.row)
          self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    )

    self.alertController = alert
    self.present(alert, animated: true, completion: nil)
  }

  func editRxAction(_ action:UITableViewRowAction, indexPath:IndexPath){
    viewModel.editingIndex = indexPath.row
    self.performSegue(withIdentifier: StoryboardSegue.PrescriptionListViewController.showPrescriptionEditEntry.rawValue, sender: self)
  }

  @IBAction func tappedAddButton(_ sender:Any){
    viewModel.editingIndex = nil
    self.performSegue(withIdentifier: StoryboardSegue.PrescriptionListViewController.showPrescriptionAddEntry.rawValue, sender: self)
  }
  

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return [
      UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteRxTableRowAction),
      UITableViewRowAction(style: .normal, title: "Edit", handler:editRxAction)
    ]
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier ?? "" {
    case StoryboardSegue.PrescriptionListViewController.showPrescriptionEditEntry.rawValue:
      guard let editIndex = viewModel.editingIndex else{
        debugPrint("RxEntry")
        return //aka making new
      }
      debugPrint("EditingRx \(viewModel.prescriptions[editIndex].title)")
      let rxEntry = (segue.destination as! UINavigationController).viewControllers.first 
            as! PrescriptionEntryViewController
      rxEntry.prescription = viewModel.prescriptions[editIndex]
    default:
      debugPrint("Other(rx)")
      let rxEntry = (segue.destination as! UINavigationController).viewControllers.first
        as! PrescriptionEntryViewController
      rxEntry.prescription = nil
      viewModel.editingIndex = nil //clear it when we return, etc
    }
  }

  var lastEditSelectionIndex:Int? = nil

  @IBAction func addTapped(_ sender:UIButton){
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.dataSource = self
    tableView.delegate = self
    tableView.emptyDataSetSource = self;
    tableView.emptyDataSetDelegate = self;
    tableView.tableHeaderView = UIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    viewModel.prescriptions = LocalStorage.PrescriptionStore.load()

    guard isViewLoaded else{
      return
    }
    tableView.reloadData()
  }

  static var cellIdentifier:String{
    return "PrescriptionListViewControllerCell"
  }
}

class PrescriptionListViewControllerCell:UITableViewCell{
  @IBOutlet weak var prescriptionDisplayView:PrescriptionDisplayView!


}



extension PrescriptionListViewController: UITableViewDelegate,UITableViewDataSource{
  
  func tableView(_ tableView:UITableView, cellForRowAt path: IndexPath) ->UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: PrescriptionListViewController.cellIdentifier, for:path) as! PrescriptionListViewControllerCell
    cell.prescriptionDisplayView?.dosage = viewModel[path].dosage
    cell.prescriptionDisplayView?.showExtended = true


    //let isSelected = tableView.indexPathsForSelectedRows?.contains(path) ?? false
    cell.textLabel?.textColor = VLColors.primaryText
    cell.textLabel?.highlightedTextColor = VLColors.highlightedPrimaryText
    cell.detailTextLabel?.textColor = VLColors.secondaryText

    //cell.backgroundColor = VLColors.cellBackground
    let selectedBG = UIView()
    selectedBG.backgroundColor  = VLColors.selectedCellBackground
    cell.selectedBackgroundView = selectedBG

    view.tintColor = VLColors.tintColor
    return cell
  }

  func numberOfSections(in: UITableView)->Int{
    return 1
  }

  func tableView(_ tableView:UITableView, numberOfRowsInSection: Int)->Int{
    return viewModel.prescriptions.count
  }

}


func colorizedAttributedString(_ string:String, color:UIColor)->NSAttributedString{
  let attributedString = NSMutableAttributedString(string:string)
  let range = attributedString.mutableString.range(of: string)
  attributedString.addAttribute(.foregroundColor,
                                value: color,
                                range:range )
  return attributedString
}

func emptyStateButtonText(_ string:String)->NSAttributedString{
  return colorizedAttributedString(string, color:.black)
}

func emptyStateAttributedString(_ string:String)->NSAttributedString{
  return colorizedAttributedString(string, color:Asset.Colors.vlEmptyStateText.color)
}

extension PrescriptionListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    return Asset.Empty.emptyRx.image
  }

  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return emptyStateAttributedString("Your Medications in One Place")
  }

  func verticalOffset(forEmptyDataSet scrollView:UIScrollView)->CGFloat{
    return 0
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return emptyStateAttributedString("To enter a Medication, tap the '+' in the upper right corner of the screen.")
  }

  func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
    performSegue(withIdentifier: StoryboardSegue.PrescriptionListViewController.showPrescriptionAddEntry.rawValue, sender: self)
  }
}


