//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private static let modelName = "FeedStore"
	private static let model = NSManagedObjectModel(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	struct ModelNotFound: Error {
		let modelName: String
	}

	public init(storeURL: URL) throws {
		guard let model = CoreDataFeedStore.model else {
			throw ModelNotFound(modelName: CoreDataFeedStore.modelName)
		}

		container = try NSPersistentContainer.load(
			name: CoreDataFeedStore.modelName,
			model: model,
			url: storeURL
		)
		context = container.newBackgroundContext()
	}

	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
			request.returnsObjectsAsFaults = false
			do {
				if let cache = try context.fetch(request).first {
					let localFeed = cache.feed.compactMap { object -> LocalFeedImage? in
						if let feedImage = (object as? ManagedFeedImage) {
							return LocalFeedImage(id: feedImage.id, description: feedImage.imageDescription, location: feedImage.location, url: feedImage.url)
						} else {
							return nil
						}
					}
					let timestamp = cache.timestamp
					completion(.found(feed: localFeed, timestamp: timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			let cache = ManagedCache(context: context)
			cache.timestamp = timestamp
			cache.feed = NSOrderedSet(array: feed.map({ localFeedImage in
				let feedImage = ManagedFeedImage(context: context)
				feedImage.id = localFeedImage.id
				feedImage.imageDescription = localFeedImage.description
				feedImage.location = localFeedImage.location
				feedImage.url = localFeedImage.url

				return feedImage
			}))

			try? context.save()
			completion(nil)
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError("Must be implemented")
	}
}
