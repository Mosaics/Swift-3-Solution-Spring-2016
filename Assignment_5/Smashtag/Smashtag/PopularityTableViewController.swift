//
//  PopularityTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 8/11/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PopularityTableViewController: CoreDataTableViewController /*UITableViewController, NSFetchedResultsControllerDelegate */{

    // MARK: Model
    
    var mention: String? { didSet { updateUI() } }
    var moc: NSManagedObjectContext? { didSet { updateUI() } }
    
 /*   var fetchedResultsController: NSFetchedResultsController<Mension>? {
        didSet {
            do {
                if let frc = fetchedResultsController {
                    frc.delegate = self
                    try frc.performFetch()
                }
                tableView.reloadData()
            } catch let error {
                print("NSFetchedResultsController.performFetch() failed: \(error)")
            }
        }
    }*/
    

    
    fileprivate func updateUI() {
        if let context = moc , mention?.characters.count > 0 {
            let request = NSFetchRequest<Mension>(entityName: "Mension")
            request.predicate = NSPredicate(format: "term.term contains[c] %@ AND count > %@",
                                                                                mention!, "1")
            request.sortDescriptors = [NSSortDescriptor(
                key: "type",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                ), NSSortDescriptor(
                    key: "count",
                    ascending: false
                ),NSSortDescriptor(
                    key: "keyword",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                )]
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "type",
                cacheName: nil
            )
        } else {
            fetchedResultsController = nil
        }
    }
    
    fileprivate struct Storyboard {
        static let CellIdentifier = "PopularMentionsCell"
        static let SegueToMainTweetTableView = "ToMainTweetTableView"
    }
    // MARK: UITableViewDataSource
    
/*    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections , sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections , sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }*/
    
     override func tableView(_ tableView: UITableView,
                             cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier,
                                                            for: indexPath)
        var keyword: String?
        var count: String?
        if let mensionM = fetchedResultsController?.object(at: indexPath) {
            mensionM.managedObjectContext?.performAndWait {  // asynchronous
                keyword =  mensionM.keyword
                count =  mensionM.count.stringValue
            }
            cell.textLabel?.text = keyword
            cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
        }
     return cell
     }
    
    // MARK: View Controller Lifecycle

   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if moc == nil {
            UIManagedDocument.useDocument{ (document) in
                    self.moc =  document.managedObjectContext
            }
        }
    }

    @IBAction fileprivate func toRootViewController(_ sender: UIBarButtonItem) {
        
       _ = navigationController?.popToRootViewController(animated: true)
    }

/*    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }*/
   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == Storyboard.SegueToMainTweetTableView{
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    var text = cell.textLabel?.text {
                    if text.hasPrefix("@") {text += " OR from:" + text} 
                    ttvc.searchText = text
                }
                
            }
        }
    }

}
