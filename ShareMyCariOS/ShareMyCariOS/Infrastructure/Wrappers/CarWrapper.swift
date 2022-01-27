//
//  CarWrapper.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import Foundation

struct CarWrapper : Decodable {
    var result : Car
}

struct ShareCarWrapper : Decodable {
    var result : String
}
