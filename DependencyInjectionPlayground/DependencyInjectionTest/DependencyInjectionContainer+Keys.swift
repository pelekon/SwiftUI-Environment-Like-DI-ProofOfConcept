//
//  DependencyInjectionContainer+Keys.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation
import DependencyInjection

extension DependencyInjectionContainer {
    var testObject: TestObjectKey.Type { TestObjectKey.self }
    var optionalTest: TestOptionalKey.Type { TestOptionalKey.self }
}
