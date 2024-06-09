//
//  Next_UpApp.swift
//  Next Up
//
//  Created by Mark Howard on 11/04/2024.
//

import SwiftUI
import EventKit

@main
struct Next_UpApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var eventData: EventData
    
    init() {
        eventData = _appDelegate.wrappedValue.eventData
    }
    
    var body: some Scene {
        MenuBarExtra("Next Up", systemImage: "calendar.day.timeline.left") {
            ContentView()
                .environmentObject(eventData)
        }
        .menuBarExtraStyle(.menu)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let eventData = EventData()
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Launched")
        
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
                        self.eventData.eventsList.append(event.title!)
                        let timeRange = "\(event.startDate!.formatted(date: .omitted, time: .shortened)) - \(event.endDate!.formatted(date: .omitted, time: .shortened))"
                        self.eventData.timesList.append(timeRange)
                    }
                    print("Events Today: \(self.eventData.eventsList.formatted())")
                    print("Times Today: \(self.eventData.timesList.formatted())")
                }
            } else {
                print(error ?? "Error")
            }
        }
        
        NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { _ in
            print("Day Changed")
            
            self.eventData.eventsList = []
            self.eventData.timesList = []
            
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
                        self.eventData.eventsList.append(event.title!)
                        let timeRange = "\(event.startDate!.formatted(date: .omitted, time: .shortened)) - \(event.endDate!.formatted(date: .omitted, time: .shortened))"
                        self.eventData.timesList.append(timeRange)
                    }
                    print("Events Today: \(self.eventData.eventsList.formatted())")
                    print("Times Today: \(self.eventData.timesList.formatted())")
                } else {
                    print(error ?? "Error")
                }
            }
        }
    }
}

class EventData: ObservableObject {
    @Published var eventsList: [String] = []
    @Published var timesList: [String] = []
}
