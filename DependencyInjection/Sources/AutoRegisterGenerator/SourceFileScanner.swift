//
//  SourceFileScanner.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import Foundation
import SwiftSyntax
import SwiftParser
import PluginCore

@available(iOS 15, macOS 12, *)
struct SourceFileScanner {
    let filePath: String
    
    func scan() async throws -> [String] {
        let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
        let sourceFileAST = Parser.parse(source: fileContent)
        
        let validDecls = sourceFileAST.statements
            .compactMap { $0.item.as(ExtensionDeclSyntax.self) }
        
        let macroUsingSyntax = validDecls
            .flatMap(\.attributes)
            .compactMap { $0.as(AttributeSyntax.self) }
            .filter { $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "TestMakeInjectable" }
        
        return try macroUsingSyntax.compactMap { try makeKeyPathFromMacroSyntax(macroSyntax: $0) }
    }
    
    private func makeKeyPathFromMacroSyntax(macroSyntax: AttributeSyntax) throws -> String? {
        guard let argumentsList = macroSyntax.arguments?.as(LabeledExprListSyntax.self) else { return nil }
        
        let parser = MacroInvocationParser()
        let data = try parser.parse(from: argumentsList)
        
        guard !data.skipInAutoGen else { return nil }
        
        return "\\." + data.keyVariableName
    }
}
