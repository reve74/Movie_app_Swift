//
//  ViewController.swift
//  Movie_app
//
//  Created by Junho Yoon on 2023/10/15.
//

import UIKit


class ViewController: UIViewController {
    
    var movieModel: MovieModel?
    
    var term = ""
    
    var networkLayer = NetworkLayer()

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var movieTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.delegate = self
        movieTableView.dataSource = self
        searchBar.delegate = self
        
        requestMovieAPI()
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?)-> Void){
        networkLayer.request(type: .justURL(urlString: urlString)) {
            data, response, error in
            if let hasData = data {
                completion(UIImage(data: hasData))
                return
            }
            completion(nil)
        }
        
    }
    
    
//    func loadImage(urlString: String, completion: @escaping (UIImage?)-> Void){
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
//
//        if let hasURL = URL(string: urlString) {
//            var request = URLRequest(url: hasURL)
//            request.httpMethod = "GET"
//
//            session.dataTask(with: request) { data, response, error in
//                print((response as! HTTPURLResponse).statusCode)
//
//                if let hasData = data {
//                    completion(UIImage(data: hasData))
//                    return
//                }
//            }.resume()
//            session.finishTasksAndInvalidate()
//        }
//
//        // 실패했을 경우
//        completion(nil)
//    }
    
    
    // api 호출 함수
    func requestMovieAPI() {
        let term = URLQueryItem(name: "term", value: term)
        let media = URLQueryItem(name: "media", value: "movie")
        
        let querys = [term, media]
        
        networkLayer.request(type: .searchMovie(querys: querys)) {
            data, response, error in
            
            if let hasData = data {
                do {
                    self.movieModel =  try JSONDecoder().decode(MovieModel.self, from: hasData)
                    
                    print(self.movieModel ?? "No Data")
                    
                    // 화면의 UI가 바뀌면 메인스레드에서 실행
                    DispatchQueue.main.async {
                        self.movieTableView.reloadData()
                    }
                    
                    
                }catch {
                    print(error)
                }
            }

        }
    }
    
//    func requestMovieAPI() {
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
//
//        var components = URLComponents(string: "https://itunes.apple.com/search")
//
//        let term = URLQueryItem(name: "term", value: term)
//        let media = URLQueryItem(name: "media", value: "movie")
//
//        components?.queryItems = [term, media]
//
//        guard let url = components?.url else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let task = session.dataTask(with: request) { data, response, error in
//            print((response as! HTTPURLResponse).statusCode)
//
//            if let hasData = data {
//                do {
//                    self.movieModel =  try JSONDecoder().decode(MovieModel.self, from: hasData)
//
//                    print(self.movieModel ?? "No Data")
//
//                    // 화면의 UI가 바뀌면 메인스레드에서 실행
//                    DispatchQueue.main.async {
//                        self.movieTableView.reloadData()
//                    }
//
//
//                }catch {
//                    print(error)
//                }
//            }
//
//
//        }
//
//        task.resume()
//        session.finishTasksAndInvalidate()
//
//
//    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 테이블 뷰 리스트 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieModel?.results.count ?? 0
    }
    
    // 테이블 뷰에서 각각의 테이블 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(identifier: "DetailViewController") as! DetailViewController // 강제 타입캐스팅 필요
        
        // 테이블 뷰에서 pressed 효과 제거
        tableView.deselectRow(at: indexPath, animated: true)
        
        detailViewController.movieResult = self.movieModel?.results[indexPath.row]
        
        // 화면을 꽉 채우는 형식으로 변경
//        detailViewController.modalPresentationStyle = .fullScreen
        
        self.present(detailViewController, animated: true) {
        }
    }
    
    
    // cell의 높이 지정(디자인 가이드 따라 적용)
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 150
//    }
    
    // 컨텐츠의 내용만큼 높이 지정
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movieData = self.movieModel?.results[indexPath.row]
        
        cell.titleLabel.text = movieData?.trackName
        cell.descriptionLabel.text = movieData?.shortDescription
        
        let currency = movieData?.currency ?? ""
        
        // description으로 타입 바꿔주
        let price = movieData?.trackPrice?.description ?? ""
        
        cell.priceLabel.text = currency + price
        
        if let hasURL = movieData?.image {
            self.loadImage(urlString: hasURL) { image in
                DispatchQueue.main.async {
                    cell.movieImageView.image = image
                }
            }
        }
        
        if let dateString = movieData?.releaseDate {
            // 2017-05-05T07:00:00Z -> ISO8601 포맷
            let formatter = ISO8601DateFormatter()
            if let isoDate = formatter.date(from: dateString) {
                let myFormater = DateFormatter()
                myFormater.dateFormat = "yyyy-MM-dd"
                let dateString = myFormater.string(from: isoDate)
                
                cell.dateLabel.text = dateString
            }
        }
        
        // dateFormat 파싱
      
        
        
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let hasText = searchBar.text else {
            return
        }
        term = hasText
        
//        self.term = searchBar.text ?? ""
        requestMovieAPI()
        self.view.endEditing(true)
          
    }
}

