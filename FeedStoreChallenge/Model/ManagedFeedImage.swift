import Foundation
import CoreData

final class ManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}

	static func images(from feed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: feed.map { localFeedImage in
			let feedImage = ManagedFeedImage(context: context)
			feedImage.id = localFeedImage.id
			feedImage.imageDescription = localFeedImage.description
			feedImage.location = localFeedImage.location
			feedImage.url = localFeedImage.url

			return feedImage
		})
	}
}
