//
//  Loader.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 04/02/2022.
//

import Foundation
import SwiftUI

class LoaderInfo: ObservableObject {
    @Published var showLoader = true
    
    func show() {
        Task{
            await MainActor.run{
                showLoader = true
            }
        }
        
    }
    
    func hide() {
        Task{
            await MainActor.run{
                showLoader = false
            }
        }
    }
}
