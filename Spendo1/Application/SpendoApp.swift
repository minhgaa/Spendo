//
//  SpendoApp.swift
//  Spendo

import SwiftUI
import GoogleSignIn
@main

struct SpendoApp1: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
                .onAppear {
                          GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                          }
                        }
                .hideNavigationBar()
                .navigationBarBackButtonHidden(true)
        }
    }
}
