//
//  LocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationView: View {
    @Binding var pin : MKCoordinateRegion
    @State var location : Location
    
    @State private var gridItems = [GridItem(.fixed(100), alignment: .topLeading), GridItem(.fixed(150), alignment: .topLeading)]
    
    var body: some View {
        VStack{
            SubTitleText(text: location.name)
            
            LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                Text("Adres:")
                Text(location.address)
                Text("Postcode:")
                Text(location.zipCode)
                Text("Stad:")
                Text(location.city)
            }.padding(.horizontal)
            
            Button ("Laat Zien op kaart", action: {
                setLocation()
            }).foregroundColor(.blue)
                .padding()
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("Secondary"), lineWidth: 1)
            ).background(RoundedRectangle(cornerRadius: 20).fill(Color("Secondary")))
    }
    
    func setLocation() {
        coordinates(forAddress: "\(location.address), \(location.city)"){
            (location) in
            guard let location = location else {
                return
            }
            pin = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
}
