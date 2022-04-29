//
//  FutureWealthApp.swift
//  FutureWealth
//
//  Created by Ttaa on 4/26/22.
//

import SwiftUI

@main
struct FutureWealthApp: App {
    
    let logController = LogController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomepageView()
                .environment(\.managedObjectContext, logController.container.viewContext)
        }
        .onChange(of: scenePhase){ (newScenePhase) in
            switch newScenePhase{
            case .background:
                print("Scene in Bg")
                logController.save()
            case .inactive:
                print("Scene inactive")
            case .active:
                print("Scene active")
            @unknown default:
                print("Scene is unknown")
            }
        }
    }
}
