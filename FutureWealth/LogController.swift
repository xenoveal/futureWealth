//
//  LogController.swift
//  FutureWealth
//
//  Created by Ttaa on 4/28/22.
//

import CoreData

struct LogController{
    static let shared = LogController()
    
    let container: NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "LogModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        if context.hasChanges{
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func delete(_ object: NSManagedObject, completion: @escaping (Error?) -> () = {_ in}) {
        let context = container.viewContext
        context.delete(object)
        save(completion: completion)
    }
    
}
