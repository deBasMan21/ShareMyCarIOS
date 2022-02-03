//
//  UpdateRideView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct UpdateRideView: View {
    @Binding var showPopUp : Bool
    @State var ride : Ride
    @State var refresh : () async -> Void
    
    @State var locations : [Location] = []
    
    @State var name : String = ""
    @State var beginDateTime: Date = Date()
    @State var endDateTime: Date = Date()
    @State var locationId : Int = 0
    
    @State var showError : Bool = false
    @State var errorMessage : String = ""
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Ritnaam:")){
                    TextField("Naar school", text: $name)
                }
                
                Section(header: Text("Begin moment:")){
                    DatePicker("Begin moment", selection: $beginDateTime, in: Date.now...)
                }
                
                Section(header: Text("Eind moment:")){
                    DatePicker("Eind moment", selection: $endDateTime, in: Date.now...)
                }
                
                Section(header: Text("Bestemming:")) {
                    Picker("Bestemming", selection: $locationId) {
                        ForEach(locations, id: \.self) { location in
                            Text(location.name).tag(location.id)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150, alignment: .center)
                    
                    NavigationLink(destination: CreateLocationView(isNew: true)){
                        Button("Locatie aanmaken", action: {
                            print("hi")
                        }).foregroundColor(.blue)
                    }
                }

            }.navigationBarTitle("Rit aanpassen")
                .navigationBarItems(
                    leading:
                        Button("Annuleren", action: {
                            showPopUp = false
                        }).foregroundColor(.blue),
                    trailing:
                        Button("Rit aanpassen", action: {
                            Task{
                                await createRide()
                            }
                        }).foregroundColor(isValidRide() ? .blue : .accentColor)
                            .disabled(!isValidRide())
                    )
            .onAppear(perform: {
                Task{
                    await startUpdateRide()
                }
            }).alert(isPresented: $showError){
                Alert(title: Text("Oeps..."), message: Text(errorMessage), dismissButton: Alert.Button.cancel(Text("Oke")))
            }
        }
    }
    
    func startUpdateRide() async {
        name = ride.name
        locationId = ride.destination!.id
        beginDateTime = Date.fromDateString(input: ride.beginDateTime)
        endDateTime = Date.fromDateString(input: ride.endDateTime)
        
        do {
            let result = try await apiGetLocations()
            if result != nil {
                locations = result!
            } else {
                errorMessage = "Er is iets misgegaan bij het ophalen van de locaties"
                showError = true
            }
        } catch let error {
            print(error)
        }
    }
    
    func isValidRide() -> Bool {
        return !name.isEmpty && beginDateTime > Date.now && endDateTime > beginDateTime && locationId != 0
    }
    
    func createRide() async {
        do{
            _ = try await apiUpdateRide(name: name, beginDateTime: beginDateTime, endDateTime: endDateTime, locationId: locationId, rideId: ride.id)
            await refresh()
            showPopUp = false
        }catch let error {
            print(error)
        }
    }
}
