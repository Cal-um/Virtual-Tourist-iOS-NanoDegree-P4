//
//  ManagedObjectContextSettable.swift
//  Virtual Tourist iOS NanoDegree P4
//
//  Created by Calum Harris on 17/06/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import CoreData

protocol ManagedObjectContextSettable: class {
	var downloadSyncAndMOC: DownloadSync! { get set }
}
