import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct DependencyInjectionPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MakeInjectableMacro.self,
    ]
}
