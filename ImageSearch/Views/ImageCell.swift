//
//  ImageCell.swift
//  ImageSearch
//
//  Created by Justin Shieh on 4/3/20.
//  Copyright © 2020 Justin Shieh. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var imageContainer: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        imageContainer.image = nil
    }
    
}
