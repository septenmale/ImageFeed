@testable import ImageFeed
import XCTest
import Foundation

final class ImageListTests: XCTestCase {
    // MARK: - View Tests
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let mockService = MockImageListService()
        let presenterSpy = ImagesListViewPresenterSpy(imageListService: mockService)
        viewController.configure(presenterSpy)
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Presenter's viewDidLoad() should be called.")
    }
    
    func testViewControllerCallsInsertRows() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let indexPaths = [IndexPath(row: 0, section: 0)]
        // when
        viewController.insertRows(at: indexPaths)
        // then
        XCTAssertTrue(viewController.insertRowsCalled)
        XCTAssertEqual(viewController.passedIndexPaths, indexPaths)
    }
    
    func testViewControllerCallsShowError() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let errorMessage = "Test error"
        // when
        viewController.showError(message: errorMessage)
        // then
        XCTAssertTrue(viewController.showErrorCalled, "ViewController did not call showError as expected")
        XCTAssertEqual(viewController.passedErrorMessage, errorMessage, "Passed error message is incorrect")
    }
    
    func testViewControllerCallsUpdatePhotos() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        // when
        viewController.updatePhotos(photos)
        // then
        XCTAssertTrue(viewController.updatePhotosCalled)
        XCTAssertEqual(viewController.passedPhotos, photos)
    }
    
    func testViewControllerCallsUpdateCell() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let index = 0
        let isLiked = true
        // when
        viewController.updateCell(at: index, isLiked: isLiked)
        // then
        XCTAssertTrue(viewController.updateCellCalled)
        XCTAssertEqual(viewController.passedIndex, index)
        XCTAssertEqual(viewController.passedIsLiked, isLiked)
    }
    // MARK: - Presenter Tests
    func testPresenterCallsLoadFirstPage() {
        // given
        let mockService = MockImageListService()
        let presenter = ImagesListViewPresenter(imageListService: mockService)
        let viewController = ImagesListViewControllerSpy()
        presenter.view = viewController
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
    }
    
    func testPresenterCallsUpdateTableView() {
        // given
        let mockService = MockImageListService()
        mockService.photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        let presenter = ImagesListViewPresenter(imageListService: mockService)
        let viewController = ImagesListViewControllerSpy()
        presenter.view = viewController
        // when
        presenter.updateTableView()
        // then
        XCTAssertTrue(viewController.insertRowsCalled)
    }
    
    func testPresenterCallsChangeLike() {
        // given
        let mockService = MockImageListService()
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        mockService.photos = [photo]
        let presenter = ImagesListViewPresenter(imageListService: mockService)
        let viewController = ImagesListViewControllerSpy()
        presenter.view = viewController
        // when
        presenter.changeLike(for: photo, isLiked: true)
        // then
        XCTAssertTrue(mockService.changeLikeCalled)
    }
    
    func testPresenterIdentifiesLastRow() {
        // given
        let mockService = MockImageListService()
        mockService.photos = [
            Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        ]
        let presenter = ImagesListViewPresenter(imageListService: mockService)
        // when
        let isLastRow = presenter.isLastRow(indexPath: IndexPath(row: 0, section: 0))
        // then
        XCTAssertTrue(isLastRow)
    }
    
}
