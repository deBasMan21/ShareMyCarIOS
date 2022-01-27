//
//  Location.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

struct Location : Decodable, Identifiable, Hashable {
    var id : Int
    var address : String
    var zipCode : String
    var city : String
    var name : String
}
