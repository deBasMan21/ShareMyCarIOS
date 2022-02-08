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
    @EnvironmentObject var loader : LoaderInfo
    @State private var locations : [Location] = []
    @Binding var user : User
    
    @State private var showAddLocation : Bool = false
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.2, longitude: 5.5), span: MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3))
    
    @State private var markers : [Place] = []
    
    var body: some View {
        VStack{
            Map(coordinateRegion: $region, annotationItems: markers){ marker in
                MapAnnotation(coordinate: marker.coordinate){
                    NavigationLink(destination: LocationDetailView(location: marker.loc)){
                        PlaceAnnotationView(marker: marker)
                    }
                }
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
                    CreateLocationView(isNew: true).onDisappear(perform: {
                        showAddLocation = false
                    })
                }
            }
    }
    
    func startLocation() async {
        loader.show()
        do{
            let result = try await apiGetLocations()
            if result != nil {
                locations = result!
                
                locations.forEach{ loc in
                    coordinates(forAddress: "\(loc.address), \(loc.city)"){
                        (location) in
                        guard let location = location else {
                            return
                        }
                        markers.append(Place(loc: loc, coordinate: location))
                    }
                }
            }
        } catch let error {
            print(error)
        }
        loader.hide()
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

struct PlaceAnnotationView: View {
    @State var marker : Place
    
    var body: some View {
        VStack(spacing: 0) {
          Image(systemName: "mappin.circle.fill")
            .font(.title)
            .foregroundColor(.red)
          
          Image(systemName: "arrowtriangle.down.fill")
            .font(.caption)
            .foregroundColor(.red)
            .offset(x: 0, y: -5)
            
            Text(marker.loc.name)
                .padding(.horizontal, 10)
                .background(
                    Text(marker.loc.name)
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .colorInvert()
                        )
                )
        }
    }
}

struct Place: Identifiable {
  let id = UUID()
  var loc: Location
  var coordinate: CLLocationCoordinate2D
}
