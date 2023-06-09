//
//  Errors.swift
//  App
//
//  Created by Benjamin Nassler on 27.05.18.
//
// import Debugging
import Vapor

/// Minimal implementation of a DebuggableError
///
/// struct Foo: DebuggableError {
/// var identifier: String
/// var reason: String
/// }

struct RenderingError: DebuggableError {
  var identifier: String = "renderingerror"
  var reason: String
  var module: Int
  init(module: Int, reason: String) {
    self.reason = "\(reason) - in module \(module)"
    self.module = module
  }
}

enum FieldErrorCategory: String {
  case startDateInvalid = "Start date"
  case endDateInvalid = "End date"
}

struct FieldError: DebuggableError {
  var identifier: String = "fielderror"
  var reason: String
  init(field: FieldErrorCategory) {
    self.reason = "\(field.rawValue) invalid."
  }
}

/// A TranslationError can take a generic reason or a missing translation
struct TranslationError: DebuggableError, Content {
  var identifier = "translationerror"
  var reason: String
  init(missingTranslation: String) {
    self.reason = "Translation \(missingTranslation) not found."
  }
  init(reason: String) {
    self.reason = reason
  }
}
typealias TranslationErrors = Array<TranslationError>

struct ImageMissingError: DebuggableError {
  var identifier: String = "notfound"
  var name: String
  var variantName: String
  var reason: String {
    get {
      if self.name.isEmpty {
        return "Image field needs an image but was empty"
      } else {
        return "Image '\(self.name)' could not be found due to a missing image setting. Check if '\(self.variantName)' exists in your teams settings."
      }
    }
  }
  init(name: String, variantName: String) {
    self.name = name
    self.variantName = variantName
  }
}

typealias ImageMissingErrors = Array<ImageMissingError>

enum RegexFault: String {
  case invalidRange = "range invalid"
}
struct RegexError: DebuggableError {
  var identifier = "regexerror"
  var reason: String
  init(_ reason: RegexFault) {
    self.reason = reason.rawValue
  }
}

/// Vapor error handling
public protocol MicroServiceError: DebuggableError {
  var error: ConnectionError { get }
}
extension MicroServiceError {
  public var identifier: String {
    return "connection.failed"
  }
}
public enum ConnectionError {
  case failed
}
public enum ServiceType: String {
  case images = "ImageService"
  case translationService = "TranslationService"
  case publishingService = "PublishingService"
}

public struct Connection: MicroServiceError {
  public var error: ConnectionError
  var statusCode: HTTPStatus
  
  public static let readableName = "Microservice Connection Error"
  public var reason: String
  // switch self.error for reasons
  
  init(
    _ error: ConnectionError,
    service: ServiceType,
    statusCode: HTTPStatus
    ) {
    self.reason = "Connection was rejected from (\(service.rawValue))"
    self.error = error
    self.statusCode = statusCode
  }
}

/// Various internal inconsistencies
struct InconsistencyError: DebuggableError {
  var identifier = "inconsistency"
  var reason: String
  init(reason: String) {
    self.reason = reason
  }
}

