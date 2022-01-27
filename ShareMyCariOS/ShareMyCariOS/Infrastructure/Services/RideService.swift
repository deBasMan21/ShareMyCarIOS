//
//  RideService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

func apiGetRide(rideId: Int) async throws -> Ride? {
    let data = try await authorizedApiCall(url: "\(apiURL)/ride/\(rideId)", body: nil, method: "GET", obj: RideWrapper(result: Ride(id: 1, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "", destination: nil, user: nil, car: nil)))
    
    return data?.result
}
