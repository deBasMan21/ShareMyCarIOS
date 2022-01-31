//
//  RidesCalendarView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 31/01/2022.
//

import SwiftUI

struct RidesCalendarView: View {
    var body: some View {
        VStack{
            CalendarDisplayView(events: $events)
                .onAppear(perform: {
                    Task {
                        await createEvents()
                    }
                })
        }.overlay(
            GeometryReader { geometry in
                Text("HI").onAppear(perform: {
                    size = CGRect(origin: CGPoint(x: 0, y: 0), size: geometry.size)
                })
            })
    }
}
