//
//  DetailViewController.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/19/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Charts

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, TaskPopUpViewControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var taskData: [Any]?
    var project: Project?
    var taskList: [Task] = []
    
    var remainingDataEntry = PieChartDataEntry(value: 0)
    var completedDataEntry = PieChartDataEntry(value: 0)
    
    var remainingTime = PieChartDataEntry(value: 0)
    var completedTime = PieChartDataEntry(value: 0)
    
    var numberOfDataEntries = [PieChartDataEntry]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtNotes: UILabel!
    @IBOutlet weak var progressPieChart: PieChartView!
    @IBOutlet weak var duePieChart: PieChartView!
    
    @IBAction func addTask(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "taskPopUpId") as! TaskPopUpViewController
        splitViewController!.addChild(popOverVC)
        popOverVC.delegate = self
        popOverVC.view.frame = splitViewController!.view.frame
        splitViewController!.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: splitViewController!)
    }
    
    var detailItem: Project? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        project = detailItem
        if let detail = detailItem {
            var priority = ""
            switch detail.priority{
            case 0:
                priority = "Low"
            case 1:
                priority = "Medium"
            case 2:
                priority = "High"
            default:
                priority = "Low"
            }
            
            if let label = txtName {

                label.text = " \(detail.name!)  Priority - \(priority)"
            }
            if let label = txtNotes {
                label.text = " \(detail.notes!) "
            }
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
//        tableView.bounces = true
//        tableView.isScrollEnabled = true
//        tableView.showsVerticalScrollIndicator = true
//        
//        self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.view.frame.size.height - self.tableView.frame.origin.y)

        //Progress Bar chart for project
        var noOfItems = 0
        var completedPercentage = 0
        if project != nil {
            for case let item as Task in (project?.tasks?.allObjects)! {
                noOfItems += 1
                completedPercentage += Int(item.percentage)
            }
            if noOfItems != 0 {
                remainingDataEntry.value = Double(100 - (completedPercentage/noOfItems))
                completedDataEntry.value = Double(completedPercentage/noOfItems)
            }
        } else {
            remainingDataEntry.value = 0
            completedDataEntry.value = 0
        }
        remainingDataEntry.label = "To do"
        completedDataEntry.label = "Completed"
        numberOfDataEntries = [remainingDataEntry, completedDataEntry]
        var chartDataSet = PieChartDataSet(values: numberOfDataEntries, label: nil)
        var colors = [UIColor.blue, UIColor.purple]
        chartDataSet.colors = colors
        
        let chartData = PieChartData(dataSet: chartDataSet)
        progressPieChart.data = chartData
        
        //Date bar chart for project
        if project != nil {
            //var givenTime = project?.dueDate?.compare(project?.startDate as! Date)
            let calendar = Calendar.current
            
            let date1 = calendar.startOfDay(for: project?.startDate! as! Date)
            let date2 = calendar.startOfDay(for: project?.dueDate! as! Date)
            let givenDays = calendar.dateComponents([.day], from: date1, to: date2)
            
            let remainingDays = calendar.dateComponents([.day], from: Date(), to: date2)
            if givenDays.day != 0 {
                remainingTime.value = Double((100 / givenDays.day!) * remainingDays.day!)
                completedTime.value = 100 - remainingTime.value
            }
        } else {
            remainingTime.value = 0
            completedTime.value = 0
        }
        remainingTime.label = "Time left"
        completedTime.label = "Time spent"
        numberOfDataEntries = [remainingTime, completedTime]
        chartDataSet = PieChartDataSet(values: numberOfDataEntries, label: nil)
        colors = [UIColor.black, UIColor.brown]
        chartDataSet.colors = colors
        
        let chartData2 = PieChartData(dataSet: chartDataSet)
        duePieChart.data = chartData2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AuthorizeNotification() //Send notifications
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        managedObjectContext =
            appDelegate.persistentContainer.viewContext
    }

    func addTask(taskData: [Any]) {
        
        if project == nil {
            //Error Alert
            let alertController = UIAlertController(title: "Error", message:
                "No project is selected.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let context = self.fetchedResultsController.managedObjectContext
            
            let task = Task(context: context)
            task.setValue(taskData[0], forKeyPath: "name")
            task.setValue(taskData[1], forKey: "startDate")
            task.setValue(taskData[2], forKey: "notes")
            task.setValue(taskData[3], forKey: "dueDate")
            task.setValue(taskData[4], forKey: "remindTask")
            task.setValue(Int(taskData[5] as! String), forKey: "percentage")
            task.owner = project
            project?.addToTasks(task)
            // Save the context.
            //tableView.reloadData()
            do {
                try context.save()
                if (task.remindTask) {}
                tableView.reloadData()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            //tableView.reloadData()
        }
    }
    
    func updateTask(taskData: [Any], index: IndexPath) {
       
        if project == nil {
            //Error Alert
            let alertController = UIAlertController(title: "Error", message:
                "No project is selected.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let context = self.fetchedResultsController.managedObjectContext
            
            let task = project?.tasks?.allObjects[index.row] as! Task //fetchedResultsController.object(at: index)
            task.setValue(taskData[0], forKeyPath: "name")
            task.setValue(taskData[1], forKey: "startDate")
            task.setValue(taskData[2], forKey: "notes")
            task.setValue(taskData[3], forKey: "dueDate")
            task.setValue(taskData[4], forKey: "remindTask")
            task.setValue(Int(taskData[5] as! String), forKey: "percentage")
            task.owner = project
            //project?.removeFromTasks(task)
            //project?.addToTasks(task)
            //tableView.reloadData()
            do {
                try context.save()
                tableView.reloadData()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            tableView.reloadData()
        }
        
    }
    
    func AuthorizeNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Access granted")
                self.ScheduleNotification()
            } else {
                print("Access denied for notifications")
            }
        }
    }
    
    func ScheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        //Find a way to loop through tasks
        if fetchedResultsController.fetchedObjects != nil {
            for task in fetchedResultsController.fetchedObjects! {
                if task.remindTask == true && (task.dueDate! as Date) < Date() && task.percentage < 100 {
                    //if  {
                        let content = UNMutableNotificationContent()
                        content.title = "Reminder about \(task.name ?? "Reminder about task")"
                        content.body = "Due date of the task is passed."
                        content.categoryIdentifier = "alarm"
                        content.userInfo = ["customData": "\(task.name ?? "task")"]//identify notification uniq
                        content.sound = UNNotificationSound.default

                        var dateComponents = DateComponents()
                        dateComponents.hour = 10
                        dateComponents.minute = 30
                        //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        //after 5 seconds; not waiting til 10.30
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        center.add(request)
                    //}
                }
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if project != nil {
//            let sectionInfo = fetchedResultsController.sections![section]
//            return sectionInfo.numberOfObjects
            return project?.tasks?.count ?? 0
        } else {
            return 0
        }
        //return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "taskCell")
        let cell =
            self.tableView.dequeueReusableCell(withIdentifier:
                "taskCell", for: indexPath)
                as! TaskViewCell
        //let task = fetchedResultsController.object(at: indexPath)
        let task = project?.tasks?.allObjects[indexPath.row]
//        let context = self.fetchedResultsController.managedObjectContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
//        let predicate = NSPredicate(format: "name CONTAINS[c] %@", "1234 task")
//        fetchRequest.predicate = predicate
//        do {
//            let records = try context.fetch(fetchRequest) as! [Task]
//
//            for record in records {
//                print(record.value(forKey: "name") ?? "no name")
//            }
//
//            let task = records[indexPath.row]
//            configureCell(cell, withEvent: task)
//
//        } catch {
//            print(error)
//        }
        configureCell(cell, withEvent: task as! Task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                let edit = editAction(at: indexPath)
                let delete = deleteAction(at: indexPath)
                return UISwipeActionsConfiguration(actions: [delete , edit])
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        let task = self.project?.tasks?.allObjects[indexPath.row]// fetchedResultsController.object(at: indexPath)
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            //trigger the popover
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "taskPopUpId") as! TaskPopUpViewController
            self.splitViewController!.addChild(popOverVC)
            popOverVC.delegate = self
            popOverVC.taskData = (task as! Task)
            popOverVC.taskIndex = indexPath
            popOverVC.view.frame = self.splitViewController!.view.frame
            self.splitViewController!.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self.splitViewController!)
            
            completion(true)
            
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let task = self.project?.tasks?.allObjects[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let context = self.fetchedResultsController.managedObjectContext
            //self.project?.removeFromTasks(task as! Task)
            context.delete(self.fetchedResultsController.object(at: indexPath))
            completion(true)
            
            do {
                try context.save()
                //self.tableView.reloadData()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    // MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let appDelegate =
            UIApplication.shared.delegate as? AppDelegate
        managedObjectContext =
            appDelegate!.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        //Project predicate
        if project != nil {
            //fetchRequest.predicate = NSPredicate(format: "owner.name == %@", (project?.name)!)
            //fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", "h")
        }
    
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
//         Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        
        aFetchedResultsController.delegate = self //(self.tableView as! NSFetchedResultsControllerDelegate)
        _fetchedResultsController = aFetchedResultsController
        
        do {
            if project != nil {
                try _fetchedResultsController?.performFetch()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    
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
            configureCell(tableView.cellForRow(at: indexPath!) as! TaskViewCell, withEvent: anObject as! Task)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!) as! TaskViewCell, withEvent: anObject as! Task)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func configureCell(_ cell: TaskViewCell, withEvent event: Task) {
        cell.lblName!.text = event.name ?? "Task Name"
        cell.lblPercentage.text = "\(event.percentage)%"
        
        let remainingDataEntry = PieChartDataEntry(value: 0)
        let completedDataEntry = PieChartDataEntry(value: 0)
        var numberOfDataEntries = [PieChartDataEntry]()
        
        remainingDataEntry.label = "To do"
        remainingDataEntry.value = Double(event.percentage)
        completedDataEntry.label = "Completed"
        completedDataEntry.value = Double(100 - event.percentage)
        numberOfDataEntries = [remainingDataEntry, completedDataEntry]
        let chartDataSet = PieChartDataSet(values: numberOfDataEntries, label: nil)
        let colors = [UIColor.lightGray, UIColor.darkGray]
        chartDataSet.colors = colors
        
        let chartData = PieChartData(dataSet: chartDataSet)
        cell.progressPieChart.data = chartData
        
        //cell.progressView.setProgress(Float(event.percentage/100), animated: true)
        //cell.progressView.progress =  0.0//Float(event.percentage/100)
     
            //cell.progressView.progress = Float(currentTime)

        
    }

    
}

