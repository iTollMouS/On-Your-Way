//
//  VideoMessage.swift
//  On Your Way
//
//  Created by Tariq Almazyad on 10/23/20.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL?){
        self.url = url
        self.placeholderImage = #imageLiteral(resourceName: "photoPlaceholder")
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
