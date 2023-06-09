//
//  RenderHelper.swift
//  RenderService
//
//  Created by Benjamin Nassler on 17.06.17.
//
//

import Vapor
// import HTTP
import Leaf
import LeafKit
import Foundation
import Redis
// import SwiftyJSON
import JSON

struct CustomKey: CodingKey {
  var stringValue: String

  init(stringValue: String) {
    self.stringValue = stringValue
    self.intValue = nil
  }

  var intValue: Int?

  init?(intValue: Int) {
    self.intValue = 0
    self.stringValue = ""
  }


}


struct RenderedNestedModule {
  var id: Int
  var renderedBody: String

  init(id: Int, renderedBody: String) {
    self.id = id
    self.renderedBody = renderedBody
  }
}

/**
 extension TemplateRenderer {

 Convenience method to render a View using a template String and TemplateData as context
 - Parameter template: String
 - Parameter context: TemplateData
 */
/// Renders Modules and Templates to HTML
final class RenderHelper {
  var renderer: LeafRenderer!
  var rendersWrapper = true
  var mode: RenderType

  init(mode: RenderType) {
    self.mode = mode
  }

  private func findNestedModuleIds(moduleTemplateData: JSON) -> Array<String> {
    do {
      let regex = try! NSRegularExpression(pattern: "nested::(.*)::")
      let nsString = moduleTemplateData.description as NSString
      let range = NSRange(location: 0, length: nsString.length)
      let matches = regex.matches(in: moduleTemplateData.description, range: range)
      return matches.map { match in
        return nsString.substring(with: match.range(at:1))
      }
    } catch  {
      return []
    }
  }


  /// Render single module
  private func render(req: Request, module: ContentModule, usingTemplate template: ContentTemplate) throws -> EventLoopFuture<String> {
    // print("\(template.id) (template ID)")
    guard let moduleDataJSON = module.body.asJSON else {
      throw RenderingError(module: module.id, reason: "Could not parse module body as JSON")
    }
    var moduleTemplateData = moduleDataJSON
    /// Serializing the template is the most expensive operation
    /// Therefore we include an updated date to add to the key
    //let hashedDateOpt = template.updatedAt.rfc1123.data(using: .utf8)
    let combinedName = template.name + template.updatedAt
    guard let combinedNameData = combinedName.data(using: .utf8) else {
      throw Abort(.badRequest, reason: "Could not create a hash out of the template updated_at date")
    }
    /// The key for the rendered template html, serialized into a vapor construct
    let templateCacheKey = String(SHA256.hash(data: combinedNameData).hashValue) // String(SHA256.hash(data: hashedDate).hashValue)
    // print(cacheKeyTemplateName)
    /// If the secondaryBody is filled it will be preferred
    var templateBody = ""
    if mode == .publishing && template.secondaryBody.count > 1 {
      templateBody = template.secondaryBody
    } else {
      templateBody = template.body
    }
    /// Removes preview or publishing tags
    switch self.mode {
    case .preview:
      templateBody = templateBody.strippedForPreview
    case .publishing:
      templateBody = templateBody.strippedForPublishing
    }
    req.application.dynamicSource.insert(templateName: templateCacheKey, value: templateBody)

    /// Custom variables
    moduleTemplateData.set(["module_id"], to: JSON(module.id))
    moduleTemplateData.set(["template_name"], to: JSON(template.name))
    moduleTemplateData.set(["random_number"], to: JSON(String(Int.random(in: 0 ... 99999))))

    // Check if module data contains nested templates
    let nestedModuleIds = findNestedModuleIds(moduleTemplateData: moduleTemplateData)
    for nestedModuleId in nestedModuleIds {
      let rendered  = try renderNested(req: req, moduleId: nestedModuleId).whenComplete { result in
              switch result {
              case .success(let renderedNestedTemplate):               
                moduleTemplateData.set([nestedModuleId], to: JSON(renderedNestedTemplate))
              case .failure(let error):
                print(error)
              }
      }
    }
   

    let view = req.view.render(templateCacheKey, moduleTemplateData)
    // req.application.leaf.cache.remove(cacheKeyTemplateName)

    return view.flatMapThrowing { value -> String in
      let returnValue: String = String(buffer: value.data)
      switch (self.rendersWrapper, template.secondaryBody.count > 1) {
      case (true, false):
        return Decorator.decorateRenderedModule(returnValue, withMarkersForModule: module, template: template)
      default:
        return returnValue
      }
    }.flatMapError { error in
      print("view rendering error. Caused by template \(template.id)")
      return req.eventLoop.makeSucceededFuture("<h1>\(template.id) is broken</h1>")
    }

    /// Insert custom variables to be available in the template
    // TODO add system tags again
    //    moduleTemplateData.set(to: LeafKit.LeafData(stringLiteral: String(module.id)), at: [CustomKey(stringValue: "module_id")])
    //    moduleTemplateData.set(to: LeafKit.LeafData(stringLiteral: String(template.name)), at: [CustomKey(stringValue: "template_name")])
    //    moduleTemplateData.set(to: LeafKit.LeafData(stringLiteral: String(Int.random(in: 0 ... 99999))), at: [CustomKey(stringValue: "random_number")])
    //    /// Register custom tags
    //     var tags = LeafTagConfig.default()
    //     tags.use(ProductLinkTag(), as: "product_url")
    //     tags.use(CategoryLinkTag(), as: "category_url")
    //     tags.use(CountStringLengthTag(), as: "count_characters")
    // let container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: EmbeddedEventLoop())
    //     let viewsDir = "/" + #file.split(separator: "/").dropLast(3).joined(separator: "/").finished(with: "/Views/")
    //     let config = LeafConfiguration(rootDirectory: "")
    //
    //
    //
    //    let template = "hello #(world)"
    //    var lexer = LeafLexer(name: "test-parseasdf", template: template)
    //    let tokens = try! lexer.lex()
    //
    //    var parser = LeafParser(name: "test-parseasdf", tokens: tokens)
    //    let ast = try! parser.parse()
    //
    //
    //
    //    var renderer = LeafRenderer(configuration: config, tags: [:], cache: LeafCache(), sources: .init(), eventLoop: EmbeddedEventLoop(), userInfo: [:])
    // renderer = LeafRenderer(config: config, using: container)



  }


