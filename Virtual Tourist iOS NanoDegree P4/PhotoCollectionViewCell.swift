//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var loadingWheel: UIActivityIndicatorView!
	@IBOutlet weak var imageView: UIImageView!
}

extension PhotoCollectionViewCell: ConfigurableCell {
	func configureCell(photoObject: Photo) {
		if let photo = photoObject.photoImage {
			loadingWheel.stopAnimating()
			imageView.image = UIImage(data: photo)
		} else {
			loadingWheel.startAnimating()
		}
	}
}

