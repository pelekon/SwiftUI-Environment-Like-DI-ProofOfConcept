//
//  DependencyValueProvider.swift
//  DependencyInjection
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation

public enum DependencyValueProvider<Value> {
    public typealias Fabric = () -> Value
    public typealias Resolver = (DependencyInjectionContainer) -> Value
    
    case singleton(Value)
    case created(Fabric)
    case resolved(Resolver)
}
