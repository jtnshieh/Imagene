//
//  ImageSearchViewController.swift
//  ImageSearch
//
//  Created by Justin Shieh on 4/3/20.
//  Copyright © 2020 Justin Shieh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
//import SkeletonView

class ImageSearchViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var imageArray = [Image]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }

    // MARK: - TableView Datasource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ImageCell
        let image = imageArray[indexPath.row]
        if let link = image.link, let url = URL(string: link), let imageView = cell.imageContainer {
            let placeholder = UIImage(systemName: "tray.and.arrow.down")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .black
            imageView.af.setImage(withURL: url, placeholderImage: placeholder)
        }
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    
    func fetchImages(_ query: String) {
        self.imageArray = []
        let request = AF.request("https://api.imgur.com/3/gallery/search/?q=\(query)", method: .get, headers: HTTPHeaders(["Authorization":"Client-ID 5431ad12ec038d5"]))
        request.validate().responseDecodable(of: ImageData.self) { (response) in
          guard let imageData = response.value else { return }
            for datum in imageData.data {
                if let images = datum.images {
                    for image in images {
                        if let link = image.link, (link.hasSuffix(".jpg") || link.hasSuffix(".png")) {
                            self.imageArray.append(image)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
//            self.view.hideSkeleton()
        }
    }
}

extension ImageSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToImage", sender: self)
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ImageViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.image = imageArray[indexPath.row]
        }
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        view.showGradientSkeleton()
        fetchImages(searchBar.text!)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            imageArray = []
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//extension ImageSearchViewController: SkeletonTableViewDataSource {
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//        return "ReusableCell"
//    }
//}
