//
//  LoadingView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    @EnvironmentObject var loader : LoaderInfo
    
    var content: () -> Content
    
    var body: some View {
        ZStack{

            VStack{
                self.content()
                    .disabled(loader.showLoader)
                    .blur(radius: loader.showLoader ? 3 : 0)
            }
                

            VStack {
                ProgressView()
                Text("Dit kan een moment duren")
                    .padding(.top, 20)
            }.padding(20)
            .background()
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .opacity(loader.showLoader ? 1 : 0)

        }.padding(.top, 0.1)
    }

}
