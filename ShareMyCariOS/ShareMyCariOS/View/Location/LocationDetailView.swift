//
//  LocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var location : Location
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.521417246551735, longitude: 4.4900756137931035), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    @State private var markers : [Marker] = []
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    @State private var showUpdateLocation : Bool = false
    var body: some View {
        VStack{
            ScrollView{
                VStack {
                    Image("Location")
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .center)
                        .padding(.bottom, 20)
                    
                    LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                        Text("Locatie:")
                        Text(location.name)
                        Text("Adres:")
                        Text(location.address)
                        Text("Postcode:")
                        Text(location.zipCode)
                        Text("Stad:")
                        Text(location.city)
                    }.padding(.horizontal)
                    
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: markers){ marker in
                        marker.location
                    }.frame(width: 400, height: 300)
                        .padding(.vertical, 40)
                        .onAppear(perform: {
                            Task{
                                await startLocationDetailView()
                            }
                        })
                }
                
                Spacer()    
            }
            
            HStack{
                Spacer()
                
                Button("Locatie aanpassen", action: {
                    showUpdateLocation = true
                }).padding(10)
                    .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Secondary"), lineWidth: 1)
                ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                
                Spacer()
                
                Button("Locatie verwijderen", action: {
                    Task{
                        await deleteLocation()
                    }
                    presentationMode.wrappedValue.dismiss()
                }).padding(10)
                    .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Secondary"), lineWidth: 1)
                ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                
                Spacer()
            }
        }.navigationTitle(location.name)
    }
    
    func startLocationDetailView() async {
        coordinates(forAddress: "\(location.address), \(location.city)"){
            (location) in
            guard let location = location else {
                return
            }
            markers.append(Marker(location: MapMarker(coordinate: location, tint: .red)))
            region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
    
    func deleteLocation() async {
        do{
            _ = try await apiDeleteLocation(locationId : location.id)
        } catch let error {
            print(error)
        }
    }
}
