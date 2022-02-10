//
//  SettingsView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    @EnvironmentObject var iconSettings:IconNames
    @EnvironmentObject var loader : LoaderInfo
    @Binding var menu : MenuItem
    @Binding var user : User
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    @State var showImagePicker : Bool = false
    @State var showUpdateUser : Bool = false
    @State var showUpdatePassword : Bool = false
    @AppStorage("showEventsInCalendar") private var showEventsIncalendar = false
    
    @State var currentImage : UIImage = UIImage(named: "User")!
    
    let store = EKEventStore()
    
    var body: some View {
        VStack{
            ScrollView{
                VStack{
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
                    }
                    
                    VStack{
                        LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                            Text("Naam:")
                            Text(user.name)
                            Text("Email:")
                            Text(user.email)
                            Text("Telefoonnummer:")
                            Text(user.phoneNumber)
                        }.padding(.horizontal)
                        
                        Button("Account aanpassen", action: {
                            showUpdateUser = true
                        }).foregroundColor(.blue)
                            .padding([.leading, .trailing, .bottom])
                        
                        Button("Wachtwoord aanpassen", action: {
                            showUpdatePassword = true
                        }).foregroundColor(.blue)
                            .padding([.leading, .trailing, .bottom])
                    }
                    
                    VStack{
                        Divider()
                        
                        
                        Toggle("Push notifications", isOn: $user.sendNotifications)
                            .padding()
                            .onChange(of: user.sendNotifications){ value in
                                Task{
                                    await savePrefs()
                                }
                            }
                            
                        Divider()
                        
                        Toggle("Show personal events in calendar", isOn: $showEventsIncalendar)
                            .padding()
                    
                    VStack{
                        Divider()
                        
                        HStack{
                            Text("AppIcon veranderen")
                            
                            Spacer()
                            
                            Picker(selection: $iconSettings.currentIndex,label:Text("Icons")){
                                ForEach(0 ..< iconSettings.iconNames.count){i in
                                    HStack(spacing:20){
                                        Text(self.iconSettings.iconNames[i] ?? "light").padding()
                                        Image(uiImage: UIImage(named: self.iconSettings.iconNames[i] ?? "AppIcon") ?? UIImage())
                                            .resizable()
                                            .renderingMode(.original)
                                            .frame(width: 50, height: 50, alignment: .leading)
                                    }
                                }.onReceive([self.iconSettings.currentIndex].publisher.first()){ value in
                                    let i = self.iconSettings.iconNames.firstIndex(of: UIApplication.shared.alternateIconName) ?? 0
                                    if value != i{
                                        UIApplication.shared.setAlternateIconName(self.iconSettings.iconNames[value], completionHandler: {
                                            error in
                                            if let error = error {
                                                print(error.localizedDescription)
                                            } else {
                                                print("Success!")
                                            }
                                        })
                                    }
                                }
                            }
                        }.padding()
                        
                        Divider()
                    }.sheet(isPresented: $showUpdatePassword){
                        UpdatePasswordView()
                    }
                    }
                    
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
                    UpdateUserView(user: user, refresh: startSettings)
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
        loader.show()
        do{
            let result = try await apiUpdateUser(user: user)
            if result != nil {
                user = result!
            }
        } catch let error{
            print(error)
        }
        loader.hide()
    }
    
    func logout() async {
        loader.show()
        do{
            _ = try await apiLogout()
            deleteAllTokens()
            menu = .login
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func requestPermission() -> Bool {
        var result = false
        store.requestAccess(to: .event) { (success, error) in
            if error != nil {
                user.showEventsInCalendar = false
            } else {
                if success {
                    result = true
                } else {
                    user.showEventsInCalendar = false
                }
            }
        }
        return result
    }
}

