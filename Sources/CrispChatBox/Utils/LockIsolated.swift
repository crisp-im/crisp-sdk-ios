import Foundation

// MIT License
//
// Copyright (c) 2023 Point-Free
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Source: https://github.com/pointfreeco/swift-concurrency-extras/blob/main/Sources/ConcurrencyExtras/LockIsolated.swift

/// A generic wrapper for isolating a mutable value with a lock.
///
/// If you trust the sendability of the underlying value, consider using ``UncheckedSendable``,
/// instead.
// swiftlint:disable:next no_unchecked_sendable
@dynamicMemberLookup package final class LockIsolated<Value>: @unchecked Sendable {
  private var _value: Value
  private let lock = NSRecursiveLock()

  /// Initializes lock-isolated state around a value.
  ///
  /// - Parameter value: A value to isolate with a lock.
  package init(_ value: @autoclosure @Sendable () throws -> Value) rethrows {
    self._value = try value()
  }

  package subscript<Subject: Sendable>(dynamicMember keyPath: KeyPath<Value, Subject>) -> Subject {
    self.lock.sync {
      self._value[keyPath: keyPath]
    }
  }

  /// Perform an operation with isolated access to the underlying value.
  ///
  /// Useful for modifying a value in a single transaction.
  ///
  /// ```swift
  /// // Isolate an integer for concurrent read/write access:
  /// var count = LockIsolated(0)
  ///
  /// func increment() {
  ///   // Safely increment it:
  ///   self.count.withValue { $0 += 1 }
  /// }
  /// ```
  ///
  /// - Parameter operation: An operation to be performed on the the underlying value with a lock.
  /// - Returns: The result of the operation.
  package func withValue<T: Sendable>(
    _ operation: @Sendable (inout Value) throws -> T,
  ) rethrows -> T {
    try self.lock.sync {
      var value = self._value
      defer { self._value = value }
      return try operation(&value)
    }
  }

  /// Overwrite the isolated value with a new value.
  ///
  /// ```swift
  /// // Isolate an integer for concurrent read/write access:
  /// var count = LockIsolated(0)
  ///
  /// func reset() {
  ///   // Reset it:
  ///   self.count.setValue(0)
  /// }
  /// ```
  ///
  /// > Tip: Use ``withValue(_:)`` instead of ``setValue(_:)`` if the value being set is derived
  /// > from the current value. That is, do this:
  /// >
  /// > ```swift
  /// > self.count.withValue { $0 += 1 }
  /// > ```
  /// >
  /// > ...and not this:
  /// >
  /// > ```swift
  /// > self.count.setValue(self.count + 1)
  /// > ```
  /// >
  /// > ``withValue(_:)`` isolates the entire transaction and avoids data races between reading and
  /// > writing the value.
  ///
  /// - Parameter newValue: The value to replace the current isolated value with.
  package func setValue(_ newValue: @autoclosure @Sendable () throws -> Value) rethrows {
    try self.lock.sync {
      self._value = try newValue()
    }
  }
}

package extension LockIsolated where Value: Sendable {
  /// The lock-isolated value.
  var value: Value {
    self.lock.sync {
      self._value
    }
  }
}

#if swift(<6)
  @available(*, deprecated, message: "Lock isolated values should not be equatable")
  extension LockIsolated: Equatable where Value: Equatable {
    package static func == (lhs: LockIsolated, rhs: LockIsolated) -> Bool {
      lhs.value == rhs.value
    }
  }

  @available(*, deprecated, message: "Lock isolated values should not be hashable")
  extension LockIsolated: Hashable where Value: Hashable {
    package func hash(into hasher: inout Hasher) {
      hasher.combine(self.value)
    }
  }
#endif

// swiftlint:disable:next no_public_outside_crisp
public extension NSRecursiveLock {
  @inlinable @discardableResult
  @_spi(Internals) func sync<R>(work: () throws -> R) rethrows -> R {
    self.lock()
    defer { self.unlock() }
    return try work()
  }
}
