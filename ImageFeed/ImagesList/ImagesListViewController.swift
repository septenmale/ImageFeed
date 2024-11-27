import UIKit
import ProgressHUD
import Kingfisher

final class ImagesListViewController: UIViewController {
    var photos: [Photo] = [] // Массив, который будет хранить данные для таблицы
    private var imageListServiceObserver: NSObjectProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService()
    
    @IBOutlet private var tableView: UITableView!
    
//    private let photosName = Array(0..<20).map{ "\($0)" }
    
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
            
//            let image = UIImage(named: photosName[indexPath.row])
            
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
    
}

extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let url = URL(string: photo.thumbImageURL) {
                    // Загрузка изображения с помощью Kingfisher
                    cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                }
        
//        guard let image = UIImage(named: photosName[indexPath.row]) else {
//            return
//        }
//        cell.cellImage.image = image
        
//        cell.dateLabel.text = dateFormatter.string(from: Date())
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
            // новое
//        guard let url = URL(string: photo.thumbImageURL) else {
//            return 0
//        }
        // новое
//        let imageView = UIImageView()
//        let image = imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        
//        guard let image = UIImage(named: photosName[indexPath.row]) else {
//            return 0
//        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
//        let imageWidth = image.size.width
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
//        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
//        return cellHeight
        return cellHeight
    }
    // перенес сюда с отдельного расширения
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath
    ) {
        // поменять в будущем на isLastRow
        if indexPath.row + 1 == photos.count {
                    imageListService.fetchPhotosNextPage { _ in }
                }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count // исправлено
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentiifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        // Получаем текущую фотографию из массива photos
        let photo = photos[indexPath.row]
        
        // Формируем URL для загрузки изображения
        if let url = URL(string: photo.thumbImageURL) {
            // Настроим ячейку с помощью URL изображения
            imageListCell.configure(with: url)
        }
        
        // Дополнительные настройки ячейки
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
}

    extension ImagesListViewController {
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

