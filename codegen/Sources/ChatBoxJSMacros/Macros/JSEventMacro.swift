import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `@JSEvent` is `@attached(body)`. Synthesizes a body that registers the
/// handler with `self.events` on a channel whose name matches the function's.
package struct JSEventMacro: BodyMacro {
  package static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext,
  ) throws -> [CodeBlockItemSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      context.diagnose(Diagnostic(node: node, message: JSEventDiagnostic.notAFunc))
      return []
    }

    let channel = funcDecl.name.text
    let handlerName = self.handlerParamName(of: funcDecl) ?? "handler"

    return [
      """
      self.events.register(\(literal: channel), JSEventHandler(\(raw: handlerName)))
      """,
    ]
  }

  /// Returns the in-scope identifier for the handler closure (uses the
  /// internal name when present, else the external label).
  private static func handlerParamName(of funcDecl: FunctionDeclSyntax) -> String? {
    guard let first = funcDecl.signature.parameterClause.parameters.first else {
      return nil
    }
    return (first.secondName ?? first.firstName).text
  }
}

enum JSEventDiagnostic: String, DiagnosticMessage {
  case notAFunc

  var severity: DiagnosticSeverity {
    .error
  }

  var message: String {
    switch self {
    case .notAFunc:
      "@JSEvent can only be applied to a function"
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "JSBridgeMacros", id: rawValue)
  }
}
