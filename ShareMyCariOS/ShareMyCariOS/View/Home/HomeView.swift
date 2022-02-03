//
//  HomeView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct HomeView: View {
    @Binding var menu : MenuItem
    @Binding var user : User
    @Binding var showLoader : Bool
    
    @State var showAddCar : Bool = false
    
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 100)
            
            Text("Welkom \(user.name)")
            
            HStack{
                SubTitleText(text: "Je auto's:")
                
                Spacer()
                
                Image("plus").onTapGesture {
                    showAddCar = true
                }
            }.padding()
            
            ScrollView{
                
                ForEach(user.cars!, id: \.self) { car in
                    
                    NavigationLink(destination: CarDetailView(navigation: $menu, showLoader: $showLoader, car: car)){
                        
                        CarView(car: car).padding()
                        
                    }
                }
            }.navigationBarHidden(false)
                .navigationBarTitle(Text("Home"))
                .sheet(isPresented: $showAddCar, content: {
                    AddCarView(showPopup: $showAddCar, refresh: startHomePage, showLoader : $showLoader)
                })
        }.onAppear(perform: {
            Task{
                await startHomePage()
            }
        }).navigationTitle("Home")
    }
    
    func startHomePage() async {
        do{
            let result = try await apiGetUser()
            
            if result != nil {
                user = result!
            }
        } catch let error {
            print(error)
        }
    }
}
