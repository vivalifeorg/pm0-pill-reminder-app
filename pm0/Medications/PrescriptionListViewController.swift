//
//  PrescriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//


import DZNEmptyDataSet
import UIKit


import UIKit
extension Dosage{
  var attributedString:NSAttributedString{
    let str =
      "**\(name)**<br/>\(quantity) × \(unitDescription ?? form ?? "dose")".renderMarkdownAsAttributedString
    return str
  }
  var attributedTitle:NSAttributedString{
    return NSAttributedString(string:"\(name)")
  }

  var attributedBody:NSAttributedString{
    return NSAttributedString(string:"\(quantity) × \(unitDescription ?? form ?? "dose")")
  }
}

extension Prescription{

  var title:String{
    return dosage?.description ?? "Drug"
  }
  var attributedTitle:NSAttributedString{
    return dosage!.attributedString
  }
  var subTitle:String{
    return conditionPrescribedFor.map{"for \($0)"} ?? "for <Condition>"
  }
}

struct PrescriptionListViewModel{
  var prescriptions:[Prescription] = []

  subscript(indexPath:IndexPath)->Prescription{
    return prescriptions[indexPath.row]
  }

  var editingIndex:Int?

  mutating func deleteItemAt(index:Int){
    editingIndex = nil
    prescriptions.remove(at:index)
    LocalStorage.PrescriptionStore.save(prescriptions)
  }

  mutating func receivedPrescription(_ rx:Prescription){
    if let editingIndex = editingIndex{
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

  func showEditRxViewController(){
    self.performSegue(withIdentifier: "showPrescriptionAddEntry", sender: self)
  }

  func editRxAction(_ action:UITableViewRowAction, indexPath:IndexPath){
    viewModel.editingIndex = indexPath.row
    showEditRxViewController()
  }
  

  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    return [
      UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteRxTableRowAction),
      UITableViewRowAction(style: .normal, title: "Edit", handler:editRxAction)
    ]
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier ?? "" {
    case "showPrescriptionAddEntry":
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
    performSegue(withIdentifier: "addPrescriptionSegue", sender: self)
  }
}


