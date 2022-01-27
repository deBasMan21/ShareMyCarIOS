//
//  ContentView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct ContentView: View {
    @Binding var menu : MenuItem
    
    var body: some View {
        if menu == .login {
            LoginView()
        } else if menu == .register {
            RegisterView()
        } else {
            GeneralPageLayout(menu: $menu)
        }
    }
}
