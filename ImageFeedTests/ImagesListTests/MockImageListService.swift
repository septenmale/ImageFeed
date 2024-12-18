@testable import ImageFeed
import Foundation

final class MockImageListService: ImageListServiceProtocol {
    // MARK: - Свойства
    var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "MockImageListServiceDidChange")
    // Флаги для отслеживания вызовов методов
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    // Результаты, которые возвращают методы (для тестов можно настраивать)
    var fetchPhotosResult: Result<[Photo], Error> = .success([])
    var changeLikeResult: Result<Void, Error> = .success(())
    // MARK: - Методы протокола
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
        completion(fetchPhotosResult)
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            let updatedPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked 
            )
            photos[index] = updatedPhoto
        }
        completion(changeLikeResult)
    }
}
