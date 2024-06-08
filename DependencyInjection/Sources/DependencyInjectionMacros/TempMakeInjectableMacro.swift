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
import Darwin

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

struct TempMakeInjectableMacro: MemberMacro {
    static let keyTypeSuffix = "InjectionKey"
    
    static func expansion(
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
        
        guard arguments.count >= 2 else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Missing required arguments!"))
            ])
        }
        
        guard let typeExp = arguments.first?.expression.as(MemberAccessExprSyntax.self),
              let modeExp = arguments[arguments.index(arguments.startIndex, offsetBy: 1)].expression.as(MemberAccessExprSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Failed to obtain arguments declaration! ArgsCount: \(arguments.count) Arguments: \(arguments)"))
            ])
        }
        
        guard let typeName = typeExp.base?.as(DeclReferenceExprSyntax.self)?.baseName.trimmed.text else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Failed to obtain type name from: \(typeExp)"))
            ])
        }
        
        guard let mode = InjectionMode(rawValue: modeExp.declName.baseName.trimmed.text) else {
            throw DiagnosticsError(diagnostics: [
                .init(node: declaration, message: DebugPrintMessage(message: "Failed to determine injection mode from: \(modeExp.declName.baseName.trimmed)"))
            ])
        }
        
        let keyTypeName = TokenSyntax(stringLiteral: "\(typeName)\(keyTypeSuffix)")
        
        let keyDecl = try StructDeclSyntax("struct \(raw: keyTypeName): DependencyInjectionKey") {
            try VariableDeclSyntax("var valueProvider: DependencyValueProvider<\(raw: typeName)>") {
                StmtSyntax("return \(raw: mode.makeProviderValue(with: typeName))")
            }
        }
        
        let keyPropertyNameSyntax = try makeKeyPropertyName(typeName: typeName, argumentsSyntax: arguments)
        
        let containerKeyPathDecl = try VariableDeclSyntax("var \(raw: keyPropertyNameSyntax): \(keyTypeName).Type") {
            StmtSyntax("return \(raw: keyTypeName).self")
        }
        
        return [keyDecl.cast(DeclSyntax.self), containerKeyPathDecl.cast(DeclSyntax.self)]
    }
    
    private static func makeKeyPropertyName(typeName: String, argumentsSyntax: LabeledExprListSyntax) throws -> TokenSyntax {
        func makeDefaultName(typeName: String) -> TokenSyntax {
            var keyPropertyName = typeName
            keyPropertyName.replaceSubrange(
                keyPropertyName.startIndex...keyPropertyName.startIndex,
                with: keyPropertyName[keyPropertyName.startIndex].lowercased()
            )
            
            return TokenSyntax(stringLiteral: "\(keyPropertyName)")
        }
        
        guard argumentsSyntax.count == 3 else {
            return makeDefaultName(typeName: typeName)
        }
        
        let nameExpr = argumentsSyntax[argumentsSyntax.index(argumentsSyntax.startIndex, offsetBy: 2)].expression
        
        guard let stringExprSegments = nameExpr.as(StringLiteralExprSyntax.self)?.segments,
              case .stringSegment(let literal) = stringExprSegments.first else {
            return makeDefaultName(typeName: typeName)
        }
        
        return literal.content
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
