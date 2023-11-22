//
//  TestObjectKey.swift
//  DependencyInjectionPlayground
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation
import DependencyInjection

struct TestObjectKey: DependencyInjectionKey {
    let valueProvider: DependencyValueProvider<TestObject> = .created(TestObject.init)
}

//extension DependencyInjectionContainer {
//    var testObject: TestObject? {
//        get { self[TestObjectKey.self] }
//    }
//}
