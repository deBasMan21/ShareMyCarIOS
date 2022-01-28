//
//  AuthenticationsWrappers.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import Foundation

struct AuthenticationWrapper : Decodable {
    var result : AuthenticationBody
}

struct AuthenticationBody : Decodable {
    var token : String
    var expireDate : String
    var user : User?
}
