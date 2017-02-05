//
//  ViewController.swift
//  CurrentFlicks
//
//  Created by Kevin M Call on 2/3/17.
//  Copyright © 2017 Kevin M Call. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var posterViewer: UICollectionView!
    @IBOutlet weak var controlFlowCell: UICollectionViewFlowLayout!
    var movies : [NSDictionary]?
    
    override func viewDidLoad() {
        //Sets up the View
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        self.posterViewer.insertSubview(refreshControl, at: 0)
        
            
        posterViewer.dataSource = self
        posterViewer.delegate = self
        
        //Adjusts spacing and flow of the cells
        controlFlowCell.scrollDirection = .vertical
        controlFlowCell.minimumLineSpacing = 0
        controlFlowCell.minimumInteritemSpacing = 0
        controlFlowCell.sectionInset = UIEdgeInsetsMake(0,0,0,0)
        
        //Performs API call
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        MBProgressHUD.showAdded(to: self.view,animated: true)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(dataDictionary)
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.posterViewer.reloadData()
                }
            }
            MBProgressHUD.hide(for:self.view, animated: true)
        }
        task.resume()
    }

    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
         
            self.posterViewer.reloadData()
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        }
        else{
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coloredCell", for: indexPath) as! coloredCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        
        let constant = "https://image.tmdb.org/t/p/w342"
        let imgURL = movie["poster_path"] as! String
        let urlPath = NSURL(string: constant+imgURL)
        
        //cell.titleLabel.text = title
        //cell.overviewLabel.text = overview
        cell.posterImageView.setImageWith(urlPath! as URL)
        //cell.bounds.size.width = cell.posterImageView.bounds.size.width
        //cell.bounds.size.height = cell.posterImageView.bounds.size.height
        

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let totalwidth = posterViewer.bounds.size.width
        let numberOfCellsPerRow = 2
        let dimensions = CGFloat(Int(totalwidth)/numberOfCellsPerRow)
        return CGSize(width: dimensions, height: dimensions)
    }
    
}

