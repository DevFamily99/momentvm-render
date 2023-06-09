//
//  ImageTest.swift
//  AppTests
//
//  Created by Benjamin Nassler on 06.06.18.
//
@testable import App
@testable import Vapor
import XCTest


final class ImageTest: XCTestCase {
  
  func testReplaceDynamicImages() throws {
    let helper = ImageHelper(mode: .preview)
    let html = """
    <img src="dynamicimage::large:this is-a-Match.jpg::" />
    """
    let variant = DynamicImage.Variant(name: "large", url: "/large/large.jpg")
    let dynamicImage = DynamicImage(name: "this is-a-Match.jpg", fileEnding: ".jpg", variants: [variant])
    let outText = try helper.replaceDynamicImages([dynamicImage], inHtml: html)
    XCTAssertEqual(outText.html, "<img src=\"/large/large.jpg\" />")
  }
  
  func testDynamicImageRegex() throws {
    let app = Application(.testing)
    defer { app.shutdown() }
    try configure(app)
    // let imageHelper = ImageHelper(mode: .preview)
    let text = """
    <h1>Hello world!</h1>
    dynamicimage::large:this is-a-Match.jpg:: <1
    dynamicimage::large:this_is-a-Match!::
    dynamicimage::large:anothermatch::     <2
    dynamicimage::large:this_is-a-Match!::
    dynamicimage::small:this_is-a-Match!:: <3

    Should not bleed over the edge
    dynamicimage::legacy:::\" class=\"sk-image__img-color\" data-product-image

    ::::img:not::right:::string

    :img::large:this_is-a-Match!::
    """
    let results = try text.dynamicImageMatches()
    print("\(results.count) matches.")
    print(results.map { $0.name })
    XCTAssertTrue(results.count == 4) // keep in mind, unique
    let imageName = results.first?.name
    let imageSize = results.first?.variantName
    XCTAssertTrue(imageSize! == "large")
    XCTAssertFalse(imageSize! == "small")
    XCTAssertTrue(imageName! == "this is-a-Match.jpg")
  }
  
  
  
  /// Finds images
  func testLegacyImages() throws {
//    let app = Application(.testing)
//    defer { app.shutdown() }
//    try configure(app)
//    let body = """
//    {
//      "foo" : "img::thisIsAPicture!::",
//      "bar" : "img::thisIsAPicture!::",
//      "baz" : "notAPicture!::"
//    }
//    """
//    let templateBody = """
//    Legacy image, should be there
//    #(foo)
//    """
//    let module = ContentModule(body: body, id: 1, rank: "abc123", template_id: 2)
//    let template = ContentTemplate(name: "foo-template", body: templateBody, secondaryBody: "", id: 2, createdAt: "foo", updatedAt: "bar")
//    let findImagesRequest = FindImagesRequest(modules: [module], templates: [template])
//    let encodedImageRequest = try findImagesRequest.encode(to: FindImagesRequest.self)
//    encodedImageRequest.http.headers.basicAuthorization = BasicAuthorization(username: "user", password: "pass")
//    let renderController = RenderController()
//    let request = try renderController.findImages(encodedImageRequest)
//    let response = try request.wait()
//    XCTAssertEqual(response.images.count, 1)
//    XCTAssertEqual(response.images.first?.variantName, "legacy")
  }
  
  
  
  /// Finds images
  func testFindImages() throws {
//    let app = Application(.testing)
//    defer { app.shutdown() }
//    try configure(app)
//    let body = """
//    {
//      "foo" : "img::thisIsAPicture!::",
//      "bar" : "img::thisIsAPicture!::",
//      "baz" : "notAPicture!::"
//    }
//    """
//    let templateBody = """
//    Legacy image, should be there
//    #(foo)
//    #(foo)
//    #(foo)
//
//
//    Dynamic image, should only exist once in the result
//    :img::large:this_is-a-Match!::
//    :img::large:this_is-a-Match!::
//    :dynamicimage::medium:crazy-nice-picture::
//    :dynamicimage::large:crazy-nice-picture::
//    """
//    let module = ContentModule(body: body, id: 1, rank: "abc123", template_id: 2)
//    let template = ContentTemplate(name: "foo-template", body: templateBody, secondaryBody: "", id: 2, createdAt: "foo", updatedAt: "bar")
//    let findImagesRequest = FindImagesRequest(modules: [module], templates: [template])
//    let encodedImageRequest = try findImagesRequest.encode(using: app.client.container).wait()
//    encodedImageRequest.http.headers.basicAuthorization = BasicAuthorization(username: "user", password: "pass")
//    let renderController = RenderController()
//    let request = try renderController.findImages(encodedImageRequest)
//    let response = try request.wait()
//    let variants = response.images.map { $0.variantName }
//    let legacyImages = variants.filter { $0 == "legacy" }
//    XCTAssertEqual(legacyImages.count, 2)
//    let dynamicImages = variants.filter { $0 != "legacy" }
//    XCTAssertEqual(dynamicImages.count, 2)
//    XCTAssertEqual(response.images.count, 4)
  }
  
  
  
  
  static let allTests = [
    ("testDynamicImageRegex", testDynamicImageRegex),
    ("testReplaceDynamicImages", testReplaceDynamicImages),
    ("testLegacyImages", testLegacyImages),
    ("testFindImages", testFindImages)
  ]
  
}
