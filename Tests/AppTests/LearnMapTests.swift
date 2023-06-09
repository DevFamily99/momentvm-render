//
//  ContentAssetTests.swift
//  App
//
//  Created by Benjamin Nassler on 17.06.18.
//
@testable import App
@testable import Vapor
import XCTest


final class LearnMapTests: XCTestCase {
  
  func returnString(req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.makeSucceededFuture("blah")
  }
  
  func returnInt(req: Request) -> EventLoopFuture<Int> {
    return req.eventLoop.makeSucceededFuture(123)
  }
  
  // While this is possible its not recommended.
  // Should either return a value and throw
  func foo(req: Request) throws -> EventLoopFuture<Bool> {
    guard "you like" == "cake" else {
      throw Abort(.forbidden)
    }
    return req.eventLoop.makeSucceededFuture(true)
  }
  
  // Here we don't throw but instead just return a failed future
  // Note the return type of a failed future is Error
  func fooNonThrowing(req: Request) -> EventLoopFuture<Bool> {
    guard "you like" == "cake" else {
      return req.eventLoop.makeFailedFuture(Abort(.forbidden))
    }
    return req.eventLoop.makeSucceededFuture(true)
  }
  
  func addStrings(req: Request, string: String) -> EventLoopFuture<String> {
    return req.eventLoop.makeSucceededFuture(string + "baz")
  }
  
  func returnStringThrowing(req: Request) -> EventLoopFuture<String> {
    return req.eventLoop.makeSucceededFuture("blah")
  }
  
  func test(req: Request) -> EventLoopFuture<String> {
    
    /// Here were processing the wrapped at the same time
    let one = returnString(req: req)
    let _ = returnString(req: req).and(one).map { (value, bazbza) -> String in
      return bazbza + value
    }
    // combinedString is an EventloopFuture<String>
    
    
    let sequenciallyCombined = returnString(req: req).map { value in return value + "bar" }
    // MARK:  map
    let _ = returnString(req: req).and(sequenciallyCombined).map { newValue, previous in
      // we return a value here (String is a value) so we map        /
      return newValue + previous // <--------------------------------
    }
    // MARK: flatMap
    let _ = returnString(req: req).flatMap { newValue in
      // This is itself a future so we flatMap   /
      return self.returnString(req: req) // <--------
    }
    // MARK: flatMapThrowing
    // throws but only value
    do {
      let _ = try foo(req: req).flatMapThrowing { newValue in
        return newValue
      }
    } catch {
      print("Ups")
    }
    
    // return value is a future string
    // because returnString returns a Int future
    return returnInt(req: req).map { value -> String in
      return "foo \(value)"
    }
    
  }
  
  func testSome() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    let req = Request(application: app, on: app.eventLoopGroup.next())
    let _ = test(req: req)
  }
  
  static let allTests = [
    ("test", testSome),
  ]
 
}
