import Foundation
import CoreData

class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

extension ManagedCache {
	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		request.returnsObjectsAsFaults = false

		return try context.fetch(request).first
	}
}
