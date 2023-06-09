//
//  RenderController.swift
//  App
//
//  Created by Benjamin Nassler on 24.04.18.
//

import Vapor
import Leaf
// import Authentication

/// Controlers basic CRUD operations on `Todo`s.
final class RenderController: RedisAccessor {
  
  
  
  /// The main method to preview a page
  /// First we render the modules with their templates. Then we search for translations and images in the content and request them.
  ///
  /// Images are requested from the main app and translations from the Translation Service as a list
  /// - Parameter req: The incoming Request
  func preview(_ req: Request) throws -> EventLoopFuture<String> {
    print("preview(_:)")
    guard req.authenticated else {
      throw Abort(.forbidden, reason: "Not authenticated")
    }
    let renderer = RenderHelper(mode: .preview)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let previewRequest = try req.content.decode(PreviewRequest.self, using: decoder)
    print("\(previewRequest.modules.count) modules.")
    print("\(previewRequest.nestedModules.count) nested modules.")
    // renderedTemplates is a future
    var (renderedTemplatesFuture, errors) = renderer.render(
      req: req,
      modules: previewRequest.modules,
      templates: previewRequest.templates
    )
    return renderedTemplatesFuture.tryFlatMap { renderedTemplates in
      var translationHelper = TranslationHelper(client: req.client)
      translationHelper.translationMatches = try translationHelper.findLocalizations(in: renderedTemplates)
      
      return try translationHelper.requestTranslations().tryFlatMap { translationResult in
        translationHelper.translations = translationResult.translations
        errors.append(contentsOf: translationResult.translationErrors)
        let localizedTemplates = translationHelper.localize(
          renderedTemplates,
          withTranslations: translationHelper.translations,
          locale: previewRequest.configuration.localeToRender
        )
        /// Images
        let imageHelper = ImageHelper(mode: .preview)
        let imageReplacementResult = try imageHelper.replaceDynamicImages(
          previewRequest.images,
          inHtml: localizedTemplates
        )
        errors.append(contentsOf: imageReplacementResult.missingImages)
        /// Widgets
        let widgetHelper = WidgetHelper(request: req)
        let widgetMatches = try renderedTemplates.matches(
          forPattern: "\\$include\\((.*?)\\)\\$",
          captureGroup: 1
        )
        return try widgetHelper.replaceWidgetPlaceholders(
          imageReplacementResult.html,
          placeholders: widgetMatches,
          locale: previewRequest.configuration.localeToRender,
          req: req
        ).map { widgetText in
          let errorString = errors.map { error in error.localizedDescription }.joined(separator: "<br />")
          return errorString + widgetText
        }
      }
    }
  }
  
  /// Pure rendering and return images found
  /// Handling of legacy images: Will find them with a "legacy" variant name
  func findImages(_ req: Request) throws -> EventLoopFuture<ImageMatchesContainer> {
    print("findImages(_:)")
    guard req.authenticated else {
      throw Abort(.forbidden, reason: "Not authenticated")
    }
    let renderer = RenderHelper(mode: .preview)
    let previewRequest = try req.content.decode(FindImagesRequest.self)
    print("\(previewRequest.modules.count) modules.")
    let (renderedTemplates, renderErrors) = renderer.render(req: req, modules: previewRequest.modules, templates: previewRequest.templates)
    // Find legacy images and dynamic images
    if renderErrors.count > 0 { print(renderErrors) }
    return renderedTemplates.flatMapThrowing { renderedString -> ImageMatchesContainer in
      // Legacy
      var legacyImageMatches = try renderedString.matches(forPattern: "(i|I)mg::(.*?)::", captureGroup: 2)
      legacyImageMatches = Array(Set(legacyImageMatches)) // Make unique
      // Dynamic
      let dynamicImageMatches = try renderedString.dynamicImageMatches()
      // For the legacy images, we now also return dynamicImages
      var outImages: DynamicImageMatches = dynamicImageMatches
      let flatDynamicImages = dynamicImageMatches.map { $0.name }
      for image in legacyImageMatches {
        // Check if the image is already in the dynamic image list
        if !flatDynamicImages.contains(image) {
          // for legacy images we return legacy as an imageSize
          outImages.append(DynamicImageMatch(name: image, rawMatch: image, variantName: "legacy"))
        }
      }
      print("images: \(outImages.count)")
      return ImageMatchesContainer(images: outImages)
    }
    
  }
  
  
}


