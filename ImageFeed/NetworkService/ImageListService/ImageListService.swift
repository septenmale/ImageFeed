import Foundation
// UI Модель 
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
     
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
    
    init(from photoResult: PhotoResultResponseBody) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt ?? "")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
    
}

final class ImageListService {
    private(set) var photos: [Photo] = []
    // добавляю нотификацию
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // на случай если уже идет загрузка
    private var lastTask: URLSessionTask?
    private var lastLoadedPage: Int?
    //TODO: ДОДЕЛАТЬ
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
//        let baseUrl = "https://api.unsplash.com"
        
        guard let baseUrl = Constants.defaultBaseURL else {
            fatalError("[ImageListService]: [changeLike] - Error: Base URL is nil")
        }
        
        guard let url = URL(string: "\(baseUrl)/photos/\(photoId)/like") else {
            print("[ImageListService]: [changeLike] - Error: Invalid URL")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"

        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImageListService]: [changeLike] - Error: OAuth token is missing.")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Change like request URL: \(url.absoluteString)")
        print("Change like HTTP method: \(request.httpMethod ?? "nil")")
        
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("[ImageListService]: [changeLike] - Error: Failed to get Authorization header.")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("Authorization header: \(authHeader)")
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Если запрос прошёл успешно, обновляем массив
                DispatchQueue.main.async {
                    guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else {
                        print("[ImageListService]: [changeLike] - Error: Photo with ID \(photoId) not found.")
                        return }
                    // Текущий элемент
                    let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked // Инвертируем значение
                    )
                    self.photos[index] = newPhoto
                    
                    completion(.success(()))
                }
                
            case .failure(let error):
                // В случае ошибки передаём её в completion
                DispatchQueue.main.async {
                    print("[ImageListService]: [changeLike]: Error - \(error.localizedDescription).")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        // Проверяем, не идет ли уже запрос
        if let lastTask = self.lastTask {
            lastTask.cancel() // Отменяем текущую задачу, если она есть
        }
        // Определяем номер следующей страницы
        let nextPage = (lastLoadedPage ?? 0) + 1
        // Генерируем запрос для указанной страницы
        guard let request = photosRequest(page: nextPage) else {
            print("[ImageListService]: Error while creating request for page \(nextPage)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResultResponseBody], Error>) in
            // потому что будет взаемодействие с UI
            DispatchQueue.main.async {
                // Сбрасываем текущую задачу
                self?.lastTask = nil
                
                switch result {
                case.success(let response):
                    // Преобразуем массив PhotoResultResponseBody в массив Photo
                    let newPhotos = response.map { photoResult in
                        Photo(from: photoResult)}
                    
                    // Обновляем массив фотографий и последнюю загруженную страницу
                    self?.photos.append(contentsOf: newPhotos)
                    self?.lastLoadedPage = nextPage
                    
                    // Отправляем уведомление об изменении данных
                    NotificationCenter.default.post(name: ImageListService.didChangeNotification, object: nil)
                    
                    // Завершаем с успешным результатом
                    completion(.success(newPhotos))
                    
                case .failure(let error):
                    // Выводим ошибку в лог и возвращаем ее в completion
                    print("[ImageListService]: Error fetching photos: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        // Сохраняем текущую задачу и запускаем ее
        self.lastTask = task
        task.resume()
    }
    
    private func photosRequest(page: Int) -> URLRequest? {
        let baseURL = "https://api.unsplash.com"
        
        guard let url = URL(string: "\(baseURL)/photos?page=\(page)") else {
            print("[ImageListService]: Error while creating url check func photosRequest")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        print("Photos request URL: \(url.absoluteString)")
        print("HTTP method: \(request.httpMethod ?? "nil")")
        guard let authHeader = request.value(forHTTPHeaderField: "Authorization") else {
            print("Error: Failed to get Authorization header.")
            return nil
        }
        print("Authorization header: \(authHeader)")
        
        return request
    }
    
}
