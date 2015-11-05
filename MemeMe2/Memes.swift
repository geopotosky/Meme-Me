//
//  Memes.swift
//  MemeMe2
//
//  Created by George Potosky on 5/5/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

@objc(Memes)


class Memes : NSManagedObject {
    
//    struct Memes {
//        var textTop : String
//        var textBottom : String
//        var originalImage : UIImage
//        var memedImage : UIImage
//    }
    
    @NSManaged var textTop: String?
    @NSManaged var textBottom: String?
    @NSManaged var originalImage: NSData?
    @NSManaged var memedImage: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(textTop: String?, textBottom: String?, originalImage: NSData?, memedImage: NSData?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Memes", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.textTop = textTop
        self.textBottom = textBottom
        self.originalImage = originalImage
        self.memedImage = memedImage

    }

}
