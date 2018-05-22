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

  /// Builds an appropriate line of the schedule
  ///
  /// - Parameters:
  ///   - maxTimeWidth: used to send in the max width of the time string in characters in the collection this is a part of
  ///   - foregroundColor: text color
  ///   - backgroundColor: this stripe's bg color
  /// - Returns: NSAttributed string rendering one single stripe
  func floridDescription(maxTimeWidth:Int = 8, foregroundColor:UIColor = Asset.Colors.vlSecondaryTextColor.color,
                         backgroundColor:UIColor = Asset.Colors.vlCellBackgroundCommon.color) -> NSAttributedString{

    let preferredFont = UIFont.preferredFont(forTextStyle: .footnote)
    let labelAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:foregroundColor,
      .backgroundColor:backgroundColor,
      .strokeWidth:-2.0,
      .font: UIFont(name: "CourierNewPSMT", size: preferredFont.pointSize) as Any
    ]

    let itemAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:foregroundColor,
      .backgroundColor:backgroundColor,
      .strokeWidth:-1.0,
      .font: preferredFont as Any
    ]

    var paddedTimeString = timeString
    while paddedTimeString.count < maxTimeWidth{
      paddedTimeString = " \(paddedTimeString)"
    }

    let displayCorrectedTimeString = "   \(paddedTimeString)"
    let itemString = "     \(name)".padding(toLength: 200, withPad: " ", startingAt: 0)
    return NSAttributedString(string:displayCorrectedTimeString, attributes:labelAttributes) +
           NSAttributedString(string:itemString, attributes:itemAttributes)

  }
}

/// Used to make alternating light/dark backgrounds
struct ZebraStriperIterator: IteratorProtocol {
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
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    return  [
      .foregroundColor:Asset.Colors.vlSecondaryTextColor.color,
      .obliqueness:0.2,
      .paragraphStyle: paragraphStyle
    ]
  }
  var attributedBody:NSAttributedString{

    return NSAttributedString(string:bodyString,
                              attributes:doseAttributes)
  }


  
  var extendedAttributedBody:NSAttributedString{
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = .byWordWrapping
    let labelAttributes: [NSAttributedStringKey: Any] = [
      .foregroundColor:Asset.Colors.vlSecondaryTextColor.color,
      .strokeWidth:-2.9,
      .paragraphStyle: paragraphStyle
    ]

    let interlineParagraphStyle = NSMutableParagraphStyle()
    interlineParagraphStyle.lineBreakMode = .byWordWrapping
    interlineParagraphStyle.lineSpacing = 10
    let interlineAttributes: [NSAttributedStringKey: Any] = [
      .paragraphStyle: interlineParagraphStyle,
      .foregroundColor:Asset.Colors.vlSecondaryTextColor.color,
      .strokeWidth:-2.9,
    ]


    let newline = NSAttributedString(string:"\n",attributes:interlineAttributes)
    let take = NSAttributedString(string:"Take: ",attributes:labelAttributes) + attributedBody
    let scheduleTitle = NSMutableAttributedString(string:"Schedule: ",attributes:interlineAttributes)
    return take + newline + scheduleTitle
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

    if let helpVC = segue.destination as? HelpViewController {
      helpVC.helpText =
        """
          This screen shows what medications you currently plan to take.

          Add a medication by tapping the '+' button.

          Delete by swiping left and tapping delete. Deleting a medication does not affect the log: your  history will remain unchanged.

          Edit by swiping left and tapping edit. Editing *may* reorder the today screen. Ensure today's record is correct after editing a prescription, and ensure you do not take a medication an extra time due to changing your plan.

          The scheduled times of day are shown on this screen for each medicaiton. You can change this by editing the medication.

          You can change the times of day shown by the different timeslots (breakfast, etc) by editing the medication as well.

        """.renderMarkdownAsAttributedString
      helpVC.title = "\(tabBarItem.title.spaceAfterOrEmpty) Help"
      return
    }
    switch segue.identifier ?? "" {
    case StoryboardSegue.PrescriptionListViewController.showHelp.rawValue:
      if let helpVC = segue.destination as? HelpViewController {
        helpVC.helpText =
          """
          This screen shows what medications you currently plan to take.

          Add a medication by tapping the '+' button.

          Delete by swiping left and tapping delete. Deleting a medication does not affect the log: your  history will remain unchanged.

          Edit by swiping left and tapping edit. Editing *may* reorder the "My Day" screen: Ensure today's record is correct after editing a prescription.

          The scheduled times of day are shown on this screen for each medicaiton. You can change this by editing the medication.

          You can change the times of day shown by the different timeslots (breakfast, etc) by editing the medication as well.

        """.renderMarkdownAsAttributedString
        helpVC.title = "\(tabBarItem.title.spaceAfterOrEmpty) Help"
        return
      }
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


  @objc func refreshData(_ sender:Any){
    viewModel.prescriptions = LocalStorage.PrescriptionStore.load()
    tableView.reloadData()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.tableView?.refreshControl?.endRefreshing()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView() //gets rid of excess lines
    tableView.dataSource = self
    tableView.delegate = self
    tableView.emptyDataSetSource = self;
    tableView.emptyDataSetDelegate = self;
    tableView.tableHeaderView = UIView()
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
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
    cell.textLabel?.textColor = Asset.Colors.vlTextColor.color
    cell.textLabel?.highlightedTextColor = Asset.Colors.vlTextColor.color
    cell.detailTextLabel?.textColor = Asset.Colors.vlSecondaryTextColor.color

    //cell.backgroundColor = VLColors.cellBackground
    let selectedBG = UIView()
    selectedBG.backgroundColor  = Asset.Colors.vlCellBackgroundCommon.color
    cell.selectedBackgroundView = selectedBG

    view.tintColor = Asset.Colors.vlWarmTintColor.color
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
    return UIDevice.current.model == "iPad" ?
    Asset.Empty.emptyRx.image.scaled(by: 0.2) : 
      Asset.Empty.emptyRx.image
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


