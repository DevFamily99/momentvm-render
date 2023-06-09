//
//  TokenHelperTest.swift
//  AppTests
//
//  Created by Benjamin Nassler on 19/05/2019.
//
@testable import App
@testable import Vapor
import XCTest


final class TokenHelperTests: XCTestCase {
  
  struct TestHelper: TokenAccessor {}
  
  func testTokenRetrieval() throws {
//    let app = try Application()
//    let client = app.client
//    let req = Request(using: client.container)
//    req.http.headers.add(name: "Client-ID", value: "foo")
//    req.http.headers.add(name: "Client-Secret", value: "bar")
  }

  func testTokenSerialization() throws {
//    let now = Date()
//    let token = Token(client: "foo", token: "bar", expiresIn: now)
//    let redisData = try token.convertToRedisData()
//    let deserializedToken = try Token.convertFromRedisData(redisData)
//    assert(token.client == deserializedToken.client)
//    assert(token.token == deserializedToken.token)
//    assert(Int(token.expiresIn.timeIntervalSince1970) == Int(deserializedToken.expiresIn.timeIntervalSince1970))
  }
  
  func testTokenValid() throws {
    let token = Token(client: "", token: "", expiresIn: Date().addingTimeInterval(-1000))
    assert(token.isValid == false)
    let token2 = Token(client: "", token: "", expiresIn: Date().addingTimeInterval(1000))
    assert(token2.isValid == true)
  }
  
  
  
  static let allTests = [
    ("testTokenRetrieval", testTokenRetrieval),
    ("testTokenValid", testTokenValid)
  ]
}
