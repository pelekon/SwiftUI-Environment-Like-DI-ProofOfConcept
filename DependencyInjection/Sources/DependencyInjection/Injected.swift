//
//  InjectedWrapper.swift
//  DependencyInjection
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation

@propertyWrapper
public struct Injected<Value> {
    private let value: Value
    private let container: DependencyInjectionContainer
    
    public init<T>(_ key: T.Type,
                   container: DependencyInjectionContainer = .shared) where T: DependencyInjectionKey, T.Value == Value {
        self.value = container[key]!
        self.container = container
    }
    
    public init<T: DependencyInjectionKey>(_ keyPath: KeyPath<DependencyInjectionContainer, T.Type>,
                                           canRegister: Bool = false,
                                           container: DependencyInjectionContainer = .shared) where T.Value == Value {
        let keyType = container[keyPath: keyPath]
        if canRegister {
            self.value = container.getExistingOrAfterRegister(keyType)!
        } else {
            self.value = container[keyType]!
        }
        self.container = container
    }
    
    public init<T: Injectable>(_ objectType: T.Type,
                               container: DependencyInjectionContainer = .shared) where T.KeyType.Value == Value {
        self.value = container[T.self]
        self.container = container
    }
    
    public var wrappedValue: Value { value }
}
