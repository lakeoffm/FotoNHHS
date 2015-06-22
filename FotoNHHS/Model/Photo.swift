//
//  Photo.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 22.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import Foundation

class Photo {
    private let photoID: Int
    private let size: Sizes
    private let possibleSizes:[Sizes]
    private let imageData:NSData
    
    
    init(id:Int, size:Sizes, possibleSizes:[Sizes], data:NSData){
        self.photoID = id
        self.size = size
        self.possibleSizes = possibleSizes
        self.imageData = data
    }
    
    enum Sizes:Int {
        case Square=75
        case LargeSquare=150
        case Thumbnail=100
        case Small=240
        case Small320=320
        case Medium=500
        case Medium640=640
        case Medium800=800
        case Large=1024
        case Large1600=1600
        case Large2048=2048
        case Original
    }
    
}