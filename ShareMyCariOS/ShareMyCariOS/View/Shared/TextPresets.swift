//
//  TextPresets.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI

struct TitleText: View {
    var text : String
    
    var body: some View {
        Text(text)
            .font(.system(size: 30, weight: .bold))
    }
}

struct SubTitleText: View {
    var text : String
    
    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .bold))
    }
}


