//
//  User.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

struct User : Decodable, Identifiable, Hashable {
    var id : Int
    var name : String
    var email : String
    var phoneNumber : String
    var showEventsInCalendar : Bool
    var sendNotifications : Bool
    var profilePicture : String
    var cars : [Car]?
}
