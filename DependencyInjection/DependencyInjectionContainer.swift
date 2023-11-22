//
//  DependencyInjectionContainer.swift
//  DependencyInjection
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation

public final class DependencyInjectionContainer {
    typealias TypeIdentifier = ObjectIdentifier
    
    public static let shared = DependencyInjectionContainer()
    private var container: Dictionary<TypeIdentifier, Any> = [:]
    
    public init() { }
    
    public subscript<T: DependencyInjectionKey>(_ key: T.Type) -> T.Value? {
        let objectId = ObjectIdentifier(key)
        guard let provider = container[objectId] as? DependencyValueProvider<T.Value> else { return nil }
        
        switch provider {
        case .singleton(let value):
            return value
        case .created(let factory):
            return factory()
        case .resolved(let resolver):
            return resolver(self)
        }
    }
    
    public func register<T: DependencyInjectionKey>(with key: T.Type) {
        let objectId = ObjectIdentifier(key)
        container[objectId] = key.init().valueProvider
    }
    
    public func register<T: DependencyInjectionKey>(keyPath: KeyPath<DependencyInjectionContainer, T.Type>) {
        let key = self[keyPath: keyPath]
        let objectId = ObjectIdentifier(key)
        container[objectId] = key.init().valueProvider
    }
}
