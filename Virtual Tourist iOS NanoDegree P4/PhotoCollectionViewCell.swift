//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var loadingWheel: UIActivityIndicatorView!
}

extension PhotoCollectionViewCell: ConfigurableCell {
	func configureCell(photoObject: Photo) {
		imageView.image = photoObject.photoImage
	}
}