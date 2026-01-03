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
    @Environment(\.openWindow) var openWindow
    var body: some View {
        Section {
            ForEach(Array(zip(eventData.eventsList, eventData.timesList)).indices, id: \.self) { index in
                Text("\(eventData.timesList[index]) - \(eventData.eventsList[index])")
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
                            let timeRange = "\(event.startDate!.formatted(date: .omitted, time: .shortened)) - \(event.endDate!.formatted(date: .omitted, time: .shortened))"
                            eventData.timesList.append(timeRange)
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
            Text("Next Up")
            Text("© 2026 Mark Howard")
            Text("Version - \(Bundle.main.releaseVersionNumber ?? "")")
            Text("Build - \(Bundle.main.buildVersionNumber ?? "")")
            Link("Portfolio", destination: URL(string: "https://markydoodled.com/")!)
            Link("GitHub Repo", destination: URL(string: "https://github.com/markydoodled/Next-Up")!)
            Button("Tip Jar") {
                openWindow(id: "tip-jar")
            }
            Button("Feedback") {
                SendEmail.send()
            }
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
        }
    }
}

extension Bundle {
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

class SendEmail: NSObject {
    static func send() {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["markhoward@markydoodled.com"]
        service.subject = "Next Up Feedback"
        service.perform(withItems: ["Please Fill Out All Relevant Sections:", "Report A Bug - ", "Rate The App - ", "Suggest An Improvement - "])
    }
}

#Preview {
    ContentView()
}
