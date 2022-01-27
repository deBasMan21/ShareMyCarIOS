//
//  Ride.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

struct Ride : Decodable, Identifiable, Hashable {
    var id : Int
    var name : String
    var beginDateTime : String
    var endDateTime : String
    var reservationDateTime : String
    var lastChangeDateTime : String
    var destination : Location?
    var user : User?
    var car : Car?
}

