//
//  LatteLensApp.swift
//  LatteLens
//
//  Created by 尾崎巧汰 on 2026/07/17.
//

import SwiftUI
import FirebaseCore

@main
struct LatteLensApp: App {
    @StateObject private var store = ArtworkStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
