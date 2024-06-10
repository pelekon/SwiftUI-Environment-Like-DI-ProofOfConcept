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

struct IgnoredObj { }

struct AnotherObj { }

@TestMakeInjectable(for: MacroTest.self, mode: .singleton)
extension DependencyInjectionContainer { }

@TestMakeInjectable(for: IgnoredObj.self, mode: .singleton, skipInAutoGen: true)
extension DependencyInjectionContainer { }

@TestMakeInjectable(for: AnotherObj.self, mode: .singleton, keyName: "testKey")
extension DependencyInjectionContainer { }
