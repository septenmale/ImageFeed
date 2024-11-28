import UIKit
import ProgressHUD
import Kingfisher

final class ImagesListViewController: UIViewController {
    var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService()
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        
        loadFirstPage()
        
    }
    
    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
    
    private func loadFirstPage() {
        imageListService.fetchPhotosNextPage { _ in }
    }
    
    private func isLastRow(indexPath: IndexPath) -> Bool {
        indexPath.row == photos.count - 1
    }
    
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = "No date available"
        }
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "liked") : UIImage(named: "disliked")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath
    ){
        
        if isLastRow(indexPath: indexPath) {
            imageListService.fetchPhotosNextPage { _ in }
        }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        
        if let url = URL(string: photo.thumbImageURL) {
            
            imageListCell.configureImage(with: url, for: indexPath, in: tableView)
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
}

extension ImagesListViewController {
    ///update Table View  if new photos loaded
    func updateTableViewAnimated() {
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
            }  completion: { _ in }
        }
    }
}

