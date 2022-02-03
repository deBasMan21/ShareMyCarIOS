//
//  CarDetailView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct CarDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var navigation : MenuItem
    @Binding var showLoader : Bool
    
    @State var car : Car
    @State var showShare: Bool = false
    @State var shareCode: String = "A K 1 D"
    
    @State var showUpdateCar: Bool = false
    @State var showCreateRide : Bool = false
    
    @State var rides : [Ride] = []
    
    var body: some View {
            VStack{
                ScrollView{
                    Image(uiImage: car.image.toImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    
                    Text(car.name)
                        .font(Font.headline.weight(.bold))
                    
                    Text(car.plate)
                    
                    HStack{
                        SubTitleText(text: "Geplande ritten:")
                        
                        Spacer()
                        
                        Image("plus").onTapGesture(perform: {
                            showCreateRide = true
                            showUpdateCar = true
                        })
                    }.padding([.top, .leading, .trailing])
                    
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(rides, id: \.self){ ride in
                                NavigationLink(destination: RideDetailView(ride: ride, showLoader: $showLoader)){
                                    RideView(ride: ride).padding([.leading, .bottom, .trailing])
                                }
                            }
                        }
                    }
                    
                }
                
                

                Spacer()
                
                if car.isOwner {
                    HStack{
                        Spacer()
                        
                        Button("Auto aanpassen", action: {
                            showUpdateCar = true
                        }).padding(10)
                            .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Secondary"), lineWidth: 1)
                        ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                        
                        Spacer()
                        
                        Button("Auto verwijderen", action: {
                            Task{
                                await deleteCar()
                            }
                            presentationMode.wrappedValue.dismiss()
                        }).padding(10)
                            .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Secondary"), lineWidth: 1)
                        ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                        
                        Spacer()
                    }
                } else {
                    Button("Auto ontkoppelen", action: {
                        Task{
                            await removeCar()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }).padding(10)
                        .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Secondary"), lineWidth: 1)
                    ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                }


        }.navigationTitle(car.name)
            .navigationBarItems(trailing: Button("Delen", action: {
                if car.isOwner {
                    Task{
                        await shareCar()
                    }
                }
            }).opacity(car.isOwner ? 100: 0))
            .alert(isPresented: $showShare){
                Alert(title: Text(shareCode), message: Text("Vul deze code in met het id \(car.id) bij degene met wie je de auto wil delen en als de auto is toegevoegd kan je op klaar klikken."), dismissButton: Alert.Button.default(Text("Klaar"), action: {
                    Task{
                        await endShareCar()
                    }
                }))
            }
            .sheet(isPresented: $showUpdateCar, content: {
                if showCreateRide {
                    CreateRideView(showPopUp: $showUpdateCar, car: car, showLoader: $showLoader, refresh: startCarDetail)
                        .onDisappear(perform: {
                            showCreateRide = false
                        })
                } else {
                    UpdateCarView(showPopup: $showUpdateCar, toMain: backToHome, car: car, showLoader: $showLoader)
                }
            })
            .onAppear(perform: {
                Task{
                    await startCarDetail()
                }
            })
    }
    
    func backToHome() {
        presentationMode.wrappedValue.dismiss()
    }
    
    func shareCar() async {
        showLoader = true
        do {
            let result = try await apiShareCar(id: car.id)
            if result != nil {
                
                shareCode = result!
                showShare = true
            }
        } catch let error {
            print(error)
        }
        showLoader = false
    }
    
    func endShareCar() async {
        do {
            _ = try await apiEndShareCar(id: car.id)
        } catch let error {
            print(error)
        }
    }
    
    func deleteCar() async {
        showLoader = true
        do{
            _ = try await apiDeleteCar(id: car.id)
        } catch let error {
            print(error)
        }
        showLoader = false
    }
    
    func removeCar() async {
        showLoader = true
        do{
            _ = try await apiRemoveCarFromUser(carId: car.id)
        } catch let error {
            print(error)
        }
        showLoader = false
    }
    
    func startCarDetail() async {
        do{
            let result = try await apiGetRidesForCar(carId: car.id)
            
            if result != nil {
                rides = result!
            }
            
            let carResult = try await apiGetCar(carId: car.id)
            
            if carResult != nil {
                car = carResult!
            }
        } catch let error {
            print(error)
        }
    }

}
