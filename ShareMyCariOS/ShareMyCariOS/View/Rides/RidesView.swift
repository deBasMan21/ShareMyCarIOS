//
//  RidesView.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 27/01/2022.
//

import SwiftUI
import KVKCalendar
import EventKit

struct RidesView: View {
    @State var events: [Event] = []
    @State var size : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State var colors : [Color] = [.blue, .red, .orange, .yellow, .green, .gray]
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if size.width > 0 {
                    CalendarDisplayView(events: $events, size : size)
                        .onAppear(perform: {
                            Task {
                                await createEvents()
                            }
                        })
                } else{
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text("HI").onAppear(perform: {
                                size = CGRect(origin: CGPoint(x: 0, y: 0), size: geometry.size)
                            })
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
            }
        }.navigationTitle("Ritten")
    }
    
    func createEvents() async {
        do{
            var index = 0
            var colorPerson : [Int : Color] = [-1: .black]
            let result = try await apiGetUser()
            if result != nil{
                var rides : [Ride] = []
                for car in result!.cars! {
                    let ridesresult = try await apiGetRidesForCar(carId: car.id)
                    if ridesresult != nil{
                        rides.append(contentsOf: ridesresult!)
                    }
                }
                
                for ride in rides {
                    var color : Color? = colorPerson[ride.user?.id ?? -1]
                    if  color == nil {
                        colorPerson[ride.user!.id] = colors[index]
                        color = colors[index]
                        index += 1
                        if index > colors.count {
                            index = 0
                        }
                    }
                    
                    var event : Event = Event(ID: String(ride.id))
                    event.start = Date.fromDateString(input: ride.beginDateTime)
                    event.end = Date.fromDateString(input: ride.endDateTime)
                    event.text = "\(ride.name)\n\(ride.user?.name ?? "Not found")\n\(ride.car?.name ?? "Not found")\n\(ride.destination?.name ?? "Not found")"
                    event.color = Event.Color(UIColor(color!))
                    event.textForList = "blabla"
                    event.textForMonth = "month"
                    events.append(event)
                }
            }
            
        } catch let error{
            print(error)
        }
    }
}
