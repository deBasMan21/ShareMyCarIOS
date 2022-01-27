//
//  ShareMyCariOSApp.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

@main
struct ShareMyCariOSApp: App {
    @State var menu : MenuItem = .home
    
    var body: some Scene {
        WindowGroup {
            ContentView(menu: $menu)
        }
    }
}
