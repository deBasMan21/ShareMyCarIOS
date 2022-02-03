//
//  LocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationsView: View {
    @State private var locations : [Location] = []
    @Binding var user : User
    @Binding var showLoader : Bool
    
    @State private var showAddLocation : Bool = false
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.95016535, longitude: 6.28259561753436), span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))
    
    @State private var markers : [Marker] = []
    
    var body: some View {
        VStack{
            if locations.count == 0 {
                Text("Je hebt nog geen ritten. Maak er een aan door bovenaan op het plusje te drukken.")
                    .multilineTextAlignment(.center)
            } else {
                ScrollView{
                    ForEach(locations, id: \.self){ location in
                        NavigationLink(destination: LocationDetailView(location: location, showLoader: $showLoader)){
                            LocationView(pin: $region, location: location).padding()
                        }
                    }
                }
                
                Spacer()
                
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: markers){ marker in
                    marker.location
                }.frame(width: 400, height: 250)
            }
        }.navigationBarTitle("Locatie's")
            .navigationBarItems(trailing: Image("plus").onTapGesture {
                showAddLocation = true
            }).onAppear(perform: {
                Task{
                    await startLocation()
                }
            }).sheet(isPresented: $showAddLocation){
                NavigationView{
                    CreateLocationView(isNew: true, showLoader: $showLoader).onDisappear(perform: {
                        showAddLocation = false
                    })
                }
            }
    }
    
    func startLocation() async {
        showLoader = true
        do{
            let result = try await apiGetLocations()
            if result != nil {
                locations = result!
                
                locations.forEach{ location in
                    coordinates(forAddress: "\(location.address), \(location.city)"){
                        (location) in
                        guard let location = location else {
                            return
                        }
                        markers.append(Marker(location: MapMarker(coordinate: location, tint: .red)))
                    }
                }
            }
        } catch let error {
            print(error)
        }
        showLoader = false
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
}
