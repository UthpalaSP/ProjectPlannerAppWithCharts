//
//  TaskPopUpViewController.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/25/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//

protocol TaskPopUpViewControllerDelegate {
    func addTask(taskData: [Any])
    func updateTask(taskData: [Any], index: IndexPath)
}

import UIKit

class TaskPopUpViewController: UIViewController {

    var delegate: TaskPopUpViewControllerDelegate?
    var taskIndex: IndexPath?
    var taskData: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        showAnimate()
        
        if taskData != nil {
            txtName.text = taskData?.name
            txtNotes.text = taskData?.notes
            dueDate.date = (taskData?.dueDate)! as Date
            startDate.date = (taskData?.startDate)! as Date
            setReminder.isOn = (taskData?.remindTask)!
            percentage.text = "\(taskData?.percentage ?? 0)"
        }
    }

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var setReminder: UISwitch!
    @IBOutlet weak var percentage: UITextField!
    
    
    @IBAction func saveTask(_ sender: Any) {
        if (self.delegate) != nil
        {
            let task = [txtName.text!, startDate.date, txtNotes.text!, dueDate.date, setReminder.isOn, percentage.text!] as [Any]
            
            if taskIndex != nil {
                delegate?.updateTask(taskData: task, index: taskIndex!)
            } else {
                delegate?.addTask(taskData: task)
            }
            
            self.dismiss(animated: true, completion: nil)
            
            //Save Alert
            let alertController = UIAlertController(title: "Success", message:
                "Task saved successfully!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.removeAnimate()
    }
    
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
