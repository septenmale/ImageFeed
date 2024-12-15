import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imageListService: ImageListService { get set }
    
    func viewDidLoad()
    func loadFirstPage()
    func isLastRow(indexPath: IndexPath) -> Bool
    func changeLike(for photo: Photo, isLiked: Bool)
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
    
    func isLastRow(indexPath: IndexPath) -> Bool {
        let photosCount = imageListService.photos.count
        return indexPath.row == photosCount - 1
    }
    
    func changeLike(for photo: Photo, isLiked: Bool) {
        UIBlockingProgressHud.show()
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHud.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success:
                let updatedPhotos = imageListService.photos
                self.view?.updatePhotos(updatedPhotos)
                if let index = updatedPhotos.firstIndex(where: { $0.id == photo.id }) {
                    let isLiked = updatedPhotos[index].isLiked
                    self.view?.updateCell(at: index, isLiked: isLiked)
                }
                
            case .failure(let error):
                self.view?.showError(message: "Не удалось поставить лайк: \(error.localizedDescription)")
            }
        }
    }
    
}
