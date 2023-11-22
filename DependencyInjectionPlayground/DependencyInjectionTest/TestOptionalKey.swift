//
//  TestOptionalKey.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation
import DependencyInjection

struct TestOptionalKey: DependencyInjectionKey {
    let valueProvider: DependencyValueProvider<TestOptionalObj> = .created(TestOptionalObj.init)
}
