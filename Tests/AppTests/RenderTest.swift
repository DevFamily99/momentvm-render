//
//  RenderTest.swift
//  App
//
//  Created by Benjamin Nassler on 17.06.18.
//
@testable import App
@testable import Vapor
import XCTest
import JSON


final class RenderTest: XCTestCase {
  
  
  func testFilterRenderTags() throws {
//    let moduleBody = """
//    {
//      "foo" : "Hello",
//      "bar" : "not used",
//      "baz" : "not used"
//    }
//    """
//    let templateBody = """
//    <mvmpublish>
//      publishingFooBar
//    </mvmpublish>
//
//    <mvmpublish id="video">
//      publishingBarFoo
//    </mvmpublish>
//
//    <mvmpreview id="video">
//    previewFooBar
//    </mvmpreview>
//    """
//    let module = ContentModule(body: moduleBody, id: 1, rank: "abc123", template_id: 2)
//    let template = ContentTemplate(name: "foo-template", body: templateBody, secondaryBody: "", id: 2, createdAt: "foo", updatedAt: "bar")
//    /// Preview
//    let renderer = RenderHelper(mode: .preview)
//    let result = try renderer.render(module: module, usingTemplate: template)
//    XCTAssertTrue(result.contains("previewFooBar"))
//    XCTAssertFalse(result.contains("publishingFooBar"))
//    XCTAssertFalse(result.contains("publishingBarFoo"))
//    /// Publishing
//    let publishingRenderer = RenderHelper(mode: .publishing)
//    let publishResult = try publishingRenderer.render(module, usingTemplate: template)
//    XCTAssertTrue(publishResult.contains("publishingBarFoo"))
//    XCTAssertTrue(publishResult.contains("publishingFooBar"))
//    XCTAssertFalse(publishResult.contains("previewFooBar"))
  }
  
  
  /// Renders a preview
  func testPreview() throws {
//    let app = Application(.testing)
//    defer { app.shutdown() }
//    try configure(app)
//    let moduleBody = """
//    {
//      "foo" : "Hello",
//      "bar" : "not used",
//      "baz" : "not used"
//    }
//    """
//    let templateBody = "#(foo)"
//    let module = ContentModule(body: moduleBody, id: 1, rank: "abc123", template_id: 2)
//    let template = ContentTemplate(name: "foo-template", body: templateBody, secondaryBody: "", id: 2, createdAt: "bar", updatedAt: "foo")
//    let config = PreviewConfiguration(localeToRender: "de", site: "DE")
//    let previewRequest = PreviewRequest(modules: [module],
//                                        templates: [template],
//                                        sites: [Site(name: "DE", id: "DE", locales: [Locale(id: "de", name: "German")])],
//                                        images: [],
//                                        configuration: config
//    )
////    let encodedPreviewRequest = try previewRequest.encode(to: PreviewRequest.self)
////    encodedPreviewRequest.http.headers.basicAuthorization = BasicAuthorization(username: "user", password: "pass")
//    let renderController = RenderController()
//    let request = try renderController.preview(encodedPreviewRequest)
//    let response = try request.wait()
//    app.test
//    try app.test(.GET, "hello") { res in
//      XCTAssertEqual(res.status, .ok)
//      XCTAssertEqual(res.body.string, "Hello, world!")
//    }
//    XCTAssertTrue(response.contains("Hello"))
  }
  
  
  
  /// Tests rendering
  func testRendering() throws {
//    let app = Application(.testing)
//    defer { app.shutdown() }
//    try configure(app)
//    let moduleBody = """
//    {
//      "foo" : "Hello",
//      "bar" : "not used",
//      "baz" : "not used"
//    }
//    """
//    let templateBody = """
//    #(foo) dynamicimage::large:test-image::
//    img::test-image::
//    """
//    let variant = DynamicImage.Variant(name: "large", url: "large.jpg")
//    let dynamicImage = DynamicImage(name: "test-image", fileEnding: ".jpg", variants: [variant])
//    let module = ContentModule(body: moduleBody, id: 1, rank: "abc123", template_id: 2)
//    let template = ContentTemplate(name: "foo-template", body: templateBody, secondaryBody: "", id: 2, createdAt: "foo", updatedAt: "bar")
//    let site = Site(name: "DE", id: "DE", locales: [Locale(id: "de", name: "German")])
//    let configuration = RenderingConfiguration(countries: ["DE"], velocity: false)
//    let renderRequest = RenderRequest(modules: [module], templates: [template], images: [dynamicImage], sites: [site], configuration: configuration)
//    let encodedRenderRequest = try renderRequest.encode(to: RenderRequest.self)
//    encodedRenderRequest.http.headers.basicAuthorization = BasicAuthorization(username: "user", password: "pass")
//    let renderController = RenderController()
//    let request = try renderController.renderPage(encodedRenderRequest)
//    let response = try request.wait()
//    guard let germanContent = response.renderedContent["de-DE"] else {
//      XCTFail()
//      return
//    }
//    XCTAssertTrue(germanContent.contains("Hello"))
//    XCTAssertTrue(germanContent.contains("test-image__large.jpg?$staticlink$"))
  }
  
  
  
  static let allTests = [
    ("testFilterRenderTags", testFilterRenderTags),
    ("testPreview", testPreview),
    ("testRendering", testRendering)
  ]
  
}
