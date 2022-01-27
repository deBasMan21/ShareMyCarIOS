//
//  CarService.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

func apiCreateCar(name: String, plate: String, image: String) async throws -> Car? {
    let json : [String: Any] = ["name": name, "plate": plate, "image": image]
    
    let data = try await authorizedApiCall(url: "\(apiURL)/car", body: json, method: "POST", obj: CarWrapper(result: Car(id: 1, name: "", plate: "", image: "", isOwner: false)))
    
    return data?.result
}

func apiAddSharedCar(id: String, shareCode : String) async throws -> User? {
    let json : [String: Any] = ["shareCode": shareCode]
    
    let data = try await authorizedApiCall(url: "\(apiURL)/user/4/car/\(id)", body: json, method: "PUT", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", cars: [])))
    
    return data?.result
}

func apiShareCar(id : Int) async throws -> String? {
    let data = try await authorizedApiCall(url: "\(apiURL)/car/\(id)/share", body: nil, method: "PUT", obj: ShareCarWrapper(result: ""))
    
    return data?.result
}

func apiEndShareCar(id : Int) async throws -> Car? {
    let data : CarWrapper? = try await authorizedApiCall(url: "\(apiURL)/car/\(id)/endShare", body: nil, method: "PUT", obj: CarWrapper(result: Car(id: 1, name: "", plate: "", image: "", isOwner: false)))
    
    return data?.result
}

func apiDeleteCar(id : Int) async throws -> Car? {
    let data : CarWrapper? = try await authorizedApiCall(url: "\(apiURL)/car/\(id)", body: nil, method: "DELETE", obj: CarWrapper(result: Car(id: 1, name: "", plate: "", image: "", isOwner: false)))
    
    return data?.result
}

func apiUpdateCar(id: Int, name : String, plate : String, image : String) async throws -> Car? {
    let json : [String: Any] = ["name": name, "plate": plate, "image": image]
    
    let data : CarWrapper? = try await authorizedApiCall(url: "\(apiURL)/car/\(id)", body: json, method: "PUT", obj: CarWrapper(result: Car(id: 1, name: "", plate: "", image: "", isOwner: false)))
    
    return data?.result
}

func apiRemoveCarFromUser(carId: Int) async throws -> User? {
    let data = try await authorizedApiCall(url: "\(apiURL)/user/4/car/\(carId)", body: nil, method: "DELETE", obj: UserWrapper(result: User(id: 1, name: "", email: "", phoneNumber: "", cars: [])))
    
    return data?.result
}

func apiGetRidesForCar(carId : Int) async throws -> [Ride]? {
    let data = try await authorizedApiCall(url: "\(apiURL)/car/\(carId)/rides", body: nil, method: "GET", obj: RidesWrapper(result: []))
    
    return data?.result
}

func apiGetCar(carId : Int) async throws -> Car? {
    let data : CarWrapper? = try await authorizedApiCall(url: "\(apiURL)/car/\(carId)", body: nil, method: "GET", obj: CarWrapper(result: Car(id: 1, name: "", plate: "", image: "", isOwner: false)))
    
    return data?.result
}
