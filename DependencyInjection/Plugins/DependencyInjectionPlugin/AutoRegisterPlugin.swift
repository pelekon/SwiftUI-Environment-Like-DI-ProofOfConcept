//
//  AutoRegisterPlugin.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import PackagePlugin
// https://github.com/laevandus/SwiftExampleToomasKit/blob/main/Package.swift
@main
struct AutoRegisterPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: any PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        guard let sourceTarget = target as? SwiftSourceModuleTarget else {
            Diagnostics.error("Only source target is supported!")
            return []
        }
        
        let command = try prepareCommand(
            context: context,
            target: sourceTarget,
            directoryPath: context.pluginWorkDirectory
        )
        
        return [command]
    }
    
    fileprivate func prepareCommand<C: AnyPluginContext, T: AnyPluginTarget>(
        context: C, target: T, directoryPath: Path
    ) throws  -> PackagePlugin.Command {
        let toolPath = try context.tool(named: "AutoRegisterGenerator").path
        let inputFiles = target.sourceFiles.filter { $0.type == .source && $0.path.extension == "swift" }.map(\.path)
        let outputPath = directoryPath
            .appending("AutoRegisterGenerated")
            .appending("DependencyInjectionContainer+AutoRegister.generated.swift")
        
        return .buildCommand(
            displayName: "Generate auto register of injectable objects",
            executable: toolPath,
            arguments: [outputPath] + inputFiles.map(\.string),
            inputFiles: inputFiles,
            outputFiles: [outputPath]
            )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension AutoRegisterPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(
        context: XcodeProjectPlugin.XcodePluginContext,
        target: XcodeProjectPlugin.XcodeTarget
    ) throws -> [PackagePlugin.Command] {
        let command = try prepareCommand(
            context: context,
            target: target,
            directoryPath: context.pluginWorkDirectory
        )
        
        return [command]
    }
}
#endif
