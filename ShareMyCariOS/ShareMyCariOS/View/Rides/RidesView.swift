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
    @Binding var user : User
    @Binding var showLoader : Bool
    
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
        showLoader = true
        events = []
        do{
            var rides : [Ride] = []
            for car in user.cars! {
                let ridesresult = try await apiGetRidesForCar(carId: car.id)
                if ridesresult != nil{
                    rides.append(contentsOf: ridesresult!)
                }
            }
            
            for ride in rides {
                var event : Event = Event(ID: String(ride.id))
                event.start = Date.fromDateString(input: ride.beginDateTime)
                event.end = Date.fromDateString(input: ride.endDateTime)
                event.text = "\(ride.name)\n\(ride.user?.name ?? "Not found")\n\(ride.car?.name ?? "Not found")\n\(ride.destination?.name ?? "Not found")"
                event.color = Event.Color(.gray)
                events.append(event)
            }
            
            if user.showEventsInCalendar {
                let store = EKEventStore()

                let calendars = store.calendars(for: .event)

                for calendar in calendars {
                    let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
                    let oneMonthAfter = Date(timeIntervalSinceNow: 30*24*3600)
                    let predicate =  store.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
                    
                    let eventsFromCalendar = store.events(matching: predicate)
                    let color = calendar.cgColor!
                    
                    for event in eventsFromCalendar {
                        var newEvent : Event = Event(ID: event.eventIdentifier)
                        newEvent.start = event.startDate
                        newEvent.end = event.endDate
                        
                        var eventDescription : String = "\(event.title ?? "Not found")"
                        if event.location != nil {
                            eventDescription = eventDescription + "\n\(event.location!)"
                        }
                        if event.notes != nil {
                            eventDescription = eventDescription + "\n\(event.notes!)"
                        }
                        
                        newEvent.text = eventDescription
                        newEvent.isAllDay = event.isAllDay
                        newEvent.color = Event.Color(UIColor(cgColor: color))
                        
                        events.append(newEvent)
                    }
                }
            }
        } catch let error{
            print(error)
        }
        showLoader = false
    }
    
}
