import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct JSBridgeMacrosPlugin: CompilerPlugin {
  let providingMacros: [any Macro.Type] = [
    JSClassMacro.self,
    JSMethodMacro.self,
    JSEventMacro.self,
    CrispActionEventMacro.self,
  ]
}
