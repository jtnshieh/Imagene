//
//  ImageViewController.swift
//  ImageSearch
//
//  Created by Justin Shieh on 4/3/20.
//  Copyright © 2020 Justin Shieh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ImageViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var imageURL: URL?
    var image: Image? {
        didSet {
            if let link = image?.link {
                imageURL = URL(string: link)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adding a small time delay for a nicer transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let safeImageURL = self.imageURL {
                self.imageView.af.setImage(withURL: safeImageURL)
            }
        }
    }
    
    
    
}
