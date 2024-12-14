import UIKit
import ProgressHUD
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    var presenter: ImagesListViewPresenterProtocol?
    
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService()
    
    @IBOutlet private var tableView: UITableView!
    // pres
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        // pres
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
        
        loadFirstPage()
        
    }
    
    deinit {
        guard let imageListServiceObserver else { return }
        NotificationCenter.default.removeObserver(imageListServiceObserver)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            if let url = URL(string: photo.largeImageURL) {
                viewController.imageURL = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
        
    }
    // pres
    private func loadFirstPage() {
        imageListService.fetchPhotosNextPage { _ in }
    }
    // pres
    private func isLastRow(indexPath: IndexPath) -> Bool {
        indexPath.row == photos.count - 1
    }
    
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
             self.presenter = presenter
             presenter.view = self
         }
    
}

extension ImagesListViewController: UITableViewDelegate {
    /// - Description: Called when a user taps a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    /// - Description: Sets the height for individual rows.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    /// - Description: This method is called just before a cell is displayed on the screen
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath
    ){
        guard isLastRow(indexPath: indexPath) else { return }
        imageListService.fetchPhotosNextPage { _ in }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    /// - Description: Returns the number of rows  in a specific section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    /// - Description: Configures and returns the cell for a specific row at the given index path. This is the most important method because it controls what each row looks like.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        let photo = photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)
        configCell(for: imageListCell, url: url, with: indexPath)
        
        return imageListCell
    }
    
}
// pres
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHud.show()
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            UIBlockingProgressHud.dismiss()
            switch result {
            case .success:
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imageListService.photos
                // Изменим индикацию лайка картинки
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                print("[ImagesListViewController]: [func imageListCellDidTapLike] Error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Не поставить лайк",
                                              preferredStyle: .alert
                )
                
                let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true)
                
            }
        }
    }
}

extension ImagesListViewController {
    /// - Description: A custom function commonly used in table view implementations to configure the content and appearance of a cell.
    private func configCell(for cell: ImagesListCell, url: URL?, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url,
                                   placeholder: UIImage(named: "Stub") ?? UIImage()
        ) { result in }
        
        let date = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.dateLabel.text = date
        
        let likeImage = photo.isLiked ? UIImage(named: "liked") : UIImage(named: "disliked")
        cell.likeButton.setImage(likeImage, for: .normal)
        
    }
    /// - Description: Updates the table view to display newly loaded photos.
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        
        let newCount = imageListService.photos.count
        
        photos = imageListService.photos
        
        if oldCount != newCount {
            var indexPaths: [IndexPath] = []
            for i in oldCount..<newCount {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
}


