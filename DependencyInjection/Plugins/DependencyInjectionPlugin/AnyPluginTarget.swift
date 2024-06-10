//
//  AnyPluginTarget.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import Foundation
import PackagePlugin

protocol AnyPluginTarget { 
    var sourceFiles: FileList { get }
}

extension SwiftSourceModuleTarget: AnyPluginTarget { }

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodeTarget: AnyPluginTarget {
    var sourceFiles: PackagePlugin.FileList {
        self.inputFiles
    }
}
#endif
