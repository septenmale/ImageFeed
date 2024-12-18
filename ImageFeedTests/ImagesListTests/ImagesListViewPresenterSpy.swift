@testable import ImageFeed
import Foundation

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    // MARK: - Свойства
    var view: ImagesListViewControllerProtocol?
    var imageListService: ImageListServiceProtocol
    // MARK: - Флаги вызовов методов
    var viewDidLoadCalled = false
    var loadFirstPageCalled = false
    var isLastRowCalled = false
    var changeLikeCalled = false
    var updateTableViewCalled = false
    // MARK: - Переданные данные
    var passedIndexPath: IndexPath?
    var passedPhoto: Photo?
    var passedIsLiked: Bool?
    // MARK: - Инициализатор
    init(imageListService: ImageListServiceProtocol) {
        self.imageListService = imageListService
    }
    // MARK: - Методы протокола
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func loadFirstPage() {
        loadFirstPageCalled = true
    }
    
    func isLastRow(indexPath: IndexPath) -> Bool {
        isLastRowCalled = true
        passedIndexPath = indexPath
        return false 
    }
    
    func changeLike(for photo: Photo, isLiked: Bool) {
        changeLikeCalled = true
        passedPhoto = photo
        passedIsLiked = isLiked
    }
    
    func updateTableView() {
        updateTableViewCalled = true
    }
}
