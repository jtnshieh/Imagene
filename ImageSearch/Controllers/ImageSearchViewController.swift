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

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var imageArray = [Image]()
    var searchArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndRecentSearches))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
        searchTableView.layer.borderWidth = 2.0;
        searchTableView.backgroundColor = #colorLiteral(red: 0.5582914948, green: 0.8606375456, blue: 0.8125551343, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchTableView.isHidden = true
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }

    // MARK: - TableView Datasource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if tableView == self.tableView {
            count = imageArray.count
        } else if tableView == self.searchTableView {
            count = searchArray.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! ImageCell
            let image = imageArray[indexPath.row]
            if let link = image.link, let url = URL(string: link), let imageView = cell.imageContainer {
                let placeholder = UIImage(systemName: "tray.and.arrow.down")?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = .black
                imageView.af.setImage(withURL: url, placeholderImage: placeholder)
            }
            return cell
        } else if tableView == self.searchTableView {
            let searchCell = searchTableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            searchCell.textLabel?.text = searchArray[indexPath.row]
            return searchCell
        }
        return UITableViewCell()
    }
    
    // MARK: - Data Manipulation Methods
    
    func fetchImages(_ query: String) {
        let request = AF.request("https://api.imgur.com/3/gallery/search/?q=\(query)", method: .get, headers: HTTPHeaders(["Authorization":"Client-ID 5431ad12ec038d5"]))
        request.validate().responseDecodable(of: ImageData.self) { (response) in
            guard let imageData = response.value else { return }
            self.imageArray = []
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
        if tableView == self.tableView {
            performSegue(withIdentifier: "goToImage", sender: self)
        } else if tableView == self.searchTableView {
            let query = searchArray[indexPath.row]
            searchBar.text = query
            fetchImages(query)
            searchArray = searchArray.filter({ $0 != query})
            searchArray.insert(query, at: 0)
            dismissKeyboardAndRecentSearches()
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ImageViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.image = imageArray[indexPath.row]
        }
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    func addSearchResult() {
        if searchBar.text!.count > 0 {
            if let idx = searchArray.firstIndex(of: searchBar.text!) {
                searchArray.remove(at: idx)
            }
            searchArray.insert(searchBar.text!, at: 0)
        }
    }
    
    @objc func dismissKeyboardAndRecentSearches() {
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
            self.searchTableView.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        addSearchResult()
        dismissKeyboardAndRecentSearches()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        addSearchResult()
        dismissKeyboardAndRecentSearches()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.searchTableView.isHidden = false
            self.searchTableView.reloadData()
            self.searchTableView.frame.size = self.searchTableView.contentSize;
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            imageArray = []
            tableView.reloadData()
            dismissKeyboardAndRecentSearches()
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
        }
        
    }
    
    @objc func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }

        fetchImages(searchBar.text!)
//        view.showGradientSkeleton()
    }
    
}

//extension ImageSearchViewController: SkeletonTableViewDataSource {
//    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
//        return "ReusableCell"
//    }
//}
