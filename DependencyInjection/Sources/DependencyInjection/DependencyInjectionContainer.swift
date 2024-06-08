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
        
        return objectFromProvider(provider)
    }
    
    public subscript<T: Injectable>(_ objectType: T.Type) -> T.KeyType.Value {
        let objectId = ObjectIdentifier(T.KeyType.self)
        
        var provider: DependencyValueProvider<T.KeyType.Value>! = container[objectId] as? DependencyValueProvider<T.KeyType.Value>
        let key = objectType.injectionKey
        
        if provider == nil {
            container[objectId] = key.valueProvider
            provider = key.valueProvider
        }
        
        return objectFromProvider(provider)
    }
    
    public func getExistingOrAfterRegister<T: DependencyInjectionKey>(_ key: T.Type) -> T.Value? {
        let objectId = ObjectIdentifier(key)
        
        var provider = container[objectId] as? DependencyValueProvider<T.Value>
        if provider == nil {
            register(with: key)
            provider = container[objectId] as? DependencyValueProvider<T.Value>
        }
        
        guard let provider else { return nil }
        
        return objectFromProvider(provider)
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
    
    private func objectFromProvider<T>(_ provider: DependencyValueProvider<T>) -> T {
        return switch provider {
        case .singleton(let value): value
        case .created(let fabric): fabric()
        case .resolved(let resolver): resolver(self)
        }
    }
}
