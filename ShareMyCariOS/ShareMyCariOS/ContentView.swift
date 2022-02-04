//
//  ContentView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loader : LoaderInfo
    @Binding var menu : MenuItem
    @State var user : User = User(id: 1, name: "", email: "", phoneNumber: "", showEventsInCalendar: true, sendNotifications: true, profilePicture: "", cars: [])
    
    var body: some View {
        if menu == .login {
            LoginView(menu: $menu)
        } else if menu == .register {
            RegisterView(menu : $menu)
        } else {
            LoadingView(){
                GeneralPageLayout(menu: $menu, user: $user).onAppear(perform: {
                    Task{
                        await startApplication()
                    }
                })
            }

        }
    }
    
    
    func startApplication() async {
        loader.show()
        do{
            let result = try await apiGetUser()
            
            if result != nil {
                user = result!
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
}
