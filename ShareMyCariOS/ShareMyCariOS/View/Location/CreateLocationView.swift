//
//  CreateLocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct CreateLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loader : LoaderInfo
    @State var isNew : Bool
    
    @State var location : Location = Location(id: 0, address: "", zipCode: "", city: "", name: "")
    @State var refresh: (() async -> Void)?
    
    var body: some View {
        Form{
            Section(header: Text("Locatienaam:")){
                TextField("School", text: $location.name)
            }
            
            Section(header: Text("Adress:")){
                TextField("Lovensdijkstraat 61", text: $location.address)
            }
            
            Section(header: Text("Postcode:")){
                TextField("4808LA", text: $location.zipCode)
            }
            
            Section(header: Text("Stad:")){
                TextField("Breda", text: $location.city)
            }
        }.navigationTitle(isNew ? "Locatie aanmaken" : "Locatie bijwerken")
            .navigationBarItems(leading: Button("Annuleren", action: {
                presentationMode.wrappedValue.dismiss()
            }).foregroundColor(.blue) ,trailing:
                Button(isNew ? "Locatie aanmaken" : "Locatie bijwerken", action: {
                    Task{
                        if isNew {
                            await createLocation()
                        } else {
                            await updateLocation()
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }).foregroundColor(isValidLocation() ? .blue : .accentColor)
                        .disabled(!isValidLocation())
            )
    }
    
    func createLocation() async {
        loader.show()
        do{
            _ = try await apiCreateLocation(location: location)
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func updateLocation() async {
        loader.show()
        do{
            _ = try await apiUpdateLocation(location: location)
            if refresh != nil {
                await refresh!()
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func isValidLocation() -> Bool {
        return !location.name.isEmpty && !location.city.isEmpty && !location.address.isEmpty && !location.zipCode.isEmpty
    }
}