  // Render nested template
  private func renderNested(req: Request, moduleId: String) throws ->  EventLoopFuture<String> {
    do {
      
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let previewRequest = try req.content.decode(PreviewRequest.self, using: decoder)
      let templates = previewRequest.templates
      let nestedModuleResult = previewRequest.nestedModules.filter { String($0.id) == moduleId }
      guard let nestedModule = nestedModuleResult.first else {
        throw RenderingError(module: 0, reason: "Could not find nested module")
      }
      let templateResult = templates.filter { $0.id == nestedModule.template_id }
      guard let template = templateResult.first else {
        throw RenderingError(module: nestedModule.id, reason: "Could not find template for nested module")
      }
      let renderedNestedTemplate = try self.render(req: req, module: nestedModule, usingTemplate: template)
      return renderedNestedTemplate
    } catch  {
      throw RenderingError(module: 0, reason: "Nested render failed")
    }
   
  }



  /// Render module list
  /// Returns renderedBody: String, List of Errors which occured
  func render(req: Request, modules: Array<ContentModule>, templates: Array<ContentTemplate>) -> (EventLoopFuture<String>, Array<Error>) {
    var errors: Array<Error> = []
    var renderedTemplates: [EventLoopFuture<String>] = []

    // Render the pages modules
    for module in modules {
      let templateResult = templates.filter { $0.id == module.template_id }
      guard let template = templateResult.first else {
        continue
      }
      do {
        let renderedTemplate = try self.render(req: req, module: module, usingTemplate: template)
        renderedTemplates.append(renderedTemplate)
      }
      catch {
        print("Error in template \(module.template_id)")
        print("error description: \(error.localizedDescription)")
        //print("Template: \(template.body)")
        //print(str)
        //print("error: \(currentTemplateResult.id) \(currentTemplateResult.name) - \(module.id)")
        //print(module.body)
        errors.append(RenderingError(module: module.template_id, reason: error.localizedDescription))
      }
    }
    let combinedTemplateFuture = renderedTemplates.flatten(on: req.eventLoop).map { renderedTemplateValues -> String in
      var renderedHtml = renderedTemplateValues.joined(separator: "")
      if renderedTemplates.count == 0 && self.mode == .preview {
        renderedHtml = """
      <div class="cms-placeholder">
      <h2 style="padding: 20px;text-align: center">
      👈 Add a first module using the editor
      </h2>
      </div>
      """
      }
      return renderedHtml
    }
    return (combinedTemplateFuture, errors)
  }
}
