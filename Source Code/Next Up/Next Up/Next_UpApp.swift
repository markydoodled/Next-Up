//
//  Next_UpApp.swift
//  Next Up
//
//  Created by Mark Howard on 11/04/2024.
//

import SwiftUI

@main
struct Next_UpApp: App {
    var body: some Scene {
        MenuBarExtra("Next Up", systemImage: "calendar.day.timeline.left") {
            ContentView()
        }
        .menuBarExtraStyle(.menu)
    }
}
