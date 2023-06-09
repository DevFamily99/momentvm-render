//
//  ImageTest.swift
//  AppTests
//
//  Created by Benjamin Nassler on 06.06.18.
//
@testable import App
@testable import Vapor
import XCTest


final class XMLTests: XCTestCase {
  
  
  
  
  let xml = """
  <div class="test">
    <mvmplugin id="video" use="preview"> 
    <div>
      <h1>HELLO</h1>
    </div>
    </mvmplugin>
  </div>
  """
  
  
  func testXMLParsing() throws {
//    let app = try Application()
//    let client = app.client
//    let req = Request(using: client.container)
//    let foo = XMLPromiseParser(req: req, elementsToListenFor: ["mvmplugin"])
//    let result = try foo.localize(content: xml).wait()
//    print(result)
//    // tester.localize(xml)
//    XCTAssertTrue(true)
//    print("test done.")
  }
  
  
  
  static let allTests = [
    ("testXMLParsing", testXMLParsing)
  ]
  
}
