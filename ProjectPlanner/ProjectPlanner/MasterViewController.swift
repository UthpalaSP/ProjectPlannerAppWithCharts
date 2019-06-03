//
//  MasterViewController.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/19/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, ProjectPopUpViewControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var projectViewController: ProjectPopUpViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var projectData: [Any]?
    var project: Project?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem

        //Plus button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        
        //WORKING POPUP
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "projectPopUpId") as! ProjectPopUpViewController
        splitViewController!.addChild(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = splitViewController!.view.frame
        splitViewController!.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: splitViewController!)
        
    }
    
    func addProject(projectData: [Any]){
        let context = self.fetchedResultsController.managedObjectContext

        project = Project(context: context)
        project?.setValue(projectData[0], forKeyPath: "name")
        project?.setValue(projectData[1], forKey: "dueDate")
        project?.setValue(projectData[2], forKey: "notes")
        project?.setValue(projectData[3], forKey: "priority")
        project?.setValue(projectData[4], forKey: "setDateInCalendar")
        project?.setValue(Date(), forKey: "startDate")

        // Save the context.
        do {
            try context.save()
            //set the calendar event if flag is true
            if (project?.setDateInCalendar)! {
                AuthorizeCalendarEvent()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func updateProject(projectData: [Any], index: IndexPath) {
        let context = self.fetchedResultsController.managedObjectContext
        let project = fetchedResultsController.object(at: index)
        //let data = projectData as! [Project]
        
        //project = Project(context: context)
        project.setValue(projectData[0], forKeyPath: "name")
        project.setValue(projectData[1], forKey: "dueDate")
        project.setValue(projectData[2], forKey: "notes")
        project.setValue(projectData[3], forKey: "priority")
        project.setValue(projectData[4], forKey: "setDateInCalendar")
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func AuthorizeCalendarEvent(){
        //Calendar DB
        let eventStore = EKEventStore()
        //authorization status
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            addCalendarEvent(store: eventStore)
        case .denied:
            print("Access denied")
        case .notDetermined:
            // User prompted to grant access
            eventStore.requestAccess(to: .event, completion:
                {[weak self] (granted: Bool, error: Error?) -> Void in
                    if granted {
                        self!.addCalendarEvent(store: eventStore)
                    } else {
                        print("Access denied")
                    }
            })
        default:
            print("Case default")
        }
    }
    
    func addCalendarEvent(store: EKEventStore) {
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            if calendar.title == "projectplanner" {
                
                let startDate = project?.dueDate
                // 2 hours
                let endDate = startDate?.addingTimeInterval(2 * 60 * 60)
                
                let event = EKEvent(eventStore: store)
                event.calendar = calendar
                
                event.title = project?.name
                event.startDate = startDate as Date?
                event.endDate = endDate as Date?
                
                do {
                    try store.save(event, span: .thisEvent)
                    print("Calendar event is set")
                }
                catch {
                    print("Error saving event in calendar")             }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete , edit])
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let project = fetchedResultsController.object(at: indexPath)
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            //trigger the popover
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "projectPopUpId") as! ProjectPopUpViewController
            self.splitViewController!.addChild(popOverVC)
            popOverVC.delegate = self
            popOverVC.projectData = project
            popOverVC.projectIndex = indexPath
            popOverVC.view.frame = self.splitViewController!.view.frame
            self.splitViewController!.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self.splitViewController!)
            
            //project.name = project.name! + " xoxoxoxox name edited :D "
            completion(true)
            
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            completion(true)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
        }
        action.backgroundColor = UIColor.red
        return action
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let context = fetchedResultsController.managedObjectContext
//            context.delete(fetchedResultsController.object(at: indexPath))
//                
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Project) {
        cell.textLabel!.text = event.name ?? "Test Project Name"
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Project> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Project>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Project)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Project)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

