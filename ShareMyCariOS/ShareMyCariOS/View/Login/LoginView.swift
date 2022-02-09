//
//  LoginView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Binding var menu : MenuItem
    
    @State var email : String = ""
    @State var password : String = ""
    
    @State var showError : Bool = false
    
    @EnvironmentObject var loader : LoaderInfo
    
    var body: some View {
        VStack{
            LoadingView(){
                VStack{
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 50)
                    
                    Text("Email")
                    TextField("john@doe.nl", text: $email)
                        .keyboardType(.emailAddress)
                        .multilineTextAlignment(.center)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Secondary"), lineWidth: 1)
                        )
                    
                    Text("Wachtwoord")
                    SecureField("wachtwoord", text: $password)
                        .multilineTextAlignment(.center)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("Secondary"), lineWidth: 1)
                        )
                    
                    Button("Inloggen", action: {
                        Task{
                            await login()
                        }
                    }).padding(10)
                        .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Secondary"), lineWidth: 1)
                    ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                    
                    Button("Nog geen account? Registreer hier", action: {
                        menu = .register
                    }).padding(10)
                        .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("Secondary"), lineWidth: 1)
                    ).background(RoundedRectangle(cornerRadius: 10).fill(Color("Secondary")))
                    
                    Spacer()
                }.onAppear(perform: {
                    startLogin()
                }).padding(.horizontal, 50)
                    .alert(isPresented: $showError){
                        Alert(title: Text("Inloggen mislukt"), message: Text("Controleer uw email en wachtwoord of maak een account aan als u die nog niet heeft"), dismissButton: Alert.Button.default(Text("Oke"), action: {
                            print("hi")
                        }))
                    }
            }
        }
        
    }
    
    func startLogin() {
        let token : String = getTokenFromChain()
        if token != " " {
            authenticate()
        }
        loader.hide()
    }
    
    func login() async {
        do{
            loader.show()
            let result = try await apiLogin(email: email, password: password)
            if result != nil {
                menu = .home
            } else {
                showError = true
            }
        } catch let error {
            print(error)
        }
        loader.hide()
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We willen zeker weten dat jij het bent"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    menu = .home
                } else {
                    loader.show()
                    Task{
                        do{
                            _ = try await apiLogout()
                            deleteAllTokens()
                        } catch let error {
                            print(error)
                        }
                    }
                    loader.hide()
                }
            }
        } else {
            menu = .home
        }
    }
}
