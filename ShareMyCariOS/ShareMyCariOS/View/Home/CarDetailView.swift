//
//  CarDetailView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//


import SwiftUI


struct CarDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loader : LoaderInfo
    
    @Binding var navigation : MenuItem
    
    @State var car : Car
    @Binding var user : User
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
                                NavigationLink(destination: RideDetailView(ride: ride)){
                                    RideView(ride: ride).padding([.leading, .bottom, .trailing])
                                }
                            }
                        }
                    }
                    
                }

                Spacer().sheet(isPresented: $showShare) {
                    ShareCarView(carId: car.id, showShare: $showShare)
                }
                
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
                    showShare = true
                }
            }).opacity(car.isOwner ? 100: 0))

            .sheet(isPresented: $showUpdateCar, content: {
                if showCreateRide {
                    CreateRideView(showPopUp: $showUpdateCar, car: car, refresh: startCarDetail, user: $user)
                } else {
                    UpdateCarView(showPopup: $showUpdateCar, toMain: backToHome, car: car)
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
    
    func deleteCar() async {
        loader.show()
        do{
            _ = try await apiDeleteCar(id: car.id)
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func removeCar() async {
        loader.show()
        do{
            _ = try await apiRemoveCarFromUser(carId: car.id)
        } catch let error {
            print(error)
        }
        loader.hide()
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
