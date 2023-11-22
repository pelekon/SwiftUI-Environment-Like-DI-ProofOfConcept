//
//  DependencyInjectionPlaygroundApp.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import SwiftUI
import DependencyInjection

@main
struct DependencyInjectionPlaygroundApp: App {
    init() {
        DependencyInjectionContainer.shared.register(with: TestObjectKey.self)
        DependencyInjectionContainer.shared.register(keyPath: \.optionalTest)
        DependencyInjectionContainer.shared.register(keyPath: \.optionalTest)
        DependencyInjectionContainer.shared.register(keyPath: \.optionalTest)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
