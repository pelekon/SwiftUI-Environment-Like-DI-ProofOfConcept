//
//  TempMakeInjectableMacro.swift
//
//
//  Created by Bartłomiej Bukowiecki on 08/06/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics
import PluginCore

struct UsableOnlyOnExtensionMessage: DiagnosticMessage {
    let message = "Macro is usable only on extension for DependencyInjectionContainer"
    let diagnosticID = MessageID(domain: "TempMakeInjectableMacro", id: "1")
    let severity = DiagnosticSeverity.error
}

struct DebugPrintMessage: DiagnosticMessage {
    let message: String
    let diagnosticID = MessageID(domain: "TempMakeInjectableMacro", id: "2")
    let severity = DiagnosticSeverity.error
    
    init(message: String) {
        self.message = message
    }
}

public struct TempMakeInjectableMacro: MemberMacro {
    static let keyTypeSuffix = "InjectionKey"
    
    public static func expansion(
      of node: AttributeSyntax,
      providingMembersOf declaration: some DeclGroupSyntax,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let extensionDecl = declaration.as(ExtensionDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: UsableOnlyOnExtensionMessage())
            ])
        }
        
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Missing argument!"))
            ])
        }
        
        let parser = MacroInvocationParser()
        let data = try parser.parse(from: arguments)
        
        let typeName = data.typeName
        
        guard let mode = InjectionMode(rawValue: data.mode) else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Failed to determine injection mode from: \(data.mode)"))
            ])
        }
        
        let keyTypeName = TokenSyntax(stringLiteral: "\(typeName)\(keyTypeSuffix)")
        
        let keyDecl = try StructDeclSyntax("struct \(raw: keyTypeName): DependencyInjectionKey") {
            try VariableDeclSyntax("var valueProvider: DependencyValueProvider<\(raw: typeName)>") {
                StmtSyntax("return \(raw: mode.makeProviderValue(with: typeName))")
            }
        }
        
        let keyPropertyNameSyntax = data.keyVariableName
        
        let containerKeyPathDecl = try VariableDeclSyntax("var \(raw: keyPropertyNameSyntax): \(keyTypeName).Type") {
            StmtSyntax("return \(raw: keyTypeName).self")
        }
        
        return [keyDecl.cast(DeclSyntax.self), containerKeyPathDecl.cast(DeclSyntax.self)]
    }
}

extension TempMakeInjectableMacro {
    enum InjectionMode: String {
        case singleton
        case newObject
        
        func makeProviderValue(with typeName: String) -> String {
            switch self {
            case .singleton: ".singleton(\(typeName)())"
            case .newObject: ".created(\(typeName).init)"
            }
        }
    }
}
