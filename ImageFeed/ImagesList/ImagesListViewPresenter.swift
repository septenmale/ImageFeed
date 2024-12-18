import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var imageListService: ImageListServiceProtocol { get set }
    
    func viewDidLoad()
    func loadFirstPage()
    func isLastRow(indexPath: IndexPath) -> Bool
    func changeLike(for photo: Photo, isLiked: Bool)
    func updateTableView()
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    var imageListService: ImageListServiceProtocol
    private var imageListServiceObserver: NSObjectProtocol?
    
    init(imageListService: ImageListServiceProtocol) {
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
            
                self.updateTableView()
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
    
    func updateTableView() {
        let oldCount = view?.photos.count ?? 0
        let newCount = imageListService.photos.count
        
        guard oldCount != newCount else { return }
        
        view?.updatePhotos(imageListService.photos)
        
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        view?.insertRows(at: indexPaths)
    }
    
}
