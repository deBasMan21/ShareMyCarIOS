//
//  Car.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

struct Car : Identifiable, Decodable, Hashable {
    var id : Int
    var name : String
    var plate : String
    var image : String
    var isOwner : Bool
}
