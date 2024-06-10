//
//  ContentView.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import SwiftUI
import DependencyInjection

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            viewModel.test()
        }
    }
}

extension ContentView {
    final class ViewModel: ObservableObject {
        @Injected(TestObjectKey.self) private var testObject1
        @Injected(\.testObject) private var testObject2
        @InjectedOptional(TestOptionalKey.self) private var optionalObject
//        @Injected(\.macroTest) private var macroObj
//        @Injected(\.macroTest) private var macroObj2
        
        func test() {
            testObject1.test()
            optionalObject?.test()
//            macroObj.test()
//            macroObj2.test()
        }
    }
}

#Preview {
    ContentView()
}
