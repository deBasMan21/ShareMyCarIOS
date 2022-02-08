//
//  UpdateCarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct UpdateCarView: View {
    @EnvironmentObject var loader : LoaderInfo
    @Binding var showPopup : Bool
    @State var toMain : () -> Void
    @State var car : Car
    
    @State var selectedImage = UIImage(named: "tesla")!
    @State var showImagePicker : Bool = false
    
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
                    Text("Selecteer je foto").onTapGesture {
                        showImagePicker = true
                    }
                }

            }
            .navigationBarTitle("Auto aanpassen")
            .navigationBarItems(leading: Button("Annuleren", action: {
                showPopup = false
            }).foregroundColor(.blue), trailing: Button("Aanpassen", action: {
                updateCar(image: car.image.toImage())
            }).foregroundColor(isValid() ? .blue : .gray)
                .disabled(!isValid())
            )
            .sheet(isPresented: $showImagePicker){
                PhotoPicker(image: $selectedImage, onSucces: updateCar)
            }
        }
    }
    
    func isValid() -> Bool {
        return !car.name.isEmpty && !car.plate.isEmpty
    }
    
    func updateCar(image : UIImage) {
        Task{
            await MainActor.run{
                loader.show()
            }
            do{
                _ = try await apiUpdateCar(id: car.id, name: car.name, plate: car.plate, image: image.toString())
                showPopup = false
            }catch let error {
                print(error)
            }
            await MainActor.run{
                loader.hide()
                toMain()
            }
        }

    }
}

