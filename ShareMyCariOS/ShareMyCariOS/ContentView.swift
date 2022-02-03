//
//  ContentView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct ContentView: View {
    @Binding var menu : MenuItem
    @State var user : User = User(id: 1, name: "", email: "", phoneNumber: "", showEventsInCalendar: true, sendNotifications: true, profilePicture: "", cars: [])
    @State public var showLoader: Bool = false
    
    var body: some View {
        if menu == .login {
            LoginView(menu: $menu)
        } else if menu == .register {
            RegisterView(menu : $menu)
        } else {
            LoadingView(isShowing: $showLoader){
                GeneralPageLayout(menu: $menu, user: $user, showLoader: $showLoader).onAppear(perform: {
                    Task{
                        await startApplication()
                    }
                })
            }

        }
    }
    
    
    func startApplication() async {
        showLoader = true
        do{
            let result = try await apiGetUser()
            
            if result != nil {
                user = result!
            }
        } catch let error {
            print(error)
        }
        showLoader = false
    }
}
