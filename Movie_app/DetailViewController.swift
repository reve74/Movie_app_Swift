//
//  DetailViewController.swift
//  Movie_app
//
//  Created by Junho Yoon on 2023/10/16.
//

import UIKit
import AVKit

class DetailViewController: UIViewController {
    
    var movieResult: MovieResult? {
        didSet {
            
        }
    }
    
    var player: AVPlayer?
    
    @IBOutlet weak var movieContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        }
    }
    
    // viewDidload 내에서 title, description 값 할당
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = movieResult?.trackName
        descriptionLabel.text = movieResult?.longDescription
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let hasURL = movieResult?.previewUrl {
            makePlayerAndPlay(urlString: hasURL)
        }
    }
    
    func makePlayerAndPlay(urlString: String) {
        
        if let hasUrl = URL(string: urlString) {
            self.player = AVPlayer(url: hasUrl)
            // 플레이어틀 넣는 틀
            let playerlayer = AVPlayerLayer(player: player)
            
            movieContainer.layer.addSublayer(playerlayer)
            playerlayer.frame = movieContainer.bounds
            
            self.player?.play()
        }
    }
    
    @IBAction func play(_ sender: Any) {
        self.player?.play()
    }
    @IBAction func stop(_ sender: Any) {
        self.player?.pause()
    }
        
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
