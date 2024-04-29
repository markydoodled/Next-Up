//
//  ContentView.swift
//  Next Up
//
//  Created by Mark Howard on 11/04/2024.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State private var eventsList: [String] = []
    @State private var timesList: [String] = []
    var body: some View {
        Section {
            ForEach(eventsList, id: \.count) { event in
                HStack {
                    Text("\(timesList.formatted()) - \(eventsList.formatted())")
                }
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
        Menu("More...") {
            Text("Version - 1.0")
            Text("Build - 2")
            Button(action: {NSApplication.shared.terminate(self)}) {
                Text("Quit")
            }
        }
        Button(action: {
            eventsList = []
            timesList = []

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
                    
                    for event in events {
                        print(event.title!)
                        print(event.startDate!)
                        eventsList.append(event.title!)
                        timesList.append(event.startDate!.formatted(date: .omitted, time: .shortened))
                    }
                    print("Events Today: \(eventsList.formatted())")
                    print("Times Today: \(timesList.formatted())")
                } else {
                    print(error ?? "Error")
                }
            }
        }) {
            Text("Refresh")
        }
    }
}

#Preview {
    ContentView()
}
