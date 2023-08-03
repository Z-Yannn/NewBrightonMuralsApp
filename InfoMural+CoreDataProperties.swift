//
//  InfoMural+CoreDataProperties.swift
//  New Brighton Murals
//
//  Created by Zhijie Yan on 09/12/2022.
//
//

import Foundation
import CoreData


extension InfoMural {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InfoMural> {
        return NSFetchRequest<InfoMural>(entityName: "InfoMural")
    }

    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var info: String?
    @NSManaged public var lat: String?
    @NSManaged public var lon: String?
    @NSManaged public var id: String?

}

extension InfoMural : Identifiable {

}
