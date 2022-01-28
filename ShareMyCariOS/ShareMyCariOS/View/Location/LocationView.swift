//
//  LocationView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct LocationView: View {
    @State var location : Location
    
    @State private var gridItems = [GridItem(.fixed(100), alignment: .topLeading), GridItem(.fixed(150), alignment: .topLeading)]
    
    var body: some View {
        VStack{
            SubTitleText(text: location.name)
            
            LazyVGrid(columns: gridItems, alignment: .leading, spacing: 10){
                Text("Adres:")
                Text(location.address)
                Text("Postcode:")
                Text(location.zipCode)
                Text("Stad:")
                Text(location.city)
            }.padding(.horizontal)
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("Secondary"), lineWidth: 1)
            ).background(RoundedRectangle(cornerRadius: 20).fill(Color("Secondary")))
    }
}
