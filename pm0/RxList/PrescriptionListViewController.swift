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
    LocalStorage.SavePrescriptions(prescriptions)
  }

  mutating func receivedPrescription(_ rx:Prescription){
    if let editingIndex = editingIndex{
      prescriptions[editingIndex] = rx
    }else{
      prescriptions.append(rx)
    }
    LocalStorage.SavePrescriptions(prescriptions)
  }
}

class PrescriptionListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var viewModel = PrescriptionListViewModel()


  @IBAction func unwindToPrescriptionListCancel(segue:UIStoryboardSegue){}
  @IBAction func unwindToPrescriptionList(segue:UIStoryboardSegue){

    guard segue.identifier == "doneEditingPrescription" else{
      return
    }
    guard let rx = (segue.source as? PrescriptionEntryViewController)?.prescription else{
        return
    }

    viewModel.receivedPrescription(rx)
    tableView.reloadData()
  }

  private var alertController :UIAlertController?
  func deleteRxTableRowAction(_ action:UITableViewRowAction, indexPath:IndexPath){
    // delete item at indexPath
    let alert = UIAlertController(title: "Delete Rx?",
                                  message: "Are you sure you want to delete \( "foo")?",
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
    tableView.tableFooterView?.backgroundColor = VLColors.background
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = VLColors.background
    tableView.separatorColor = UIColor.lightGray
    tableView.sectionHeaderHeight = 40
    tableView.emptyDataSetSource = self;
    tableView.emptyDataSetDelegate = self;

    viewModel.prescriptions = LocalStorage.LoadPrescriptions()

    //sendFax(toNumber:"+18558237571", documentPaths: ["TestPage1.pdf"]){ isSuccess,msg in print(msg) }
  
  }
  


  static var cellIdentifier:String{
    return "PrescriptionListViewControllerCell"
  }
}


extension PrescriptionListViewController: UITableViewDelegate,UITableViewDataSource{

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 5
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.textColor = VLColors.primaryText
    header.textLabel?.frame = header.frame
  }


  func tableView(_ tableView:UITableView, cellForRowAt path: IndexPath) ->UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: PrescriptionListViewController.cellIdentifier, for:path)
    cell.textLabel?.text = viewModel[path].title
    cell.detailTextLabel?.text = viewModel[path].subTitle

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

extension PrescriptionListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    return UIImage(named:"RxEmptyState")
  }

  

  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string: "No prescriptions (yet)")
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    return NSAttributedString(string:"Tap the + button below to add one.")
  }
}


