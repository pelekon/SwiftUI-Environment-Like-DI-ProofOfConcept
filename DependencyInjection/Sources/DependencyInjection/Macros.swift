public enum InjectionMode {
    case singleton
    case newObject
}

@attached(member, names: arbitrary)
@attached(extension, conformances: Injectable, names: named(injectionKey))
public macro MakeInjectable(_ mode: InjectionMode) = #externalMacro(module: "Macros", type: "MakeInjectableMacro")
