//
//  CollectionViewDataSource.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class CollectionViewDataSource<Delegate: DataSourceDelegate, Data: Dataprovider, Cell: UICollectionViewCell where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object>: NSObject, UICollectionViewDataSource {
	
	required init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate) {
		self.collectionView = collectionView
		self.dataProvider = dataProvider
		self.delegate = delegate
		super.init()
		collectionView.dataSource = self
		collectionView.reloadData()
	}
	
	
	// MARK: Private
	
	private let collectionView: UICollectionView
	private let dataProvider: Data
	private weak var delegate = Delegate!
	
	
}
