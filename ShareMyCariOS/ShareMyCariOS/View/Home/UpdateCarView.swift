//
//  UpdateCarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct UpdateCarView: View {
    @Binding var showPopup : Bool
    @State var toMain : () -> Void
    @State var car : Car
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Autonaam:")){
                    TextField("John's auto", text: $car.name)
                }
                
                Section(header: Text("Kenteken:")){
                    TextField("AA-111-AA", text: $car.plate)
                }
                
                Section(header: Text("Foto van de auto:")){
                    TextField("tesla", text: $car.image)
                }

            }
        
            
            .navigationBarTitle("Auto aanpassen")
            .navigationBarItems(leading: Button("Annuleren", action: {
                showPopup = false
            }).foregroundColor(.blue), trailing: Button("Aanpassen", action: {
                Task{
                    await updateCar()
                }
                toMain()
            }).foregroundColor(.blue))
        }
    }
    
    func updateCar() async {
        do{
            _ = try await apiUpdateCar(id: car.id, name: car.name, plate: car.plate, image: car.image)
            showPopup = false
        }catch let error {
            print(error)
        }
    }
}

