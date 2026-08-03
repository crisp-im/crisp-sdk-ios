import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `@CrispActionEvent` is `@attached(body)`. Synthesizes a body that registers
/// the handler on the JS event bus; `@JSClass` separately emits a top-level
/// `on("<event-name>", …)` subscription in `generatedJS` that funnels the
/// payload back through `sendEvent`.
package struct CrispActionEventMacro: BodyMacro {
  package static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext,
  ) throws -> [CodeBlockItemSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      context.diagnose(Diagnostic(node: node, message: CrispActionEventMacroDiagnostic.notAFunc))
      return []
    }

    guard node.firstPositionalStringArgument() != nil else {
      context.diagnose(
        Diagnostic(node: node, message: CrispActionEventMacroDiagnostic.missingEventName),
      )
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

enum CrispActionEventMacroDiagnostic: String, DiagnosticMessage {
  case notAFunc
  case missingEventName

  var severity: DiagnosticSeverity {
    .error
  }

  var message: String {
    switch self {
    case .notAFunc:
      "@CrispActionEvent can only be applied to a function"
    case .missingEventName:
      "@CrispActionEvent needs an event name to subscribe to (e.g. 'message:sent')"
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "JSBridgeMacros", id: rawValue)
  }
}
