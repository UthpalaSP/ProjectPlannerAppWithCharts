//
//  Task+CoreDataProperties.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/26/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var dueDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var percentage: Int16
    @NSManaged public var remindTask: Bool
    @NSManaged public var startDate: NSDate?
    @NSManaged public var owner: Project?

}
