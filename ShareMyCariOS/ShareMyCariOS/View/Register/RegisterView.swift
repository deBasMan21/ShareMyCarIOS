//
//  RegisterView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct RegisterView: View {
    @Binding var menu : MenuItem
    
    @State var email : String = ""
    @State var password : String = ""
    @State var passwordConfirm : String = ""
    @State var name : String = ""
    @State var phoneNumber : String = ""
    
    @State var showError : Bool = false
    @State var errorMessage : String = "Er is iets fout gegaan"
    
    @State private var showLoader : Bool = false
    
    var body: some View {
        VStack{
            LoadingView(isShowing: $showLoader){
                ScrollView{
                    VStack{
                        Spacer()
                        
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 50)
                        
                        VStack{
                            Text("Email")
                            TextField("john@doe.nl", text: $email)
                                .keyboardType(.emailAddress)
                                .multilineTextAlignment(.center)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("Secondary"), lineWidth: 1)
                                )
                        }
                        
                        VStack{
                            Text("Wachtwoord")
                            SecureField("wachtwoord", text: $password)
                                .multilineTextAlignment(.center)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("Secondary"), lineWidth: 1)
                                )
                        }
                        
                        VStack{
                            Text("Bevestig wachtwoord")
                            SecureField("wachtwoord", text: $passwordConfirm)
                                .multilineTextAlignment(.center)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("Secondary"), lineWidth: 1)
                                )
                        }

                        VStack{
                            Text("Naam")
                            TextField("John Doe", text: $name)
                                .multilineTextAlignment(.center)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("Secondary"), lineWidth: 1)
                                )
                        }

                        VStack{
                            Text("Telefoonnummer")
                            TextField("06 1234567", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .multilineTextAlignment(.center)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("Secondary"), lineWidth: 1)
                                )
                        }

                        VStack{
                            Button("Registreren", action: {
                                Task{
                                    await register()
                                }
                            }).padding(10)
                                .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("Secondary"), lineWidth: 1)
                                ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                            
                            Button("Al een account? Log hier in", action: {
                                menu = .login
                            }).padding(10)
                                .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("Secondary"), lineWidth: 1)
                            ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                        }

                        Spacer()
                        
                    }.onAppear(perform: {
                        startRegister()
                    }).padding(.horizontal, 50)
                        .alert(isPresented: $showError){
                            Alert(title: Text("Oeps.."), message: Text(errorMessage), dismissButton: Alert.Button.default(Text("Oke"), action: {
                                print("hi")
                            }))
                        }
                }
                
            }
        }
        
    }
    
    func startRegister() {
        let token : String = getTokenFromChain()
        if token != " " {
            menu = .home
        }
    }
    
    func isValid() -> Bool {
        return password == passwordConfirm && !password.isEmpty && !name.isEmpty && !email.isEmpty && !phoneNumber.isEmpty
    }
    
    func register() async {
        showLoader = true
        if isValid() {
            do{
                let result = try await apiRegister(email: email, password: password, name: name, phoneNumber: phoneNumber)
                if result != nil {
                    menu = .home
                } else {
                    errorMessage = "Controleer uw email en wachtwoord of maak een account aan als u die nog niet heeft"
                    showError = true
                }
            } catch let error {
                print(error)
            }
        } else {
            errorMessage = "Registratie formulier niet geldig. Vul alles in en probeer het opnieuw!"
            showError = true
        }
        showLoader = false
    }
}
