public enum InjectionMode {
    case singleton
    case newObject
}

@attached(member, names: arbitrary)
@attached(extension, conformances: Injectable, names: named(injectionKey))
public macro MakeInjectable(_ mode: InjectionMode) = #externalMacro(module: "DependencyInjectionMacros", type: "MakeInjectableMacro")

@attached(member, names: arbitrary)
public macro TestMakeInjectable<T>(
    for type: T.Type, 
    mode: InjectionMode,
    keyName: String? = nil,
    skipInAutoGen: Bool = false
) = #externalMacro(module: "DependencyInjectionMacros", type: "TempMakeInjectableMacro")
