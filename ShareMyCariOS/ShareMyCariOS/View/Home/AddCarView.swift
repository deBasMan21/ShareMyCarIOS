//
//  AddCarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct AddCarView: View {
    @Binding var showPopup : Bool
    var refresh : () async -> Void
    
    @State var carName : String = ""
    @State var carPlate : String = ""
    @State var carImage : String = "tesla"
    
    @State var newCar : Bool = true
    @State var sharecode : String = ""
    @State var carId : String = ""
    
    var body: some View {
        NavigationView{
            
            VStack{
                Picker(selection: $newCar, label: Text("Auto maken of toevoegen")){
                    Text("Nieuwe auto").tag(true)
                    Text("Auto toevoegen").tag(false)
                }.pickerStyle(.segmented)
                    .padding()
                
                Form{
                    if newCar {
                        Section(header: Text("Autonaam:")){
                            TextField("John's auto", text: $carName)
                        }
                        
                        Section(header: Text("Kenteken:")){
                            TextField("AA-111-AA", text: $carPlate)
                        }
                        
                        Section(header: Text("Foto van de auto:")){
                            TextField("tesla", text: $carImage)
                        }
                    } else {
                        Section(header: Text("Auto id:")){
                            TextField("9263", text: $carId)
                        }
                        
                        Section(header: Text("ShareCode:")){
                            TextField("KD6S", text: $sharecode)
                        }
                    }
                }
            }
            
            .navigationBarTitle("Auto toevoegen")
            .navigationBarItems(leading: Button("Annuleren", action: {
                showPopup = false
            }).foregroundColor(.blue), trailing: Button(newCar ? "Aanmaken" : "Toevoegen", action: {
                Task{
                    if newCar {
                        await createCar()
                    } else {
                        await addCarToUser()
                    }
                }
            }).foregroundColor(.blue))
        }
    }
    
    func createCar() async{
        do{
            let result = try await apiCreateCar(name: carName, plate: carPlate, image: carImage)
            if result != nil {
                await refresh()
                showPopup = false
            }
        } catch let error {
            print(error)
        }
    }
    
    func addCarToUser() async {
        print(carId)
        print(sharecode)
        do{
            let result = try await apiAddSharedCar(id: carId, shareCode: sharecode)
            if result != nil {
                await refresh()
                showPopup = false
            }
        } catch let error {
            print(error)
        }
    }
}
