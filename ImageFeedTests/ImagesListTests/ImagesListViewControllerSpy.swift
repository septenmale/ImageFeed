@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    // MARK: - Свойства
    var presenter: ImagesListViewPresenterProtocol?
    var photos: [Photo] = []
    // MARK: - Флаги вызовов методов
    var showErrorCalled = false
    var updatePhotosCalled = false
    var updateCellCalled = false
    var insertRowsCalled = false
    // MARK: - Переданные данные
    var passedErrorMessage: String?
    var passedPhotos: [Photo]?
    var passedIndex: Int?
    var passedIsLiked: Bool?
    var passedIndexPaths: [IndexPath]?
    // MARK: - Методы протокола
    func showError(message: String) {
        showErrorCalled = true
        passedErrorMessage = message
    }
    
    func updatePhotos(_ photos: [Photo]) {
        updatePhotosCalled = true
        passedPhotos = photos
    }
    
    func updateCell(at index: Int, isLiked: Bool) {
        updateCellCalled = true
        passedIndex = index
        passedIsLiked = isLiked
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        passedIndexPaths = indexPaths
    }
}
