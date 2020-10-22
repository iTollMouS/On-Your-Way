//
//  PhotoMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/21/20.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(path: String){
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(systemName: "photo.on.rectangle.angled")!
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
