//
//  LocationManager.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 09/02/2022.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Binding var region : MKCoordinateRegion
    
    @Published var location: CLLocationCoordinate2D?
    
    init(region : Binding<MKCoordinateRegion>){
        _region = region
        super.init()
        manager.delegate = self
        
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        region = MKCoordinateRegion(center: location!, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
