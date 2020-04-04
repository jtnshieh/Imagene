//
//  File.swift
//  ImageSearch
//
//  Created by Justin Shieh on 4/3/20.
//  Copyright © 2020 Justin Shieh. All rights reserved.

struct ImageData: Decodable {
    let data: [Datum]
}

struct Datum: Decodable {
    let images: [Image]?
}

struct Image: Decodable {
    let link: String?
}
