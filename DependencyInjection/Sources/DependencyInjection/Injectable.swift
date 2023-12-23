//
//  Injectable.swift
//  
//
//  Created by Bartłomiej Bukowiecki on 14/12/2023.
//

import Foundation

public protocol Injectable {
    associatedtype KeyType: DependencyInjectionKey
    
    static var injectionKey: KeyType { get }
}
