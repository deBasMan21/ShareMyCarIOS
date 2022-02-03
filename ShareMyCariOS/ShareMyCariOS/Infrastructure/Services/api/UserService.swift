//
//  UserService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

public let apiURL: String = "https://sharemycarapi.azurewebsites.net/api"


func apiGetUser() async throws -> User? {
    let data = try await apiCall(url: "\(apiURL)/user", body: nil, method: "GET", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", cars: [])), authorized: true)
    
    return data?.result
}

func apiUpdateUser(user : User) async throws -> User? {
    let json : [String: Any] = ["name":user.name, "email":user.email, "phoneNumber": user.phoneNumber]
    
    let data = try await apiCall(url: "\(apiURL)/user/\(user.id)", body: json, method: "PUT", obj: UserWrapper(result: User(id: 0, name: "", email: "", phoneNumber: "", cars: [])), authorized: true)
    
    return data?.result
}
