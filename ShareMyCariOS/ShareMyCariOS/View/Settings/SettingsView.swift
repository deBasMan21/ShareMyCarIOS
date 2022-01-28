//
//  SettingsView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding var menu : MenuItem
    
    @State var user : User = User(id: 0, name: "", email: "", phoneNumber: "", cars: [])
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    var body: some View {
        VStack{
            VStack{
                LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                    Text("Naam:")
                    Text(user.name)
                    Text("Email:")
                    Text(user.email)
                    Text("Telefoonnummer:")
                    Text(user.phoneNumber)
                }.padding(.horizontal)
            }
            
            Divider()

            VStack{
                Button("Log uit", action: {
                    deleteAllTokens()
                    menu = .login
                })
            }
        }.onAppear(perform: {
            Task {
                await startSettings()
            }
        }).navigationTitle("Instellingen")
    }
    
    func startSettings() async {
        do {
            let result = try await apiGetUser()
            if result != nil {
                user = result!
            }
        } catch let error {
            print(error)
        }
    }
}

