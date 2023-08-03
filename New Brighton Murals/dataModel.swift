//
//  dataModel.swift
//  New Brighton Murals
//
//  Created by Zhijie Yan on 05/12/2022.
//

import Foundation
struct image: Decodable {
    let id: String
    let filename: String?
    
}

struct mural: Decodable {
    let id: String
    let title: String
    let artist: String?
    let info: String?
    let thumbnail: String?
    let lat: String
    let lon: String
    let enabled: String
    let lastModified: String
    let images: [image]
}

struct brightonMurals: Decodable{
    let newbrighton_murals: [mural]
}
