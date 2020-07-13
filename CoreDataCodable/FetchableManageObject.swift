//
//  FetchableManageObject.swift
//  CoreDataCodable
//
//  Created by Peter Ringset on 19/03/2019.
//  Copyright © 2019 Ringset. All rights reserved.
//

import CoreData
import Foundation

public protocol FetchableManagedObject {
    
    associatedtype FetchableCodingKeys: CodingKey
    associatedtype Identifier: Decodable & CVarArg
    static var identifierKeys: [FetchableCodingKeys] { get }
    static var identifierNames: [String] { get }
    
}

extension FetchableManagedObject where Self: NSManagedObject {
    
    static func fetch(from decoder: Decoder) throws -> Self? {
        let context = try decoder.managedObjectContext()
        let container = try decoder.container(keyedBy: FetchableCodingKeys.self)
        
        var predicate = ""
        var identifiers = [Identifier]()
        for i in 0..<identifierKeys.count {
            let identifier = try container.decode(Identifier.self, forKey: identifierKeys[i])
            identifiers.append(identifier)
            if i > 0 {
                predicate += " && "
            }
            
            predicate += "\(identifierNames[i]) == %d"
        }
        let request = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        request.predicate = NSPredicate(format: predicate, argumentArray: identifiers)
        return try context.fetch(request).first
    }
    
}
