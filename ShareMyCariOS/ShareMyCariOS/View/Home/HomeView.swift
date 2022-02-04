//
//  HomeView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var showLoaderEnv : LoaderInfo
    @Binding var menu : MenuItem
    @Binding var user : User
    
    @State var newCar : Bool = true
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
                
                Menu(content: {
                    Button("Auto aanmaken", action: {
                        newCar = true
                        showAddCar = true
                    })
                    Button("Auto toevoegen", action: {
                        newCar = false
                        showAddCar = true
                    })
                }, label: {
                    Image("plus")
                })
            }.padding()
            
            ScrollView{
                
                ForEach(user.cars!, id: \.self) { car in
                    
                    NavigationLink(destination: CarDetailView(navigation: $menu, car: car, user: $user)){
                        
                        CarView(car: car).padding()
                        
                    }
                }
            }.navigationBarHidden(false)
                .navigationBarTitle(Text("Home"))
                .sheet(isPresented: $showAddCar, content: {
                    AddCarView(showPopup: $showAddCar, refresh: startHomePage, newCar: $newCar)
                })
        }.onAppear(perform: {
            Task{
                await startHomePage()
            }
        }).navigationTitle("Home")
    }
    
    func startHomePage() async {
        showLoaderEnv.hide()
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
