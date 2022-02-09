//
//  HomeView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import CodeScanner

struct HomeView: View {
    @EnvironmentObject var showLoaderEnv : LoaderInfo
    @Binding var menu : MenuItem
    @Binding var user : User
    
    @State var showNewCar : Bool = false
    @State var showAddCar : Bool = false
    @State var isNewCar : Bool = false
    
    var body: some View {
        VStack{
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 100)
            
            Text("Welkom \(user.name)")
            
            HStack{
                SubTitleText(text: "Je auto's:")
                
                Spacer()
                
                Menu(content: {
                    Button("Auto maken", action: {
                        showNewCar = true
                        isNewCar = true
                    })
                    Button("Auto QR-code scannen", action: {
                        showAddCar = true
                    })
                    Button("Auto handmatig delen", action: {
                        showNewCar = true
                        isNewCar = false
                    })
                }, label: {
                    Image("plus")
                })
            }.padding()
                
            
            ScrollView{
                
                ForEach(user.cars!, id: \.self) { car in
                    
                    NavigationLink(destination: CarDetailView(navigation: $menu, car: car, user: $user)){
                        
                        CarView(car: car).padding()
                        
                    }
                }
            }.navigationBarHidden(false)
                .navigationBarTitle(Text("Home"))
                .sheet(isPresented: $showNewCar, content: {
                    AddCarView(showPopup: $showNewCar, refresh: startHomePage, newCar: $isNewCar)
                })
        }.onAppear(perform: {
            Task{
                await startHomePage()
            }
        }).navigationTitle("Home")
            .sheet(isPresented: $showAddCar){
                CodeScannerView(codeTypes: [.qr], simulatedData: "ABCD\n0", completion: handleScan).navigationTitle("Scan qr code")
            }
    }
    
    func startHomePage() async {
        do{
            let result = try await apiGetUser()
            
            if result != nil {
                user = result!
            }
        } catch let error {
            print(error)
        }
        showLoaderEnv.hide()
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        switch result {
        case .success(let result):
            Task{
                print(result)
                let details = result.string.components(separatedBy: "\n")
                guard details.count == 2 else {return}
                await addCarToUser(sharecode: details[0], carId: details[1])
                await MainActor.run{
                    showAddCar = false
                }
            }
            
        case .failure(let error):
            print(error)
        }

    }
    
    func addCarToUser(sharecode : String, carId : String) async {
        showLoaderEnv.show()
        do{
            let result = try await apiAddSharedCar(id: carId, shareCode: sharecode)
            if result != nil {
                await startHomePage()
            }
        } catch let error {
            print(error)
        }
        showLoaderEnv.hide()
    }
}
