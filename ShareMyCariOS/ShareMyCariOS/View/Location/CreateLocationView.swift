//
//  CreateLocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct CreateLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var location : Location = Location(id: 0, address: "", zipCode: "", city: "", name: "")
    
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
        }.navigationTitle("Locatie aanmaken")
            .navigationBarItems(trailing:
                Button("Locatie maken", action: {
                    Task{
                        await createLocation()
                    }
                    presentationMode.wrappedValue.dismiss()
                }).foregroundColor(isValidLocation() ? .blue : .accentColor)
                        .disabled(!isValidLocation())
            )
    }
    
    func createLocation() async {
        do{
            _ = try await apiCreateLocation(location: location)
        } catch let error {
            print(error)
        }
    }
    
    func isValidLocation() -> Bool {
        return !location.name.isEmpty && !location.city.isEmpty && !location.address.isEmpty && !location.zipCode.isEmpty
    }
}
