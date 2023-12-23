//
//  DependencyInjectionKey.swift
//  DependencyInjection
//
//  Created by Bartłomiej Bukowiecki on 22/11/2023.
//

import Foundation

public protocol DependencyInjectionKey {
    associatedtype Value
    
    init()
    
    var valueProvider: DependencyValueProvider<Value> { get }
}
