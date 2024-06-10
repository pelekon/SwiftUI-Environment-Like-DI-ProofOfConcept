//
//  MacroInvocationParser.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import Foundation
import SwiftSyntax

public struct MacroInvocationParser {
    public init() { }
    
    public func parse(from arguments: LabeledExprListSyntax) throws -> MacroData {
        var data = MacroData(typeName: "", mode: "", skipInAutoGen: false)
        
        try arguments.forEach {
            switch $0.label?.trimmed.text {
            case "for":
                data.typeName = findTypeName(in: $0)
            case "mode":
                data.mode = findMode(in: $0)
            case "keyName":
                data.keyName = findKeyName(in: $0)
            case "skipInAutoGen":
                data.skipInAutoGen = findSkipFlag(in: $0)
            default:
                throw ParserError.notHandledParam
            }
        }
        
        guard !data.typeName.isEmpty else {
            throw ParserError.missingTypeName
        }
        
        guard !data.mode.isEmpty else {
            throw ParserError.missingMode
        }
        
        return data
    }
    
    private func findTypeName(in syntax: LabeledExprSyntax) -> String {
        return syntax.expression
            .as(MemberAccessExprSyntax.self)?
            .base?.as(DeclReferenceExprSyntax.self)?
            .baseName.trimmed.text ?? ""
    }
    
    private func findMode(in syntax: LabeledExprSyntax) -> String {
        return syntax.expression
            .as(MemberAccessExprSyntax.self)?
            .declName.baseName.trimmed.text ?? ""
    }
    
    private func findKeyName(in syntax: LabeledExprSyntax) -> String? {
        guard let segments = syntax.expression.as(StringLiteralExprSyntax.self)?.segments,
              case .stringSegment(let literal) = segments.first else { return nil }
        
        return literal.content.trimmed.text
    }
    
    private func findSkipFlag(in syntax: LabeledExprSyntax) -> Bool {
        syntax.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true"
    }
}

extension MacroInvocationParser {
    public enum ParserError: Error {
        case notHandledParam
        case missingTypeName
        case missingMode
    }
}
