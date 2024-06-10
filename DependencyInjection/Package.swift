// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let packageDependencies: [Package.Dependency]
if Context.environment["DI_MACRO_COCOAPODS_BUILD"] != nil {
    packageDependencies = [
        .package(url: "https://github.com/sjavora/swift-syntax-xcframeworks.git", from: "509.0.2")
    ]
} else {
    packageDependencies = [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ]
}

let macroDependencies: [Target.Dependency]
if Context.environment["DI_MACRO_COCOAPODS_BUILD"] != nil {
    macroDependencies = [
        .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
    ]
} else {
    macroDependencies = [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
    ]
}
let targetsSyntaxDependencies: [Target.Dependency]
if Context.environment["DI_MACRO_COCOAPODS_BUILD"] != nil {
    targetsSyntaxDependencies = [
        .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
    ]
} else {
    targetsSyntaxDependencies = [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax")
    ]
}

let package = Package(
    name: "DependencyInjection",
    platforms: [
        .iOS(.v14), .macCatalyst(.v13), .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]),
        .plugin(name: "DependencyInjectionPlugin", targets: ["DependencyInjectionPlugin"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "PluginCore",
            dependencies: targetsSyntaxDependencies
        ),
        .macro(
            name: "DependencyInjectionMacros",
            dependencies: ["PluginCore"] + macroDependencies
        ),
        .executableTarget(
            name: "AutoRegisterGenerator",
            dependencies: ["PluginCore"] + targetsSyntaxDependencies
        ),
        .plugin(
            name: "DependencyInjectionPlugin",
            capability: .buildTool(),
            dependencies: ["AutoRegisterGenerator"]
        ),
        .target(
            name: "DependencyInjection",
            dependencies: ["DependencyInjectionMacros"]
        ),
    ]
)

if Context.environment["DI_MACRO_COCOAPODS_BUILD"] != nil {
    package.products.removeAll()
    package.products.append(.executable(name: "DependencyInjectionMacros", targets: ["DependencyInjectionMacros"]))
    
    package.targets = package.targets.compactMap { target in
        guard target.type == .macro else { return nil }

        return .executableTarget(
            name: target.name,
            dependencies: target.dependencies,
            path: target.path,
            exclude: target.exclude,
            sources: target.sources,
            resources: target.resources,
            publicHeadersPath: target.publicHeadersPath,
            cSettings: target.cSettings,
            cxxSettings: target.cxxSettings,
            swiftSettings: target.swiftSettings,
            linkerSettings: target.linkerSettings,
            plugins: target.plugins
        )
    }
}
