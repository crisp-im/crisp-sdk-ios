import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

package struct JSClassMacro: MemberMacro {
  package static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo _: [TypeSyntax],
    in context: some MacroExpansionContext,
  ) throws -> [DeclSyntax] {
    // @JSClass is only allowed on structs.
    guard let structDecl = declaration.as(StructDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: node,
          message: JSClassDiagnostic.notAStruct,
        ),
      )
      return []
    }

    let arguments = self.parseArguments(from: node)
    let className = arguments.name ?? structDecl.name.text
    guard let jsModule = arguments.jsModule else {
      context.diagnose(
        Diagnostic(node: node, message: JSClassDiagnostic.missingJSModule),
      )
      return []
    }

    let methods = self.collectMethods(from: structDecl)
    let events = self.collectEvents(from: structDecl)

    let evaluatorStorage: DeclSyntax = "private let evaluator: JSEvaluator"
    let eventsStorage: DeclSyntax = "let events: JSEventBus"
    let classNameDecl: DeclSyntax = """
    static let _jsClassName: String = \(raw: self.quoted(className))
    """
    let initDecl: DeclSyntax = """
    @MainActor
    package init(evaluator: @escaping JSEvaluator, events: JSEventBus) {
      self.evaluator = evaluator
      self.events = events
    }
    """
    let onEventErrorDecl: DeclSyntax = """
    @MainActor
    package func onEventError(
      _ handler: @MainActor @escaping (String, JSEventError) -> Void,
    ) {
      self.events.onError(handler)
    }
    """
    let generatedJSDecl = self.makeGeneratedJS(
      className: className,
      jsModule: jsModule,
      methods: methods,
      events: events,
    )

    return [
      evaluatorStorage,
      eventsStorage,
      classNameDecl,
      initDecl,
      onEventErrorDecl,
      generatedJSDecl,
    ]
  }

  private struct Arguments {
    var name: String?
    var jsModule: String?
  }

  private static func parseArguments(from node: AttributeSyntax) -> Arguments {
    Arguments(
      name: node.stringArgument(named: "name"),
      jsModule: node.stringArgument(named: "jsModule"),
    )
  }

  struct Method {
    let swiftName: String
    let replacement: String? // from @JSMethod(replacement:)
  }

  struct Event {
    let swiftName: String
    let actionEventName: String?
  }

  private static func isEventHandler(_ decl: FunctionDeclSyntax) -> Bool {
    if
      self.findAttribute(named: "JSEvent", in: decl.attributes) != nil ||
      self.findAttribute(named: "CrispActionEvent", in: decl.attributes) != nil
    {
      return true
    }
    return false
  }

  private static func collectMethods(from structDecl: StructDeclSyntax) -> [Method] {
    var methods: [Method] = []

    for member in structDecl.memberBlock.members {
      guard
        let funcDecl = member.decl.as(FunctionDeclSyntax.self),
        !self.isEventHandler(funcDecl)
      else {
        continue
      }

      let replacement = self.findAttribute(named: "JSMethod", in: funcDecl.attributes)
        .flatMap { $0.stringArgument(named: "replacement") }
      methods.append(Method(swiftName: funcDecl.name.text, replacement: replacement))
    }

    return methods
  }

  private static func collectEvents(from structDecl: StructDeclSyntax) -> [Event] {
    var events: [Event] = []

    for member in structDecl.memberBlock.members {
      guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
        continue
      }

      if self.findAttribute(named: "JSEvent", in: funcDecl.attributes) != nil {
        events.append(Event(swiftName: funcDecl.name.text, actionEventName: nil))
      } else if let attribute = self.findAttribute(
        named: "CrispActionEvent",
        in: funcDecl.attributes,
      ) {
        guard let event = attribute.firstPositionalStringArgument() else {
          continue
        }
        events.append(Event(swiftName: funcDecl.name.text, actionEventName: event))
      }
    }

    return events
  }

  /// Returns the named attribute, if present.
  private static func findAttribute(
    named name: String,
    in attributes: AttributeListSyntax,
  ) -> AttributeSyntax? {
    for element in attributes {
      guard
        let attr = element.as(AttributeSyntax.self),
        let attrName = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
        attrName == name
      else { continue }
      return attr
    }
    return nil
  }

  private static func makeGeneratedJS(
    className: String,
    jsModule: String,
    methods: [Method],
    events: [Event],
  ) -> DeclSyntax {
    // The full surface we import from `jsModule` — methods + library event
    // functions, sorted for stable output. @CrispActionEvent events use the
    // shared `on(event, cb)` helper rather than a per-event export.
    let jsEventNames = events.filter { $0.actionEventName == nil }.map(\.swiftName)
    let hasActionEvent = events.contains { $0.actionEventName != nil }
    var importSet = Set(methods.map(\.swiftName) + jsEventNames)
    if hasActionEvent {
      importSet.insert("on")
    }
    let importNames = importSet.sorted()
    let imports = importNames
      .map { "  \($0)," }
      .joined(separator: "\n")

    // window.<ClassName> = { ... } — key is always the Swift property name,
    // value is either the same identifier (imported) or globalThis.<replacement>.
    let entries = methods
      .sorted(by: { $0.swiftName < $1.swiftName })
      .map { method -> String in
        if let replacement = method.replacement {
          "  \(method.swiftName): globalThis.\(replacement),"
        } else {
          "  \(method.swiftName),"
        }
      }
      .joined(separator: "\n")

    // Subscriptions for `@JSEvent` library bindings: forward each onXxx call to
    // the matching `webkit.messageHandlers` channel via the host's `sendEvent`
    // helper (defined in index.html).
    let subscriptions = events
      .sorted(by: { $0.swiftName < $1.swiftName })
      .map { event in
        if let actionEventName = event.actionEventName {
          #"on("\#(actionEventName)", (payload) => sendEvent("\#(event.swiftName)", payload))"#
        } else {
          "\(event.swiftName)((payload) => sendEvent('\(event.swiftName)', payload))"
        }
      }
      .joined(separator: "\n")

    var js = """
    import {
    \(imports)
    } from '\(jsModule)'

    window.\(className) = {
    \(entries)
    }
    """

    if !subscriptions.isEmpty {
      js += "\n\n" + subscriptions
    }

    return """
    nonisolated static let generatedJS: String = #\"\"\"
    \(raw: js)
    \"\"\"#
    """
  }

  private static func quoted(_ s: String) -> String {
    // Property names and the class name are Swift identifiers, so no escaping
    // is needed. If you ever feed user-controlled strings through here, revisit.
    "\"\(s)\""
  }
}

