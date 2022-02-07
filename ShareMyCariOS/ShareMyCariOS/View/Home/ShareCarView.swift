//
//  ShareCarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 07/02/2022.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ShareCarView: View {
    @EnvironmentObject var loader : LoaderInfo
    var carId : Int
    
    @Binding var showShare : Bool
    
    @State var image = UIImage()
    @State var shareCode : String = ""
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView{
            VStack{
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Divider()
                    .padding()
                
                Text("Scan deze QR-code op het device waarmee je de auto wil delen.")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding()
                
                Text("Lukt dit niet? Voer dan handmatig de code hieronder in.")
                    .padding()
                    .multilineTextAlignment(.center)
                
                Text("Deelcode: \(shareCode)")
                
                Text("Id: \(carId)")
            }.navigationBarItems(trailing: Button("Klaar", action: {
                showShare = false
            }).foregroundColor(.blue))
                .navigationTitle("Auto delen")
        }.onDisappear{
            Task{
                await endShareCar()
            }
        }.onAppear(perform: {
            Task {
                await shareCar()
            }
        })
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return nil
    }
    
    func shareCar() async {
        loader.show()
        do {
            let result = try await apiShareCar(id: carId)
            if result != nil {
                
                shareCode = result!
                image = generateQRCode(from: "\(shareCode)\n\(carId)") ?? UIImage()
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func endShareCar() async {
        do {
            _ = try await apiEndShareCar(id: carId)
        } catch let error {
            print(error)
        }
    }
}
