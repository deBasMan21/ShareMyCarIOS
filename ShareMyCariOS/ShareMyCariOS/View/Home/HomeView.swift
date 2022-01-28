//
//  HomeView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct HomeView: View {
    @Binding var menu : MenuItem
    @State var user : User = User(id: 1, name: "", email: "", phoneNumber: "", cars: [])
    
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
                    
                    NavigationLink(destination: CarDetailView(navigation: $menu, car: car)){
                        
                        CarView(car: car).padding()
                        
                    }
                }
            }.navigationBarHidden(true)
                .navigationBarTitle(Text("Home"))
                .sheet(isPresented: $showAddCar, content: {
                    AddCarView(showPopup: $showAddCar, refresh: startHomePage)
                })
        }.onAppear(perform: {
            Task{
                await startHomePage()
            }
        })
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
