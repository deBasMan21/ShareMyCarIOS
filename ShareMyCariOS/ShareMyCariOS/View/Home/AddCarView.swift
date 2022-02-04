//
//  AddCarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import UIKit
import Foundation

struct AddCarView: View {
    @EnvironmentObject var loader : LoaderInfo
    @Binding var showPopup : Bool
    var refresh : () async -> Void
    
    @State var carName : String = ""
    @State var carPlate : String = ""
    @State var carImage : String = "tesla"
    
    @Binding var newCar : Bool
    @State var sharecode : String = ""
    @State var carId : String = ""
    
    @State var selectedImage = UIImage(named: "tesla")!
    @State var showImagePicker : Bool = false
    var body: some View {
        NavigationView{
            
            VStack{
                
                Form{
                    if newCar {
                        Section(header: Text("Autonaam:")){
                            TextField("John's auto", text: $carName)
                        }
                        
                        Section(header: Text("Kenteken:")){
                            TextField("AA-111-AA", text: $carPlate)
                        }
                        
                        Section(header: Text("Foto van de auto:")){
                            Text("Selecteer je foto").onTapGesture {
                                showImagePicker = true
                            }
                        }
                    } else {
                        Section(header: Text("Auto id:")){
                            TextField("9263", text: $carId)
                        }
                        
                        Section(header: Text("ShareCode:")){
                            TextField("KD6S", text: $sharecode)
                        }
                    }
                }.sheet(isPresented: $showImagePicker){
                    PhotoPicker(image: $selectedImage, onSucces: saveCar)
                }
            }
            
            .navigationBarTitle(newCar ? "Auto aanmaken" : "Auto toevoegen")
            .navigationBarItems(leading: Button("Annuleren", action: {
                showPopup = false
            }).foregroundColor(.blue), trailing: Button(newCar ? "Aanmaken" : "Toevoegen", action: {
                Task{
                    if newCar {
                        carImage = selectedImage.toString()
                        await createCar()
                    } else {
                        await addCarToUser()
                    }
                }
            }).foregroundColor(.blue))
        }
    }
    
    func saveCar(image : UIImage) {
        selectedImage = image
        carImage = image.toString()
    }
    
    func createCar() async{
        loader.show()
        do{
            let result = try await apiCreateCar(name: carName, plate: carPlate, image: carImage)
            if result != nil {
                await refresh()
                showPopup = false
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func addCarToUser() async {
        loader.show()
        do{
            let result = try await apiAddSharedCar(id: carId, shareCode: sharecode)
            if result != nil {
                await refresh()
                showPopup = false
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
}
