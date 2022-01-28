//
//  RideView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct RideView: View {
    @State var ride : Ride
    
    var body: some View {
        VStack{
            Text(ride.name)
                .font(Font.headline.weight(.bold))
                .foregroundColor(.accentColor)
            
            Text(ride.destination?.name ?? "No destination")
                .foregroundColor(.accentColor)
            
            Text(ride.user?.name ?? "No user")
                .foregroundColor(.accentColor)
            
            Text(Date.fromDateString(input: ride.beginDateTime).formatted())
                .foregroundColor(.accentColor)
            
        }.padding()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("Secondary"), lineWidth: 1)
            ).background(RoundedRectangle(cornerRadius: 20).fill(Color("Secondary")))
    }
}
