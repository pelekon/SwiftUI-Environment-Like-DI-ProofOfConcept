//
//  MacroTest.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 14/12/2023.
//

import Foundation
import DependencyInjection

//@MakeInjectable(.newObject)
//@TestPeer
final class MacroTest {
    func test() {
        print("I am object with auto generated injection")
    }
}

@TestMakeInjectable(for: MacroTest.self, mode: .singleton)
extension DependencyInjectionContainer { }

