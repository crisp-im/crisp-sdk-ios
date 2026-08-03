import SwiftSyntax

extension AttributeSyntax {
  var labeledArguments: LabeledExprListSyntax? {
    self.arguments?.as(LabeledExprListSyntax.self)
  }

  /// Returns the value of the first string-literal argument matching `label`.
  func stringArgument(named label: String) -> String? {
    self.labeledArguments?
      .first(where: { $0.label?.text == label })?
      .stringLiteralValue
  }

  /// Returns the first positional (unlabeled) string-literal argument.
  func firstPositionalStringArgument() -> String? {
    guard
      let first = self.labeledArguments?.first,
      first.label == nil
    else {
      return nil
    }
    return first.stringLiteralValue
  }
}

extension LabeledExprSyntax {
  /// The string value of the expression if it is a non-interpolated string literal.
  var stringLiteralValue: String? {
    self.expression.as(StringLiteralExprSyntax.self)?.stringValue
  }
}

extension StringLiteralExprSyntax {
  /// Extracts the literal string value, returning nil if the literal contains
  /// interpolation segments.
  var stringValue: String? {
    var result = ""
    for segment in segments {
      guard let text = segment.as(StringSegmentSyntax.self) else { return nil }
      result += text.content.text
    }
    return result
  }
}
