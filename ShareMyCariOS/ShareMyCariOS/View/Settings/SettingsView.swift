//
//  SettingsView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding var menu : MenuItem
    
    var body: some View {
        Button("Log uit", action: {
            deleteAllTokens()
            menu = .login
        })
    }
}

