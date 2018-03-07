//
//  PrescriptionListViewController
//  pm0
//
//  Created by Michael Langford on 12/29/17.
//  Copyright © 2017 Rowdy Labs. All rights reserved.
//


import DZNEmptyDataSet
import UIKit


extension Prescription{
  var title:String{
    return dosage?.shortName  ?? ""
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
}

class PrescriptionListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var viewModel = PrescriptionListViewModel()

  @IBAction func unwindToPrescriptionList(segue:UIStoryboardSegue){

    guard segue.identifier == "doneEditingPrescription" else{
      return
    }
    guard let rx = (segue.source as? PrescriptionEntryViewController)?.prescription else{
        return
    }

    viewModel.prescriptions.append(rx)
    global_allDrugs = viewModel.prescriptions.flatMap{$0.dosage}
    tableView.reloadData()
  }

  


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

    
  }

  static var cellIdentifier:String{
    return "PrescriptionListViewControllerCell"
  }
}


extension PrescriptionListViewController: UITableViewDelegate,UITableViewDataSource{

//  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//    return 40
//  }
//
//  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//    guard let header = view as? UITableViewHeaderFooterView else { return }
//    header.textLabel?.textColor = VLColors.primaryText
//    header.textLabel?.font = UIFont.boldSystemFont(ofSize: 40)
//    header.textLabel?.frame = header.frame
//    header.textLabel?.text = "Prescriptions"
//  }

  func tableView(_ tableView:UITableView, cellForRowAt path: IndexPath) ->UITableViewCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: PrescriptionListViewController.cellIdentifier, for:path)
    cell.textLabel?.text = viewModel[path].title
    cell.detailTextLabel?.text = viewModel[path].subTitle

    //let isSelected = tableView.indexPathsForSelectedRows?.contains(path) ?? false
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
    cell.textLabel?.textColor = VLColors.primaryText
    cell.textLabel?.highlightedTextColor = VLColors.highlightedPrimaryText
    cell.detailTextLabel?.textColor = VLColors.secondaryText

    cell.backgroundColor = VLColors.cellBackground
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

  func tableView(_ tableView:UITableView, titleForHeaderInSection: Int)->String?{
    return "Prescriptions"
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


