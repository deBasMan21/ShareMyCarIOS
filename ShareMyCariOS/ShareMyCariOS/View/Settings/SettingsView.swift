//
//  SettingsView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding var menu : MenuItem
    @Binding var user : User
    @Binding var showLoader : Bool
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    @State var userNotifications : Bool = true
    @State var userCalendarEvents : Bool = true
    
    @State var showImagePicker : Bool = false
    @State var showUpdateUser : Bool = false
    
    @State var currentImage : UIImage = UIImage(named: "User")!
    
    var body: some View {
        VStack{
            ScrollView{
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
                    
                    
                    Toggle("Push notifications", isOn: $user.sendNotifications)
                        .padding()
                        .onChange(of: user.sendNotifications){ value in
                            Task{
                                await savePrefs()
                            }
                        }
                        
                    Divider()
                    
                    Toggle("Show personal events in calendar", isOn: $user.showEventsInCalendar)
                        .padding()
                        .onChange(of: user.showEventsInCalendar){ value in
                            Task{
                                await savePrefs()
                            }
                        }
                    
                    Divider()
                }
            }
            
            Spacer()

            VStack{
                Button("Log uit", action: {
                    Task{
                        await logout()
                    }
                }).padding(10)
                    .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Secondary"), lineWidth: 1)
                ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
            }.sheet(isPresented: $showImagePicker){
                PhotoPicker(image: $currentImage, onSucces: saveImage)
            }

        }.onAppear(perform: {
            Task {
                await startSettings()
            }
        }).navigationTitle("Instellingen")
            .sheet(isPresented: $showUpdateUser){
                NavigationView{
                    UpdateUserView(user: user, refresh: startSettings, showLoader: $showLoader)
                }
            }
    }
    
    func startSettings() async {
        do {
            let result = try await apiGetUser()
            if result != nil {
                user = result!
                if !user.profilePicture.isEmpty{
                    currentImage = user.profilePicture.toImage()
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func saveImage(image : UIImage) {
        user.profilePicture = image.toString()
        Task{
            do{
                _ = try await apiUpdatePf(user: user)
            } catch let error {
                print(error)
            }
        }
    }
    
    func savePrefs() async {
        showLoader = true
        do{
            let result = try await apiUpdateUser(user: user)
            if result != nil {
                user = result!
            }
        } catch let error{
            print(error)
        }
        showLoader = false
    }
    
    func logout() async {
        showLoader = true
        do{
            _ = try await apiLogout()
            deleteAllTokens()
            menu = .login
        } catch let error {
            print(error)
        }
        showLoader = false
    }
}

