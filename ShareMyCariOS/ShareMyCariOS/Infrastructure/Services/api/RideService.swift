//
//  RideService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

func apiGetRide(rideId: Int) async throws -> Ride? {
    let data = try await apiCall(url: "\(apiURL)/ride/\(rideId)", body: nil, method: "GET", obj: RideWrapper(result: Ride(id: 1, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "", destination: nil, user: nil, car: nil)), authorized: true)
    
    return data?.result
}

func apiCreateRide(name: String, beginDateTime : Date, endDateTime: Date, locationId : Int, carId: Int) async throws -> Ride?{
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    
    let json : [String: Any] = ["name": name, "beginDateTime" : formatter.string(from: beginDateTime), "endDateTime": formatter.string(from: endDateTime), "locationId": locationId, "carId": carId]
    
    let data = try await apiCall(url: "\(apiURL)/ride", body: json, method: "POST", obj: RideWrapper(result: Ride(id: 1, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "", destination: nil, user: nil, car: nil)), authorized: true)
    
    return data?.result
}

func apiDeleteRide(rideId : Int) async throws -> Ride? {
    let data = try await apiCall(url: "\(apiURL)/ride/\(rideId)", body: nil, method: "DELETE", obj: RideWrapper(result: Ride(id: 1, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "", destination: nil, user: nil, car: nil)), authorized: true)
    
    return data?.result
}

func apiUpdateRide(name : String, beginDateTime : Date, endDateTime : Date, locationId : Int, rideId : Int) async throws -> Ride? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    
    let json : [String: Any] = ["name": name, "beginDateTime" : formatter.string(from: beginDateTime), "endDateTime": formatter.string(from: endDateTime), "locationId": locationId]
    
    let data = try await apiCall(url: "\(apiURL)/ride/\(rideId)", body: json, method: "PUT", obj: RideWrapper(result: Ride(id: 1, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "", destination: nil, user: nil, car: nil)), authorized: true)
    
    return data?.result
}
