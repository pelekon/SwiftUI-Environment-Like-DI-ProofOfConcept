// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "DependencyInjection",
    platforms: [
        .iOS(.v14), .macCatalyst(.v13), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        // .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        .package(url: "https://github.com/sjavora/swift-syntax-xcframeworks.git", from: "509.0.2")
    ],
    targets: [
        .macro(
            name: "DependencyInjectionMacros",
            dependencies: [
                // .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                // .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
                .product(name: "SwiftSyntaxWrapper", package: "swift-syntax-xcframeworks")
            ]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "DependencyInjection", dependencies: ["DependencyInjectionMacros"]),
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
