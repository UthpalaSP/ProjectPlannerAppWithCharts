//
//  ProjectPopUpViewController.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/23/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//
protocol ProjectPopUpViewControllerDelegate {
    func addProject(projectData: [Any])
    func updateProject(projectData: [Any], index: IndexPath)
}

import UIKit

class ProjectPopUpViewController: UIViewController {
    
    var projectData: Project?
    var projectIndex: IndexPath?
    var delegate: ProjectPopUpViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.showAnimate()
        
        if projectData != nil {
            txtName.text = projectData?.name
            txtNotes.text = projectData?.notes
            dateDue.date = (projectData?.dueDate)! as Date
            setDateInCalendar.isOn = (projectData?.setDateInCalendar)!
            sltPriority.selectedSegmentIndex = Int((projectData?.priority)!)
        }
    }

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var sltPriority: UISegmentedControl!
    @IBOutlet weak var dateDue: UIDatePicker!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var setDateInCalendar: UISwitch!
    
    @IBAction func saveProject(_ sender: Any) {
        
        //NEW PROJECT
        if (self.delegate) != nil
        {
            let project = [txtName.text!, dateDue.date, txtNotes.text!, sltPriority.selectedSegmentIndex, setDateInCalendar.isOn] as [Any]
            
            if projectIndex != nil {
                delegate?.updateProject(projectData: project, index: projectIndex!)
            } else {
                delegate?.addProject(projectData: project)
            }
     
            self.dismiss(animated: true, completion: nil)
            
            //Save Alert
            let alertController = UIAlertController(title: "Success", message:
                "Project saved successfully!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.removeAnimate()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "saveProject" {
//
//            let newProject = Project()
//            newProject.setValue(txtName.text, forKeyPath: "name")
//            newProject.setValue(dateDue.date, forKey: "dueDate")
//            newProject.setValue(txtNotes.text, forKey: "notes")
//            newProject.setValue(sltPriority.selectedSegmentIndex, forKey: "priority")
//            newProject.setValue(setDateInCalendar.isOn, forKey: "setDateInCalendar")
//
//            projectData = newProject
//
//            let controller = segue.destination as! MasterViewController
//            controller.projectData = projectData
//        }
//
//    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
}
