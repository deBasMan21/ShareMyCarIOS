//
//  GenericApiCalls.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

func authorizedApiCall<T : Decodable>(url : String, body : [String : Any]?, method : String, obj: T) async throws -> T? {
    let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiI5MjhlYjM0Yi1kNzUxLTRlMjQtOThhYy0xYjUyMjRjMmExMTciLCJuYW1lIjoic3RyaW5nIiwiZW1haWwiOiJzdHJpbmciLCJBc3BOZXQuSWRlbnRpdHkuU2VjdXJpdHlTdGFtcCI6IkxUN1hVRE5BVks3TEdDQzI2RjJVQ1k1Mkk1TTJYWUc2IiwiVXNlcklkIjoiNCIsIm5iZiI6MTY0MzI4ODQwMSwiZXhwIjoxNjQzMzc0ODAxLCJpYXQiOjE2NDMyODg0MDF9.yOdbM_UZ5q1eaTamxro1lHoN8SmtOmxk577AennFN7E"
    
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
