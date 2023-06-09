//
//  PublishingHelper.swift
//  App
//
//  Created by Benjamin Nassler on 17/05/2019.
//


import Foundation
import Vapor

protocol ContentPublisher {}

extension ContentPublisher {
  var contentUrl: String { return "/s/-/dw/data/v19_5/libraries/" }
  
  /**
   Convenience method, handles saving the manifest file which loads all the modules
   
   - parameter name: The name of the manifest to publish
   - parameter modules: The module IDs that will be referenced
   */
  func publishManifest(_ manifestRequest: PublishManifestRequest, token: Token, req: Request) throws -> EventLoopFuture<HTTPStatus> {
    print(":publishManifest(_:token:req:)")
    var content = Array<String>()
    for module in manifestRequest.modules {
      content.append("$include('Page-Include', 'cid', '\(module)')$")
    }
    /// Construct all locales. We need to publish in the specific locales to different pages can publish different manifests
    var body: [String:LocalizedMarkup] = [:]
    // body["default"] = LocalizedMarkup(source: content.joined().decoratedWithWrapper)
    for locale in manifestRequest.locales {
      body[locale] = LocalizedMarkup(source: content.joined())
    }
    let contentAssetDocument = ContentAssetDocument(online: ["default" : true], body: body)
    /// If some attributes exist we need to translate them
    return try self.translateAttributes(manifestRequest: manifestRequest,
                                        contentAsset: contentAssetDocument,
                                        req: req).tryFlatMap { modifiedAssetDocument in
                                          return try self.publish(content: modifiedAssetDocument,
                                                                     named: manifestRequest.manifest,
                                                                     req: req,
                                                                     token: token)
                                        }
  }
  
  
  /**
   Convenience method, handles getting content, patching it etc
   
   - parameter token: a string like: 12345678-1234-1234-1234-12345678. The "Bearer" is omitted
   - parameter content: a ContentAssetDocument
   - returns: HTTPStatus if it was successful
   */
  func publish(content: ContentAssetDocument, named name: String, req: Request, token: Token) throws -> EventLoopFuture<HTTPStatus> {
    let exists = try self.contentExists(name: name, token: token, req: req)
    return exists.tryFlatMap { existsResponse in
      if existsResponse {
        return try self.patch(req: req, name: name, content: content, token: token)
      } else {
        return try self.put(req: req, name: name, content: content, token: token)
      }
    }
  }
  
  /**
   Will request translations for the content asset attributes and return a modified asset
   */
  private func translateAttributes(manifestRequest: PublishManifestRequest, contentAsset: ContentAssetDocument, req: Request) throws -> EventLoopFuture<ContentAssetDocument> {
    var modifiedAsset = contentAsset
    var translationHelper = TranslationHelper(client: req.client)
    /// Find the localization IDs and request a translation
    if let pageURL = manifestRequest.pageURL {
      translationHelper.translationMatches.append(String(pageURL))
    }
    if let pageDescription = manifestRequest.pageDescription {
      translationHelper.translationMatches.append(String(pageDescription))
    }
    if let pageKeywords = manifestRequest.pageKeywords {
      translationHelper.translationMatches.append(String(pageKeywords))
    }
    if let pageTitle = manifestRequest.pageTitle {
      translationHelper.translationMatches.append(String(pageTitle))
    }
    /// If none of them requires requesting the translations, we just return the original asset
    if (manifestRequest.pageDescription == nil &&
          manifestRequest.pageKeywords == nil &&
          manifestRequest.pageTitle == nil &&
          manifestRequest.pageURL == nil) {
      return req.eventLoop.future(contentAsset)
    }
    /// If not we request translations
    return try translationHelper.requestTranslations().map() { translationResult in
      /// Check if a translation was found and if so attach it
      if let pageURL = manifestRequest.pageURL {
        if let translation = translationResult.translations.first(where: {$0.translationID == pageURL }) {
          modifiedAsset.pageURL = translation.body
        }
      }
      if let pageDescription = manifestRequest.pageDescription {
        if let translation = translationResult.translations.first(where: {$0.translationID == pageDescription }) {
          modifiedAsset.pageDescription = translation.body
        }
      }
      if let pageKeywords = manifestRequest.pageKeywords {
        if let translation = translationResult.translations.first(where: {$0.translationID == pageKeywords }) {
          modifiedAsset.pageKeywords = translation.body
        }
      }
      if let pageTitle = manifestRequest.pageTitle {
        if let translation = translationResult.translations.first(where: {$0.translationID == pageTitle }) {
          modifiedAsset.pageTitle = translation.body
        }
      }
      return modifiedAsset
    }
  }
  
  /// Uses the desired countries and picks them and the locales from a given Site list
  /// The Site list at this point contains all the sites with its locales
  private func localeList(countries: Array<String>, in sites: Array<Site>) throws -> Array<String> {
    var localeList: Array<String> = []
    for countryString in countries {
      let countryResult = sites.filter { $0.id == countryString }
      guard let country = countryResult.first else {
        throw Abort(.badRequest, reason: "Country not found in sites")
      }
      // Iterate through locales
      for locale in country.locales {
        localeList.append("\(locale.id)-\(countryString)")
      }
    }
    return localeList
  }
  
  /// Not private, but rather use the convenience methods above
  
  func put(req: Request, name: String, content: ContentAssetDocument, token: Token) throws -> EventLoopFuture<HTTPStatus> {
    let url = try URI(withUnsafeString: req.targetHost + self.contentUrl + req.defaultLibrary + "/content/" + name)
    return req.client.put(url, headers: ["Authorization" : "Bearer \(token.token)"]) { putRequest in
      try putRequest.content.encode(content)
    }.map() { response in
      print("put \(name) - \(response.status.code)")
      // print("Error: \(response.debugDescription)")
      return response.status
    }
  }
  
  func patch(req: Request, name: String, content: ContentAssetDocument, token: Token) throws -> EventLoopFuture<HTTPStatus> {
    let url = try URI(withUnsafeString: req.targetHost + self.contentUrl + req.defaultLibrary + "/content/" + name)
    return req.client.patch(url, headers: ["Authorization" : "Bearer \(token.token)"]) { patchRequest in
      try patchRequest.content.encode(content)
    }.map() { response in
      print("patched \(name) - \(response.status.code)")
      return response.status
    }
  }
  
  func contentExists(name: String, token: Token, req: Request) throws -> EventLoopFuture<Bool> {
    print("contentExists(name:token:req:")
    try protectFromFaultyHeader(req: req)
    //    print("targethost: \(req.targetHost)")
    //    print("contentUrl: \(self.contentUrl)")
    //    print("default lib: \(req.defaultLibrary)")
    //    print("name: \(name)")
    let url = try URI(withUnsafeString: req.targetHost + self.contentUrl + req.defaultLibrary + "/content/" + name)
    let resp = req.client.get(url, headers: ["Authorization" : "Bearer \(token.token)"])
    let exists = resp.map() { response -> Bool in
      if response.status.code == 200 {
        return true
      } else {
        return false
      }
    }
    return exists
  }
  
  /**
   Parses request headers to extract path and targetHost, if fails will throw
   */
  private func protectFromFaultyHeader(req: Request) throws -> Void {
    guard req.targetHost != "" else {
      throw Abort(.badRequest, reason: "Target-Host header emtpy")
    }
    guard req.defaultLibrary != "" else {
      throw Abort(.badRequest, reason: "Default Library header empty")
    }
    return
  }
  
  
}



