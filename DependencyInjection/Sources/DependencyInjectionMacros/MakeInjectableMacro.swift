//
//  MakeInjectableMacro.swift
//
//
//  Created by Bartłomiej Bukowiecki on 13/12/2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/
public struct MakeInjectableMacro: MemberMacro, ExtensionMacro {
    static let memberTypeNameSuffix = "InjectionKey"
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let typeName = try decratationTypeName(syntax: declaration)
        
        guard let arguments = node.arguments?._syntaxNode.as(LabeledExprListSyntax.self) else {
            throw MacroError.argumentListFailure
        }
        
        let children = arguments.children(viewMode: .sourceAccurate)
        
        guard children.count == 1 else {
            throw MacroError.incorrectArgsList(1, children.count)
        }
        
        guard let label = children.first?._syntaxNode.as(LabeledExprSyntax.self),
              let enumCaseExp = label.expression.as(MemberAccessExprSyntax.self) else {
            throw MacroError.incorrectArgType(0)
        }
        
        guard let mode = InjectionMode(rawValue: enumCaseExp.declName.baseName.text) else {
            throw MacroError.incorrectArgType(0)
        }
        
        let memberName = "\(typeName.text)\(memberTypeNameSuffix)"
        
        let keySyntax = try makeKeyDeclaration(for: memberName, parentTypeName: typeName, mode: mode)
        return [keySyntax]
    }
    
    public static func expansion(
      of node: AttributeSyntax,
      attachedTo declaration: some DeclGroupSyntax,
      providingExtensionsOf type: some TypeSyntaxProtocol,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let typeName = try decratationTypeName(syntax: declaration)

        guard let conformingType = protocols.first else {
            throw MacroError.macroMissingCoformingType
        }
        
        let memberName = "\(typeName.text)\(memberTypeNameSuffix)"
        
        let inheritanceSyntax = InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax([
            InheritedTypeSyntax(type: conformingType)
        ]))
        
        let keyPropertySyntax = try VariableDeclSyntax("static var injectionKey: \(raw: memberName)") {
            StmtSyntax("return \(raw: memberName)()")
        }
        
        let extensionSyntax = ExtensionDeclSyntax(extendedType: type, inheritanceClause: inheritanceSyntax) {
            keyPropertySyntax
        }
        
        return [extensionSyntax]
    }
    
    private static func decratationTypeName(syntax: DeclGroupSyntax) throws -> TokenSyntax {
        if let structSyntax = syntax.as(StructDeclSyntax.self) {
            return structSyntax.name
        } else if let classSyntax = syntax.as(ClassDeclSyntax.self) {
            return classSyntax.name
        }
        
        throw MacroError.notClassOrStruct
    }
    
    private static func makeKeyDeclaration(for name: String, parentTypeName: TokenSyntax,
                                           mode: InjectionMode) throws -> DeclSyntax {
        let inheritanceSyntax = InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax([
            InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "DependencyInjectionKey"))
        ]))
        let valueProviderPropertySyntax = VariableDeclSyntax(bindingSpecifier: .keyword(.let),
                                                             bindings: PatternBindingListSyntax([
                                                                makeVariableBinding(with: parentTypeName, for: mode)
                                                             ]))
        
        let structName = TokenSyntax(stringLiteral: name)
        let syntax = StructDeclSyntax(name: structName, inheritanceClause: inheritanceSyntax) {
            MemberBlockItemSyntax(decl: valueProviderPropertySyntax)
        }
        
        return DeclSyntax(syntax)
    }
    
    private static func makeVariableBinding(with type: TokenSyntax, 
                                            for mode: InjectionMode) -> PatternBindingSyntax {
        let valueSyntax = makeVariableValueSyntax(for: mode, with: type)
        let varTypeSyntax = TypeSyntax(stringLiteral: "DependencyValueProvider<\(type.text)>")
        
        return PatternBindingSyntax(pattern: IdentifierPatternSyntax(identifier: .identifier("valueProvider")),
                                    typeAnnotation: TypeAnnotationSyntax(colon: .colonToken(), type: varTypeSyntax),
                                    initializer: InitializerClauseSyntax(value: valueSyntax))
    }
    
    private static func makeVariableValueSyntax(for injectionMode: InjectionMode, with parentType: TokenSyntax) -> ExprSyntax {
        return switch injectionMode {
        case .singleton:
            ExprSyntax(stringLiteral: ".singleton(\(parentType.text)())")
        case .newObject:
            ExprSyntax(stringLiteral: ".created(\(parentType.text).init)")
        }
    }
}

extension MakeInjectableMacro {
    enum MacroError: Error, CustomStringConvertible {
        case notClassOrStruct
        case argumentListFailure
        case incorrectArgsList(Int, Int)
        case incorrectArgType(Int)
        case extensionAlreadyImplemented
        case macroMissingCoformingType
        case print(String)
        
        var description: String {
            switch self {
            case .notClassOrStruct:
                return "Macro is usable only on structs and classes."
            case .argumentListFailure:
                return "Failed to obtain argument list"
            case let .incorrectArgsList(expected, found):
                return "Incorrect arguments amount, expected: \(expected) got: \(found)"
            case let .incorrectArgType(position):
                return "Received argument of icorrect type at position \(position)"
            case .extensionAlreadyImplemented:
                return "Type already conforms to type InjectionKeyProvider."
            case .macroMissingCoformingType:
                return "Missing declaration of type to conform to."
            case let .print(desc):
                return desc
            }
        }
    }
    
    enum InjectionMode: String {
        case singleton
        case newObject
    }
}
