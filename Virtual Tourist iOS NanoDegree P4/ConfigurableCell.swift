//
//  ConfigurableCell.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 06/07/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

protocol ConfigurableCell {
	associatedtype DataSource
	func configureForObject(object: DataSource)
}