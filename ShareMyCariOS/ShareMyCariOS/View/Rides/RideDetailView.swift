//
//  RideDetailView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}

struct RideDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var ride : Ride
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.521417246551735, longitude: 4.4900756137931035), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    @State private var markers : [Marker] = []
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    @State private var showUpdateRide : Bool = false
    
    @State private var isOwner : Bool = false
    
    var itemslong: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 120), alignment: .topLeading), count: 2)
    }
    
    var body: some View {
        VStack{
            ScrollView{
                SubTitleText(text: "Rit #\(ride.id)")
                
                LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                    Text("Naam:")
                    Text(ride.name)
                    Text("Begin moment:")
                    Text(Date.fromDateString(input: ride.beginDateTime).formatted())
                    Text("Eind moment:")
                    Text(Date.fromDateString(input: ride.endDateTime).formatted())
                    Text("Auto:")
                    Text(ride.car?.name ?? "Not found")
                }.padding(.horizontal)
                
                SubTitleText(text: "Gebruiker").padding(.top, 40)
                
                LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                    Text("Naam:")
                    Text(ride.user?.name ?? "Not found")
                    Text("Email:")
                    Text(ride.user?.email ?? "Not found")
                    Text("Telefoonnummer:")
                    Text(ride.user?.phoneNumber ?? "Not found")
                }.padding(.horizontal)
                
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: markers){ marker in
                    marker.location
                }.frame(width: 400, height: 300)
                    .padding(.vertical, 40)
                
                SubTitleText(text: "Locatie")
                
                LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                    Text("Locatie:")
                    Text(ride.destination?.name ?? "No destination name")
                    Text("Adres:")
                    Text(ride.destination?.address ?? "Not found")
                    Text("Postcode:")
                    Text(ride.destination?.zipCode ?? "Not found")
                    Text("Stad:")
                    Text(ride.destination?.city ?? "Not found")
                }.padding(.horizontal)
                
                SubTitleText(text: "Overige details:").padding(.top, 40)
                
                LazyVGrid(columns: itemslong, alignment: .leading, spacing: 10){
                    Text("Aangemaakt op:")
                    Text(Date.fromDateString(input: ride.reservationDateTime).formatted())
                    Text("Laatst aangepast op:")
                    Text(Date.fromDateString(input: ride.lastChangeDateTime).formatted())
                    Text("Aangemaakt door:")
                    Text(ride.user?.name ?? "Not found")
                }.padding(.horizontal)
                    .padding(.bottom, 30)
            }

            Spacer()
            
            if isOwner{
                HStack{
                    Spacer()
                    
                    Button("Rit aanpassen", action: {
                        showUpdateRide = true
                    }).padding(10)
                        .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Secondary"), lineWidth: 1)
                    ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                    
                    Spacer()
                    
                    Button("Rit verwijderen", action: {
                        Task{
                            await deleteRide()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }).padding(10)
                        .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Secondary"), lineWidth: 1)
                    ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                    
                    Spacer()
                }
            }
        }.navigationTitle(ride.name)
            .onAppear(perform: {
                Task{
                    await startRideDetail()
                }
            })
            .sheet(isPresented: $showUpdateRide){
                UpdateRideView(showPopUp: $showUpdateRide, ride: ride, refresh: startRideDetail)
            }
    }
    
    func startRideDetail() async {
        do{
            let result = try await apiGetRide(rideId: ride.id)
            
            if result != nil {
                ride = result!
                
                isOwner = ride.user?.id == getUserIdFromChain()

                coordinates(forAddress: "\(ride.destination!.address), \(ride.destination!.city)"){
                    (location) in
                    guard let location = location else {
                        return
                    }
                    markers.append(Marker(location: MapMarker(coordinate: location, tint: .red)))
                    region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    func deleteRide() async {
        do{
            _ = try await apiDeleteRide(rideId: ride.id)
        } catch let error {
            print(error)
        }
    }
}
