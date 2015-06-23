//
//  Album.swift
//  FotoNHHS
//
//  Created by Max Ozerov on 22.06.15.
//  Copyright © 2015 Max Ozerov. All rights reserved.
//

import Foundation

class Album {
    
    private let albumID:String
    private let albumName:String
    private let numberOfPhotos:Int
    private let dateCreated:String
    private let coverPhoto:Photo
    
    
    init(id:String, name:String, photos:Int, dateCreated:String, cover:Photo){
        self.albumID = id
        self.albumName = name
        self.numberOfPhotos = photos
        self.dateCreated = dateCreated
        self.coverPhoto = cover
    }
    
    func getAlbumId()->String{
        return self.albumID
    }
    
    func getAlbumName()-> String{
        return self.albumName
    }
    
    func getNumberOfPhotos()->Int{
        return self.numberOfPhotos
    }
    
    func getDateCreated()->String{
        return self.dateCreated
    }
    
    func getCoverPhoto()->Photo{
        return self.coverPhoto
    }
    
}