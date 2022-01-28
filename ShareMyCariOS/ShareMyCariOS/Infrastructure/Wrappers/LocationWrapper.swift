//
//  LocationWrapper.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import Foundation

struct LocationsWrapper : Decodable {
    var result : [Location]
}

struct LocationWrapper : Decodable {
    var result : Location
}
