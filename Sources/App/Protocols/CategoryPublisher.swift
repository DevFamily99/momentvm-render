//
//  CategoryHelper.swift
//  App
//
//  Created by Benjamin Nassler on 21/05/2019.
//

import Foundation
import Vapor

struct CategoryDocument: Content {
  var contentAssetId: String
  enum CodingKeys: String, CodingKey {
    case contentAssetId = "c_velocityAssetID"
  }
}

/**
 
 Interface to SFCC OCAPI Category Ressource
 
 */
protocol CategoryPublisher {}

extension CategoryPublisher {
  
  var categoryUrl: String { return "/s/-/dw/data/v19_5/catalogs/" }

  func checkHeaders(request: Request) throws -> Void {
    guard request.hostExists else {
      throw Abort(.badRequest, reason: "missing 'Target-Host' in header")
    }
  }
  
  func update(category: String, forAsset name: String, inCatalog catalog: String, token: Token, req: Request) throws -> EventLoopFuture<HTTPStatus> {
    try self.checkHeaders(request: req)
    let document = CategoryDocument(contentAssetId: name)
    return try self.categoryExists(category, catalog: catalog, token: token, req: req).tryFlatMap { exists in
      if exists {
        return try self.patch(category: category, catalog: catalog, document: document, token: token, req: req)
      } else {
        throw Abort(.notFound)
      }
    }
  }

  
  func categoryExists(_ category: String, catalog: String, token: Token, req: Request) throws -> EventLoopFuture<Bool> {
    try self.checkHeaders(request: req)
    return try self.get(category: category, catalog: catalog, token: token, req: req).map() { response in
      if response.code == 200 {
        return true
      } else {
        return false
      }
    }
  }
  
  /// Low level api, you should probably use one of the higher level requests

      
  func patch(category: String, catalog: String, document: CategoryDocument, token: Token, req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let url = req.targetHost + self.categoryUrl + catalog + "/categories/" + category
    return req.client.patch(URI(string: url), headers: ["Authorization" : "Bearer \(token.token)"]) { request in
      try request.content.encode(document)
    }.map() { response in
      print("patched category \(category) - \(response.status.code)")
      return response.status
    }
  }
  
  func get(category: String, catalog: String, token: Token, req: Request) throws -> EventLoopFuture<HTTPStatus> {
    let url = req.targetHost + self.categoryUrl + catalog + "/categories/" + category
    return req.client.get(URI(string: url), headers: ["Authorization" : "Bearer \(token.token)"]).map() { response in
      return response.status
    }
  }
  
  
}
