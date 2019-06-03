//
//  Project+CoreDataProperties.swift
//  ProjectPlanner
//
//  Created by Uthpala Pathirana on 5/26/19.
//  Copyright © 2019 Uthpala Pathirana. All rights reserved.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var dueDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var priority: Int16
    @NSManaged public var setDateInCalendar: Bool
    @NSManaged public var startDate: NSDate?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension Project {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
