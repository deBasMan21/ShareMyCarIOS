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
    @EnvironmentObject var loader : LoaderInfo
    @State var events: [Event] = []
    @State var size : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    @Binding var user : User
    @State var showNewRide : Bool = false
    @State var showRideDetail : Bool = false
    @State var lastRide : Ride = Ride(id: 0, name: "", beginDateTime: "", endDateTime: "", reservationDateTime: "", lastChangeDateTime: "")
    
    var body: some View {
        GeometryReader { geometry in
            
            
            if showRideDetail {
                NavigationLink(destination: RideDetailView(ride: lastRide), isActive: $showRideDetail){
                    Text("")
                }
            }else{
                VStack{
                    if size.width > 0 {
                        CalendarDisplayView(events: $events, size : size, showDetail: $showRideDetail, ride: $lastRide)
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
                                Text("Loading data...").onAppear(perform: {
                                    size = CGRect(origin: CGPoint(x: 0, y: 0), size: geometry.size)
                                })
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    
                }
            }
            
        }.navigationTitle("Ritten")
            .toolbar(content: {
                Image("plus").onTapGesture {
                    showNewRide = true
                }
            }).sheet(isPresented: $showNewRide){
                CreateRideView(showPopUp: $showNewRide, car: nil, refresh: createEvents, user: $user)
            }
            
    }
    
    func createEvents() async {
        loader.show()
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
                event.data = ride
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
        loader.hide()
    }
    
}
