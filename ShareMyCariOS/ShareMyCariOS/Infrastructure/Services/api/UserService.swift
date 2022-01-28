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
