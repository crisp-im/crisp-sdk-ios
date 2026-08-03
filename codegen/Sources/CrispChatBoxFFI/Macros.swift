@attached(
  member,
  names: named(init), named(evaluator), named(events), named(_jsClassName),
  named(onEventError), named(generatedJS)
)
@attached(memberAttribute)
package macro JSClass(
  name: String? = nil,
  jsModule: String,
) = #externalMacro(module: "ChatBoxJSMacros", type: "JSClassMacro")

@attached(body)
package macro JSMethod(replacement: String? = nil) = #externalMacro(
  module: "ChatBoxJSMacros",
  type: "JSMethodMacro",
)

@attached(body)
package macro JSEvent() = #externalMacro(
  module: "ChatBoxJSMacros",
  type: "JSEventMacro",
)

@attached(body)
package macro CrispActionEvent(_ event: String) = #externalMacro(
  module: "ChatBoxJSMacros",
  type: "CrispActionEventMacro",
)
