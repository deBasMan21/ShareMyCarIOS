//
//  GenericApiCalls.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

func authorizedApiCall<T : Decodable>(url : String, body : [String : Any]?, method : String, obj: T) async throws -> T? {
    let token = "INSERT TOKEN HERE"
    
    let url = URL(string: url)!
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    if body != nil {
        let jsonData = try? JSONSerialization.data(withJSONObject: body!)
        request.httpBody = jsonData
    }
    
    let(data, _) = try await URLSession.shared.data(for: request)
    
    do{
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
        print(jsonResponse)
        
        let decoder = JSONDecoder()
        let model = try decoder.decode(T.self, from: data)
        
        return model
    } catch let parsingError{
        print("error", parsingError)
    }
    
    return nil
}
