//
//  GeneralPageLayout.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct GeneralPageLayout: View {
    @Binding var menu : MenuItem
    
    var body: some View {
        VStack{
            NavigationView{
                if menu == .home {
                    HomeView(menu: $menu)
                } else if menu == .rides {
                    RidesView()
                } else if menu == .settings {
                    SettingsView(menu : $menu)
                } else if menu == .locations {
                    LocationsView()
                }
                
                Spacer()
            }

            Spacer()
            
            HStack{
                Spacer()
                
                Image("HomeIcon").onTapGesture {
                    menu = .home
                }
                
                Spacer()
                
                Image("CalendarIcon").onTapGesture {
                    menu = .rides
                }
                
                Spacer()
                
                Image("MapIcon").onTapGesture {
                    menu = .locations
                }
                
                Spacer()
                
                Image("SettingsIcon").onTapGesture {
                    menu = .settings
                }
                
                Spacer()
            }.padding(20)
        }
    }
}
