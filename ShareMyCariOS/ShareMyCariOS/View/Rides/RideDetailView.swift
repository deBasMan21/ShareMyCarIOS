//
//  RideDetailView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import MapKit
import CoreLocation
import EventKit

struct Marker: Identifiable {
    let id = UUID()
    var location: MapMarker
}

struct RideDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var ride : Ride
    @Binding var showLoader : Bool
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.521417246551735, longitude: 4.4900756137931035), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    
    @State private var markers : [Marker] = []
    
    @State private var gridItems = [GridItem(.fixed(150), alignment: .topLeading), GridItem(.fixed(200), alignment: .topLeading)]
    
    @State private var showUpdateRide : Bool = false
    
    @State private var isOwner : Bool = false
    
    @State private var showAlert : Bool = false
    @State private var userImage : UIImage = UIImage(named: "User")!
    
    let store = EKEventStore()
    
    var itemslong: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 120), alignment: .topLeading), count: 2)
    }
    
    var body: some View {
        VStack{
            ScrollView{
                Image("Navigation")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding(.bottom, 20)
                
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
                
                
                Image(uiImage: userImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipped()
                    .clipShape(Circle())
                    .overlay(Circle()
                        .stroke(lineWidth: 2))
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
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
                
//                SubTitleText(text: "Locatie")
                Image("Location")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding(.bottom, 20)
                
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
                
//                SubTitleText(text: "Overige details:").padding(.top, 40)
                Image("Info")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
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
                UpdateRideView(showPopUp: $showUpdateRide, ride: ride, refresh: startRideDetail, showLoader: $showLoader)
            }
            .navigationBarItems(trailing: Image("file-plus").onTapGesture(perform: {
                showAlert = true
            }))
            .alert(isPresented: $showAlert){
                Alert(title: Text("Agenda"), message: Text("Wil je deze rit in je agenda zetten?"), primaryButton: Alert.Button.default(Text("Nee")), secondaryButton: Alert.Button.default(Text("Ja"), action: {
                    createEventinTheCalendar(with: ride.name, forDate: Date.fromDateString(input: ride.beginDateTime), toDate: Date.fromDateString(input: ride.endDateTime))
                }))
            }
    }
    
    func startRideDetail() async {
        showLoader = true
        do{
            let result = try await apiGetRide(rideId: ride.id)
            
            if result != nil {
                ride = result!
                
                if ride.user != nil{
                    if !ride.user!.profilePicture.isEmpty {
                        userImage = ride.user!.profilePicture.toImage()
                    }
                }
                
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
    
    func deleteRide() async {
        showLoader = true
        do{
            _ = try await apiDeleteRide(rideId: ride.id)
        } catch let error {
            print(error)
        }
        showLoader = false
    }
    
    func createEventinTheCalendar(with title:String, forDate eventStartDate:Date, toDate eventEndDate:Date) {
        store.requestAccess(to: .event) { (success, error) in
            if  error == nil {
                showLoader = true
                let event = EKEvent.init(eventStore: self.store)
                event.title = title
                event.calendar = self.store.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
                event.startDate = eventStartDate
                event.endDate = eventEndDate
                event.location = "\(ride.destination?.address ?? ""), \(ride.destination?.city ?? "")"
                event.notes = "Rit #\(ride.id) met de auto: \(ride.car?.name ?? "Auto niet gevonden") door gebruiker \(ride.user?.name ?? "Gebruiker niet gevonden")"
                let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                event.addAlarm(alarm)
                
                do {
                    try self.store.save(event, span: .thisEvent)
                    //event created successfullt to default calendar
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                showLoader = false
            } else {
                //we have error in getting access to device calnedar
                print("error = \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
