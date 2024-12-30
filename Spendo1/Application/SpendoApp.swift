//
//  SpendoApp.swift
//  Spendo

import SwiftUI
import GoogleSignIn

struct SpendoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
