//
//  AnyPluginContext.swift
//
//
//  Created by Bartłomiej Bukowiecki on 09/06/2024.
//

import Foundation
import PackagePlugin

protocol AnyPluginContext {
    func tool(named name: String) throws -> PackagePlugin.PluginContext.Tool
}

extension PluginContext: AnyPluginContext { }

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension XcodePluginContext: AnyPluginContext { }
#endif
