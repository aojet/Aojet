//
//  Either.swift
//  Aojet
//
//  Created by Qihe Bian on 7/23/16.
//  Copyright © 2016 Qihe Bian. All rights reserved.
//

public protocol EitherType {
  associatedtype LeftType
  associatedtype RightType

  /// Constructs a `Left` instance.
  static func left(value: LeftType) -> Self

  /// Constructs a `Right` instance.
  static func right(value: RightType) -> Self

  /// Returns the result of applying `f` to `Left` values, or `g` to `Right` values.
  func either<Result>( ifLeft: (LeftType) throws -> Result, ifRight: (RightType) throws -> Result) rethrows -> Result
}


extension EitherType {
  /// Returns the value of `Left` instances, or `nil` for `Right` instances.
  public var left: LeftType? {
    return either(ifLeft: unit, ifRight: const(nil))
  }

  /// Returns the value of `Right` instances, or `nil` for `Left` instances.
  public var right: RightType? {
    return either(ifLeft: const(nil), ifRight: unit)
  }
}


// MARK: API

/// Equality (tho not `Equatable`) over `EitherType` where `Left` & `Right` : `Equatable`.
public func == <E: EitherType> (lhs: E, rhs: E) -> Bool where E.LeftType: Equatable, E.RightType: Equatable {
  return lhs.either(
    ifLeft: { $0 == rhs.either(ifLeft: unit, ifRight: const(nil)) },
    ifRight: { $0 == rhs.either(ifLeft: const(nil), ifRight: unit) })
}


/// Inequality over `EitherType` where `Left` & `Right` : `Equatable`.
public func != <E: EitherType> (lhs: E, rhs: E) -> Bool where E.LeftType: Equatable, E.RightType: Equatable {
  return !(lhs == rhs)
}

public enum Either<T, U>: EitherType, CustomDebugStringConvertible, CustomStringConvertible {
  case Left(T)
  case Right(U)


  // MARK: Lifecycle

  /// Constructs a `Left`.
  ///
  /// Suitable for partial application.
  public static func left(value: T) -> Either {
    return Left(value)
  }

  /// Constructs a `Right`.
  ///
  /// Suitable for partial application.
  public static func right(value: U) -> Either {
    return Right(value)
  }


  // MARK: API

  /// Returns the result of applying `f` to the value of `Left`, or `g` to the value of `Right`.
  public func either<Result>( ifLeft: (T) throws -> Result, ifRight: (U) throws -> Result) rethrows -> Result {
    switch self {
    case let .Left(x):
      return try ifLeft(x)
    case let .Right(x):
      return try ifRight(x)
    }
  }

  /// Maps `Right` values with `transform`, and re-wraps `Left` values.
  public func map<V>( transform: (U) -> V) -> Either<T, V> {
    return flatMap { .right(value: transform($0)) }
  }

  /// Returns the result of applying `transform` to `Right` values, or re-wrapping `Left` values.
  public func flatMap<V>( transform: (U) -> Either<T, V>) -> Either<T, V> {
    return either(
      ifLeft: Either<T, V>.left,
      ifRight: transform)
  }

  /// Maps `Left` values with `transform`, and re-wraps `Right` values.
  public func mapLeft<V>( transform: (T) -> V) -> Either<V, U> {
    return flatMapLeft { .left(value: transform($0)) }
  }

  /// Returns the result of applying `transform` to `Left` values, or re-wrapping `Right` values.
  public func flatMapLeft<V>( transform: (T) -> Either<V, U>) -> Either<V, U> {
    return either(
      ifLeft: transform,
      ifRight: Either<V, U>.right)
  }


  /// Returns the value of `Left` instances, or `nil` for `Right` instances.
  public var left: T? {
    return either(
      ifLeft: unit,
      ifRight: const(nil))
  }

  /// Returns the value of `Right` instances, or `nil` for `Left` instances.
  public var right: U? {
    return either(
      ifLeft: const(nil),
      ifRight: unit)
  }


  /// Given equality functions for `T` and `U`, returns an equality function for `Either<T, U>`.
  public static func equals(left: @escaping (T, T) -> Bool, right: @escaping (U, U) -> Bool) -> (Either<T, U>, Either<T, U>) -> Bool {
    return { a, b in
      (a.left &&& b.left).map(left)
        ??	(a.right &&& b.right).map(right)
        ??	false
    }
  }


  // MARK: CustomDebugStringConvertible

  public var debugDescription: String {
    return either(
      ifLeft: { ".Left(\(String(reflecting: $0)))" },
      ifRight: { ".Right(\(String(reflecting: $0)))" })
  }
  
  
  // MARK: CustomStringConvertible
  
  public var description: String {
    return either(
      ifLeft: { ".Left(\($0))"},
      ifRight: { ".Right(\($0))" })
  }
}

/// Returns a function which ignores its argument and returns `x` instead.
public func const<T, U>(_ x: T) -> (U) -> T {
  return { _ in x }
}

// MARK: - Unit

/// Returns its argument as an `Optional<T>`.
public func unit<T>(x: T) -> T? {
  return x
}


// MARK: - Optional conjunction

/// Returns a tuple of two `Optional` values, or `nil` if either or both are `nil`.
public func &&& <T, U> (left: T?, right: @autoclosure () -> U?) -> (T, U)? {
  if let x = left, let y = right() {
    return (x, y)
  }
  return nil
}


// MARK: - Operators

infix operator &&&: LogicalConjunctionPrecedence
