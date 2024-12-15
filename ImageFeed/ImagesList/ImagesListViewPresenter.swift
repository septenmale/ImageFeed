import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imageListService: ImageListService { get set }
    
    func viewDidLoad()
    func loadFirstPage()
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var imageListService: ImageListService
    private var imageListServiceObserver: NSObjectProtocol?
    
    init(imageListService: ImageListService) {
        self.imageListService = imageListService
    }
    
    func viewDidLoad() {
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                // TODO: move to presenter
                self.view?.updateTableViewAnimated()
            }
        
        loadFirstPage()
        
    }
    
     func loadFirstPage() {
        imageListService.fetchPhotosNextPage { _ in }
    }
}
