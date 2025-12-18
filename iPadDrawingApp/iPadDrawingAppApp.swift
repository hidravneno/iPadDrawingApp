//
//  iPadDrawingAppApp.swift
//  iPadDrawingApp
//
//  Created by francisco eduardo aramburo reyes on 15/12/25.
//

import SwiftUI

@main
struct iPadDrawingAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            DrawingView()
        }
    }
}
