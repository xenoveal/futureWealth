//
//  Category+CoreDataProperties.swift
//  FutureWealth
//
//  Created by Ttaa on 4/28/22.
//
//

import Foundation
import CoreData


extension InstrumentCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var category_id: UUID?
    @NSManaged public var instrument: String?
    @NSManaged public var name: String?
    @NSManaged public var toLog: Set<Log>?
    
    public var logs: [Log]{
        let setOfLogs = toLog
        return setOfLogs!.sorted{
            $0.id > $1.id
        }
    }
 
}

// MARK: Generated accessors for toLog
extension InstrumentCategory {

    @objc(addToLogObject:)
    @NSManaged public func addToToLog(_ value: Log)

    @objc(removeToLogObject:)
    @NSManaged public func removeFromToLog(_ value: Log)

    @objc(addToLog:)
    @NSManaged public func addToToLog(_ values: NSSet)

    @objc(removeToLog:)
    @NSManaged public func removeFromToLog(_ values: NSSet)

}

extension InstrumentCategory  : Identifiable {

}
