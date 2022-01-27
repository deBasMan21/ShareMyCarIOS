//
//  CarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct CarView: View {
    @State var car : Car
    
    var body: some View {
        VStack{
            Image(car.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(car.name)
                .font(Font.headline.weight(.bold))
                .foregroundColor(.accentColor)
            
            Text(car.plate)
                .foregroundColor(.accentColor)
            
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color("Secondary"), lineWidth: 1)
            ).background(RoundedRectangle(cornerRadius: 40).fill(Color("Secondary")))
            
    }
}
