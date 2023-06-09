//
//  PublishController.swift
//  App
//
//  Created by Benjamin Nassler on 31/07/2019.
//

import Vapor


final class PublishController: ContentPublisher, CategoryPublisher, TokenAccessor, SlotPublisher {
  
  /// Legacy
  func updateCategory(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let request = try req.content.decode(UpdateCategoryRequest.self)
    return try self.getStoredToken(request: req).tryFlatMap { token -> EventLoopFuture<HTTPStatus> in
      
      return try self.update(category: request.category,
                             forAsset: request.contentAsset,
                             inCatalog: request.catalog,
                             token: token,
                             req: req)
      
    }
  }
  
  /// Publishes a single module
  func publishModule(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    print("renderModule(_:)")
    let renderer = RenderHelper(mode: .publishing)
    let renderRequest = try req.content.decode(RenderModuleRequest.self)
    var contentAssetDocument = ContentAssetDocument(online: ["default":true], body: [:])
    var renderingErrors = [DebuggableError]()
    /// Prepare
    let (renderedTemplatesFuture, errors) = renderer.render(req: req, modules: [renderRequest.module], templates: [renderRequest.template])
    print("Rendering errors: \(errors.count)")
    print("Requesting localizations...")
    return renderedTemplatesFuture.tryFlatMap { renderedTemplates -> EventLoopFuture<HTTPStatus> in
      var translationHelper = TranslationHelper(client: req.client)
      translationHelper.translationMatches = try translationHelper.findLocalizations(in: renderedTemplates)
      return try translationHelper.requestTranslations().tryFlatMap { translationResult -> EventLoopFuture<HTTPStatus> in
        translationHelper.translations = translationResult.translations
        renderingErrors.append(contentsOf: translationResult.translationErrors)
        /// Images
        let imageHelper = ImageHelper(mode: .publishing)
        let imageReplacementResult = try imageHelper.replaceDynamicImages(renderRequest.images, inHtml: renderedTemplates, webDAVPath: renderRequest.webDAVPath ?? "")
        renderingErrors.append(contentsOf: imageReplacementResult.missingImages)
        if (renderRequest.locales.count == 0) {
          throw RenderingError(module: renderRequest.module.id, reason: "locales was empty")
        }
        // locales: ["de-DE", ...]
        print("Rendering \(renderRequest.locales.count) locales")
        for locale in renderRequest.locales {
          print("Rendering \(locale)")
          var localizedMarkup = ""
          localizedMarkup = translationHelper.localize(
            imageReplacementResult.html,
            withTranslations: translationHelper.translations,
            locale: locale
          )
          //renderResponse[locale.id + "-" + country.id] = localizedTemplates
          contentAssetDocument.body[locale] = LocalizedMarkup(type: "markup_text", source: localizedMarkup)
        }
        // print("Compressed body down to \(contentAssetDocument.compressedBody.body.keys.count) locales")
        return try self.getStoredToken(request: req).tryFlatMap { token -> EventLoopFuture<HTTPStatus> in
          return try self.publish(content: contentAssetDocument,
                                     named: renderRequest.contentAssetName,
                                     req: req,
                                     token: token)
        }
      }
    }
    
  }
  
  /// Renders a content asset that references the other modules
  func publishManifest(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
    print("renderManifest(_:)")
    let manifestRequest = try req.content.decode(PublishManifestRequest.self)
    return try self.getStoredToken(request: req).tryFlatMap { token in
      return try self.publishManifest(manifestRequest,
                                      token: token,
                                      req: req)
    }
  }
  
  
  
  /// Renders a content asset that references the other modules
  func publishContentSlot(_ req: Request) throws -> EventLoopFuture<ClientResponse> {
    print("publishContentSlot(_:)")
    let request = try req.content.decode(SlotPublishRequest.self)
    return try self.getStoredToken(request: req).tryFlatMap { token in
      return try self.put(site: request.site,
                          slot: request.slot,
                          document: request.slotDocument,
                          token: token,
                          req: req)
    }
  }
  
}


