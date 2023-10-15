//
//  ViewController.swift
//  Movie_app
//
//  Created by Junho Yoon on 2023/10/15.
//

import UIKit

class ViewController: UIViewController {
    
    var movieModel: MovieModel?
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var movieTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.delegate = self
        movieTableView.dataSource = self
        searchBar.delegate = self
        
        requestMovieAPI()
    }
    
    func requestMovieAPI() {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        var components = URLComponents(string: "https://itunes.apple.com/search")
        
        let term = URLQueryItem(name: "term", value: "marvel")
        let media = URLQueryItem(name: "media", value: "movie")
        
        components?.queryItems = [term, media]
        
        guard let url = components?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            print((response as! HTTPURLResponse).statusCode)
            
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
        
        task.resume()
        session.finishTasksAndInvalidate()
        
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieModel?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movieData = self.movieModel?.results[indexPath.row]
        
        cell.titleLabel.text = movieData?.trackName
        cell.dateLabel.text = movieData?.shortDescription
        
        let currency = movieData?.currency ?? ""
        
        // description으로 타입 바꿔주
        let price = movieData?.trackPrice.description ?? ""
        
        cell.priceLabel.text = currency + price
        
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          
    }
}

