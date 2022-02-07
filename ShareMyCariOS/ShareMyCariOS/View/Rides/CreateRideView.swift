//
//  CreateRideView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct CreateRideView: View {
    @EnvironmentObject var loader : LoaderInfo
    @Binding var showPopUp : Bool
    @State var car : Car?
    @State var refresh : () async -> Void
    @Binding var user : User
    
    @State var locations : [Location] = []
    @State var cars : [Car] = []
    
    @State var name : String = ""
    @State var beginDateTime: Date = Date()
    @State var endDateTime: Date = Date()
    @State var locationId : Int = 0
    @State var carId : Int = 0

    @State var showConfirm : Bool = false
    
    var body: some View {
        NavigationView{
            Form{
                if car == nil {
                    Section(header: Text("Auto:")) {
                        Picker("Auto", selection: $carId) {
                            ForEach(user.cars ?? [], id: \.self) { car in
                                Text(car.name).tag(car.id)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150, alignment: .center)
                    }
                }
                
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
                        Text("Geen locatie").tag(0)
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
                }.alert(isPresented: $showConfirm){
                    Alert(title: Text("Bevestig"), message: Text("Weet je zeker dat je een rit wil maken zonder locatie? Als je wel een locatie hebt geselecteerd probeer deze dan opnieuw te selecteren."), primaryButton: Alert.Button.default(Text("Annuleren").foregroundColor(.red), action: {
                        showConfirm = false
                    }), secondaryButton: Alert.Button.cancel(Text("Oke"), action:{
                        Task{
                            await createRide()
                        }
                    }))
                }

            }.navigationBarTitle("Rit aanmaken")
                .navigationBarItems(
                    leading:
                        Button("Annuleren", action: {
                            showPopUp = false
                        }).foregroundColor(.blue),
                    trailing:
                        Button("Rit maken", action: {
                            confirmRide()
                        }).foregroundColor(isValidRide() ? .blue : .accentColor)
                            .disabled(!isValidRide())
                    )
            .onAppear(perform: {
                Task{
                    await startCreateRide()
                }
            })
        }
    }
    
    func startCreateRide() async {
        loader.show()
        if car != nil {
            carId = car!.id
        }
        do {
            let result = try await apiGetLocations()
            if result != nil {
                locations = result!
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func isValidRide() -> Bool {
        return !name.isEmpty && beginDateTime > Date.now && endDateTime > beginDateTime
    }
    
    func confirmRide(){
        if locationId == 0 {
            showConfirm = true
        } else {
            Task{
                await createRide()
            }
        }
    }
    
    func createRide() async {
        loader.show()
        do{
            _ = try await apiCreateRide(name: name, beginDateTime: beginDateTime, endDateTime: endDateTime, locationId: locationId, carId: carId)
            await refresh()
            showPopUp = false
        }catch let error {
            print(error)
        }
        loader.hide()
    }
}
