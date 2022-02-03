//
//  LoadingView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 28/01/2022.
//

import SwiftUI

struct LoadingView<Content>: View where Content: View {
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        ZStack{

            VStack{
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
            }
                

            VStack {
                ProgressView()
                Text("Dit kan een moment duren")
                    .padding(.top, 20)
            }.padding(20)
            .background()
            .foregroundColor(Color.primary)
            .cornerRadius(20)
            .opacity(self.isShowing ? 1 : 0)

        }.padding(.top, 0.1)
    }

}
