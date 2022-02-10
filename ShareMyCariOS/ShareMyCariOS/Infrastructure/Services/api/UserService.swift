//
//  UserService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

public let apiURL: String = "https://serverbuijsen.nl/api"


func apiGetUser() async throws -> User? {
    let data = try await apiCall(url: "\(apiURL)/user", body: nil, method: "GET", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", showEventsInCalendar: true, sendNotifications: true, profilePicture: "", cars: [])), authorized: true)
    
    return data?.result
}

func apiUpdateUser(user : User) async throws -> User? {
    let json : [String: Any] = ["name":user.name, "phoneNumber": user.phoneNumber, "sendNotifications": user.sendNotifications, "showEventsInCalendar": user.showEventsInCalendar]
    
    let data = try await apiCall(url: "\(apiURL)/user/\(user.id)", body: json, method: "PUT", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", showEventsInCalendar: true, sendNotifications: true, profilePicture: "", cars: [])), authorized: true)
    
    return data?.result
}

func apiUpdatePf(user : User) async throws -> User? {
    let json : [String: Any] = ["profilePicture": user.profilePicture]
    
    let data = try await apiCall(url: "\(apiURL)/user/\(user.id)/pf", body: json, method: "PUT", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", showEventsInCalendar: true, sendNotifications: true, profilePicture: "", cars: [])), authorized: true)
    
    return data?.result
}


