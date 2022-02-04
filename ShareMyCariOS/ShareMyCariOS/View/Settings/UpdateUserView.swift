//
//  UpdateUserView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 03/02/2022.
//

import SwiftUI

struct UpdateUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var loader : LoaderInfo
    
    @State var user : User
    @State var refresh: (() async -> Void)?
    
    var body: some View {
        Form{
            Section(header: Text("Naam:")){
                TextField("John Doe", text: $user.name)
            }
            
            Section(header: Text("Telefoonnummer:")){
                TextField("061234567", text: $user.phoneNumber)
            }
            
        }.navigationTitle("Account aanpassen")
            .navigationBarItems(leading: Button("Annuleren", action: {
                presentationMode.wrappedValue.dismiss()
            }).foregroundColor(.blue) ,trailing:
                Button("Account aanpassen", action: {
                    Task{
                        await updateUser()
                    }
                    presentationMode.wrappedValue.dismiss()
                }).foregroundColor(isValidUser() ? .blue : .accentColor)
                        .disabled(!isValidUser())
            )
    }
    
    func isValidUser() -> Bool {
        return !user.name.isEmpty && !user.email.isEmpty && !user.phoneNumber.isEmpty
    }
    
    func updateUser() async {
        loader.show()
        do{
            _ = try await apiUpdateUser(user: user)
            if refresh != nil {
                await refresh!()
            }
        } catch let error{
            print(error)
        }
        loader.hide()
    }
}
