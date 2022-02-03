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
    
    @State var userNotifications : Bool = true
    
    @State var showImagePicker : Bool = false
    @State var showUpdateUser : Bool = false
    
    @State var currentImage : UIImage = UIImage(named: "User")!
    
    var body: some View {
        VStack{
            Image(uiImage: currentImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .clipped()
                .clipShape(Circle())
                .overlay(Circle()
                    .stroke(lineWidth: 2))
                .padding([.leading, .trailing, .top])
            
            Button("Foto aanpassen", action: {
                showImagePicker = true
            }).foregroundColor(.blue)
                .padding([.leading, .trailing, .bottom])
            
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
            
            Button("Account aanpassen", action: {
                showUpdateUser = true
            }).foregroundColor(.blue)
                .padding([.leading, .trailing, .bottom])
            
            Divider()
            
            Toggle("Push notifications", isOn: $userNotifications)
                .padding()
            
            Spacer()

            VStack{
                Button("Log uit", action: {
                    deleteAllTokens()
                    menu = .login
                }).padding(10)
                    .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Secondary"), lineWidth: 1)
                ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
            }.sheet(isPresented: $showImagePicker){
                PhotoPicker(image: $currentImage, onSucces: temp)
            }
        }.onAppear(perform: {
            Task {
                await startSettings()
            }
        }).navigationTitle("Instellingen")
            .sheet(isPresented: $showUpdateUser){
                NavigationView{
                    UpdateUserView(user: user, refresh: startSettings)
                }
            }
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
    
    func temp(image : UIImage) {
        print("hi")
    }
}

