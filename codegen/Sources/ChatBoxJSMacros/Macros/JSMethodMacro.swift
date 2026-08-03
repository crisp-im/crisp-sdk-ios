import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `@JSMethod` is an `@attached(body)` macro. It synthesizes an async-throwing
/// body for a function that calls into the JS bridge at
/// `window.<ClassName>.<funcName>`, JSON-encoding each argument.
///
/// The class name is read at runtime via `Self._jsClassName`, which is provided
/// by the enclosing `@JSClass` macro.
package struct JSMethodMacro: BodyMacro {
  package static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext,
  ) throws -> [CodeBlockItemSyntax] {
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      context.diagnose(Diagnostic(node: node, message: JSMethodDiagnostic.notAFunc))
      return []
    }

    let funcName = funcDecl.name.text

    // Use the parameter's internal name (or external label if no internal name)
    // as the local identifier we encode at the call site.
    let argNames = funcDecl.signature.parameterClause.parameters.map { param -> String in
      (param.secondName ?? param.firstName).text
    }

    let encodedArgs = argNames.map { "jsEncode(\($0))" }.joined(separator: ", ")

    let callerDecl: CodeBlockItemSyntax = """
    let caller = JSCaller(
      funcName: "\\(Self._jsClassName).\(raw: funcName)",
      evaluator: self.evaluator,
    )
    """

    let returnStmt: CodeBlockItemSyntax = """
    return try await caller(\(raw: encodedArgs))
    """

    return [callerDecl, returnStmt]
  }
}

enum JSMethodDiagnostic: String, DiagnosticMessage {
  case notAFunc

  var severity: DiagnosticSeverity {
    .error
  }

  var message: String {
    switch self {
    case .notAFunc:
      "@JSMethod can only be applied to a function"
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "JSBridgeMacros", id: rawValue)
  }
}
