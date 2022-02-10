//
//  _12Meldingen.swift
//  112Meldingen
//
//  Created by Bas Buijsen on 09/02/2022.
//

import WidgetKit
import SwiftUI
import Intents
import SWXMLHash

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> Announcement {
        Announcement(date: Date(), announcements: [AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal")])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Announcement) -> ()) {
        let entry = Announcement(date: Date(), announcements: [AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal")])
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Announcement] = []
        
        Task{
            do{
                let value = try await apiCall()
                print(value)
            }catch let error {
                print(error)
            }
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Announcement(date: entryDate, announcements: [AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"),AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal"), AnnouncementItem(title: "A1 Roosendaal", description: "Ambulance met spoed naar roosendaal")])
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct Announcement: TimelineEntry {
    var date: Date
    var announcements : [AnnouncementItem]
}

struct AnnouncementItem : Identifiable {
    let id = UUID()
    let title: String
    let description : String
}

struct _12MeldingenEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack{
            ForEach(entry.announcements){ item in
                VStack{
                    Text(item.title)
                    Text(item.description)
                }.padding()
            }
        }
        
    }
}

@main
struct _12Meldingen: Widget {
    let kind: String = "112Meldingen"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            _12MeldingenEntryView(entry: entry)
        }
        .configurationDisplayName("112Meldingen")
        .description("This widget shows all 112 announcements in the brabant area")
    }
}


func apiCall() async throws -> String {
    let url = URL(string: "https://www.alarmeringen.nl/feeds/region/midden-en-west-brabant.rss")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let(data, _) = try await URLSession.shared.data(for: request)
    
    let xml = XMLHash.parse(String(data: data, encoding: .utf8) ?? "")
    
    print(xml)
    return String(data: data, encoding: .utf8) ?? ""
}
