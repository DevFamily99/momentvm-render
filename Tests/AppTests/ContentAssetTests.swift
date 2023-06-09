//
//  ContentAssetTests.swift
//  App
//
//  Created by Benjamin Nassler on 17.06.18.
//
@testable import App
@testable import Vapor
import XCTest


final class ContentAssetTests: XCTestCase {
  
  /*
  
  /// Renders a preview
  func testContentAssetCompress() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    var body: [String: LocalizedMarkup] = [:]
    body["default"] = LocalizedMarkup(type: "html", source: "foo")
    body["de"] = LocalizedMarkup(type: "html", source: "foo")
    body["de-DE"] = LocalizedMarkup(type: "html", source: "foo")
    body["de-CH"] = LocalizedMarkup(type: "html", source: "bar")
    
    let document = ContentAssetDocument(online: ["default" : true],
                                        body: body)
    let compressed = document.compressedBody
     let response = try request.wait()
    XCTAssertTrue(compressed.body.keys.count == 2)
  }
  
  
  /// Renders a preview
  func testContentAssetCompressTwo() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    var body: [String: LocalizedMarkup] = [:]
    body["default"] = LocalizedMarkup(type: "html", source: "bazzz")
    body["de"] = LocalizedMarkup(type: "html", source: "foo")
    body["de-DE"] = LocalizedMarkup(type: "html", source: "foo")
    body["de-CH"] = LocalizedMarkup(type: "html", source: "bar")
    body["fr"] = LocalizedMarkup(type: "html", source: "fr")
    body["fr-CH"] = LocalizedMarkup(type: "html", source: "bar")
    body["fr-BE"] = LocalizedMarkup(type: "html", source: "fr")


    let document = ContentAssetDocument(online: ["default" : true],
                                        body: body)
    let compressed = document.compressedBody
    // let response = try request.wait()
    XCTAssertTrue(compressed.body.keys.count == 5)
  }
  
  static let allTests = [
    ("testContentAssetCompress", testContentAssetCompress),
    ("testContentAssetCompressTwo", testContentAssetCompressTwo)
  ]
 
 */
  
}