extension JSClassMacro: MemberAttributeMacro {
  /// Auto-attaches `@MainActor` to every function declared inside the struct.
  /// Funcs that aren't already marked `@JSEvent` also get `@JSMethod` — events
  /// opt out of the method bridge by virtue of carrying their own annotation.
  package static func expansion(
    of _: AttributeSyntax,
    attachedTo _: some DeclGroupSyntax,
    providingAttributesFor member: some DeclSyntaxProtocol,
    in _: some MacroExpansionContext,
  ) throws -> [AttributeSyntax] {
    guard let funcDecl = member.as(FunctionDeclSyntax.self) else { return [] }

    let isEvent = self.isEventHandler(funcDecl)
    let hasMethod = self.findAttribute(named: "JSMethod", in: funcDecl.attributes) != nil

    var attrs: [AttributeSyntax] = []
    if !self.hasAttribute(named: "MainActor", in: funcDecl.attributes) {
      attrs.append("@MainActor")
    }
    if !isEvent, !hasMethod {
      attrs.append("@JSMethod")
    }
    return attrs
  }

  private static func hasAttribute(
    named name: String,
    in attributes: AttributeListSyntax,
  ) -> Bool {
    for element in attributes {
      guard
        let attr = element.as(AttributeSyntax.self),
        let attrName = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text
      else { continue }
      if attrName == name { return true }
    }
    return false
  }
}

enum JSClassDiagnostic: String, DiagnosticMessage {
  case notAStruct
  case missingJSModule

  var severity: DiagnosticSeverity {
    .error
  }

  var message: String {
    switch self {
    case .notAStruct:
      "@JSClass can only be applied to a struct"
    case .missingJSModule:
      "@JSClass requires a 'jsModule:' argument pointing at the JS module to import from"
    }
  }

  var diagnosticID: MessageID {
    MessageID(domain: "JSBridgeMacros", id: rawValue)
  }
}
