@testable import App
@testable import Vapor
import XCTest


final class AppTests: XCTestCase {
  
  func testValidURLs() throws {
    let invalidURLString = "http://goo   gle.com"
    try XCTAssertThrowsError(URI(withUnsafeString: invalidURLString))
    try XCTAssertNoThrow(URI(withUnsafeString: "https://google.com"))
  }
  
  /// A product ID should not be rendered as markdown
  func testMarkdownProductId() throws {
    let body = [
      "default" : "productid1234"
    ]
    let translation = Translation(body: body, createdAt: "", updatedAt: "", translationID: 1)
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    let helper = TranslationHelper(client: app.client)
    let value = helper.localize("loc::1", withTranslations: [translation], locale: "default")
    XCTAssertEqual(value, "productid1234")
    XCTAssertFalse(value.contains("<p>"))
  }
  
  func testLocalesHierarchySite() throws {
    let body = [
      "default" : "default",
      "de" : "de",
      "de-DE" : "de-DE"
    ]
    let translation = Translation(body: body, createdAt: "", updatedAt: "", translationID: 1)
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    let helper = TranslationHelper(client: app.client)
    let value = helper.translation(translation, forLocale: "de-DE")
    XCTAssertEqual(value, "de-DE")
  }
  
  func testLocalesHierarchyLang() throws {
    let body = [
      "default" : "default",
      "de" : "de"
    ]
    let translation = Translation(body: body, createdAt: "", updatedAt: "", translationID: 1)
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    let helper = TranslationHelper(client: app.client)
    let value = helper.translation(translation, forLocale: "de-DE")
    XCTAssertEqual(value, "de")
  }
  
  func testLocalesHierarchyDefault() throws {
    let body = [
      "default" : "default",
      "de" : "de",
      "de-DE" : "de-DE"
    ]
    let translation = Translation(body: body, createdAt: "", updatedAt: "", translationID: 1)
    
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    let helper = TranslationHelper(client: app.client)
    let value = helper.translation(translation, forLocale: "default")
    XCTAssertEqual(value, "default")
  }
  
  
  
  func testFindLocalesInTranslations() throws {
    let body = [
      "default" : "default",
      "de" : "de",
      "de-DE" : "de-DE",
      "de-CH" : "Hallo Schweiz!",
      "fr" : "Bienvenue!",
      "fr-BE" : "Belgium"
    ]
    let translation = Translation(body: body, createdAt: "", updatedAt: "", translationID: 1)
    
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    
    var helper = TranslationHelper(client: app.client)
    helper.translations.append(translation)
    
    
    let _ = helper.findMinimalLocales()
    XCTAssertEqual("default", "default")
  }
  
  static let allTests = [
    ("testMarkdownProductId", testMarkdownProductId),
    ("testLocalesHierarchySite", testLocalesHierarchySite),
    ("testLocalesHierarchyLang", testLocalesHierarchyLang),
    ("testLocalesHierarchyDefault", testLocalesHierarchyDefault),
    ("testFindLocalesInTranslations", testFindLocalesInTranslations)
  ]
}

