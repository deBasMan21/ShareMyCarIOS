//
//  Loader.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 04/02/2022.
//

import Foundation

class LoaderInfo: ObservableObject {
    @Published var showLoader = true
    
    func show() {
        showLoader = true
    }
    
    func hide() {
        showLoader = false
    }
}
