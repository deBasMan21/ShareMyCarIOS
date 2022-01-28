//
//  LocationService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import Foundation

func apiGetLocations() async throws -> [Location]? {
    let data = try await apiCall(url: "\(apiURL)/location", body: nil, method: "GET", obj: LocationsWrapper(result : []), authorized: true)
    
    return data?.result
}

func apiCreateLocation(location : Location) async throws -> Location? {
    let json : [String : Any] = ["name": location.name, "address": location.address, "zipcode": location.zipCode, "city": location.city]
    
    let data = try await apiCall(url: "\(apiURL)/location", body: json, method: "POST", obj: LocationWrapper(result: Location(id: 1, address: "", zipCode: "", city: "", name: "")), authorized: true)
    
    return data?.result
}

func apiDeleteLocation(locationId : Int) async throws -> Location? {
    let data = try await apiCall(url: "\(apiURL)/location/\(locationId)", body: nil, method: "DELETE", obj: LocationWrapper(result: Location(id: 0, address: "", zipCode: "", city: "", name: "")), authorized: true)
    
    return data?.result
}
