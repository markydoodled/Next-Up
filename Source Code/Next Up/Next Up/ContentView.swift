//
//  ContentView.swift
//  Next Up
//
//  Created by Mark Howard on 11/04/2024.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @EnvironmentObject var eventData: EventData
    var body: some View {
        Section {
            ForEach(Array(zip(eventData.eventsList, eventData.timesList)), id: \.0) { index in
                Text("\(index.1) - \(index.0)")
            }
        } header: {
            Text("Happening Today")
        }
        Divider()
        Button(action: {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.ical") {
                NSWorkspace.shared.open(url)
            }
        }) {
            Text("Open Calendar")
        }
        Button(action: {
            eventData.eventsList = []
            eventData.timesList = []

            let store = EKEventStore()
            
            store.requestFullAccessToEvents { granted, error in
                if granted {
                    print("Access Granted")
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfDay = calendar.startOfDay(for: now)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    
                    let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
                    let events = store.events(matching: predicate)
                    
                    DispatchQueue.main.async {
                        for event in events {
                            print(event.title!)
                            print(event.startDate!)
                            eventData.eventsList.append(event.title!)
                            eventData.timesList.append(event.startDate!.formatted(date: .omitted, time: .shortened))
                        }
                        print("Events Today: \(eventData.eventsList.formatted())")
                        print("Times Today: \(eventData.timesList.formatted())")
                    }
                } else {
                    print(error ?? "Error")
                }
            }
        }) {
            Text("Refresh")
        }
        Menu("More...") {
            Text("Version - 1.1")
            Text("Build - 2")
            Button(action: {NSApplication.shared.terminate(self)}) {
                Text("Quit")
            }
        }
    }
}

#Preview {
    ContentView()
}
