//
//  MacroInvocationParser+MacroData.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import Foundation

extension MacroInvocationParser {
    public struct MacroData {
        public internal(set) var typeName: String
        public internal(set) var mode: String
        public internal(set) var keyName: String?
        public internal(set) var skipInAutoGen: Bool
        
        public var keyVariableName: String {
            if let keyName {
                return keyName
            }
            
            var keyPropertyName = typeName
            keyPropertyName.replaceSubrange(
                keyPropertyName.startIndex...keyPropertyName.startIndex,
                with: keyPropertyName[keyPropertyName.startIndex].lowercased()
            )
            
            return keyPropertyName
        }
    }
}
