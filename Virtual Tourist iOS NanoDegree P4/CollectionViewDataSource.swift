//
//  CollectionViewDataSource.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 05/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit

class CollectionViewDataSource<Delegate: DataSourceDelegate, Data: DataProvider, Cell: UICollectionViewCell where Delegate.Object == Data.Object, Cell: ConfigurableCell, Cell.DataSource == Data.Object>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
	
	required init(collectionView: UICollectionView, dataProvider: Data, delegate: Delegate) {
		self.collectionView = collectionView
		self.dataProvider = dataProvider
		self.delegate = delegate
		super.init()
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.reloadData()
		
	}
	
	func processUpdates(updates: [DataProviderUpdate<Data.Object>]?) {
		guard let updates = updates else { return collectionView.reloadData() }
		collectionView.performBatchUpdates({
			for update in updates {
				switch update {
				case .Insert(let indexPath):
					print("inserted")
					self.collectionView.insertItemsAtIndexPaths([indexPath])
				case .Update(let indexPath, let object):
					guard let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? Cell else { fatalError("wrong cell type") }
					cell.configureCell(object)
				case .Move(let indexPath, let newIndexPath):
					self.collectionView.deleteItemsAtIndexPaths([indexPath])
					self.collectionView.insertItemsAtIndexPaths([newIndexPath])
				case .Delete(let indexPath):
					self.collectionView.deleteItemsAtIndexPaths([indexPath])
				}
			}
			}, completion: nil)
	}
	
	// MARK: Private
	
	private let collectionView: UICollectionView
	private let dataProvider: Data
	private weak var delegate: Delegate!
	
	// MARK: CollectionViewDataSource
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataProvider.numberOfItemsInSection(section)
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let object = dataProvider.objectAtIndexPath(indexPath)
		let identifier = delegate.cellIdentifierForObject(object)
		guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? Cell else { fatalError("Unexpected cell type at \(indexPath)") }
		cell.configureCell(object)
		return cell
	}
	
}
