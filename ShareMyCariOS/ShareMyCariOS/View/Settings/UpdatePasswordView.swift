//
//  UpdatePasswordView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 10/02/2022.
//

import SwiftUI

struct UpdatePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loader : LoaderInfo
    
    @State var oldPassword = ""
    @State var newPassword = ""
    @State var newPasswordConfirm = ""
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("Oude wachtwoord:")){
                    SecureField("Oude wachtwoord", text: $oldPassword)
                }
                
                Section(header: Text("Nieuwe wachtwoord:")){
                    SecureField("Nieuwe wachtwoord", text: $newPassword)
                }
                
                Section(header: Text("Nieuwe wachtwoord bevestigen:")){
                    SecureField("Nieuwe wachtwoord", text: $newPasswordConfirm)
                }
            }.navigationTitle("Wachtwoord bijwerken")
                .navigationBarItems(leading: Button("Annuleren", action: {
                    presentationMode.wrappedValue.dismiss()
                }).foregroundColor(.blue),trailing: Button("Bijwerken", action: {
                    Task{
                        await updatePassword()
                    }
                }).foregroundColor(isValid() ? .blue : .gray).disabled(!isValid()))
        }
    }
    
    func isValid() -> Bool {
        return newPassword == newPasswordConfirm
    }
    
    func updatePassword() async {
        loader.show()
        do {
            let result = try await apiUpdatePassword(oldPassword: oldPassword, newPassword: newPassword)
            
            if result != nil {
                await MainActor.run{
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                print("something went wrong")
            }
            
            
        } catch let error{
            print(error)
        }
        loader.hide()
    }
}
