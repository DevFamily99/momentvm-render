//
//  CategoryHelper.swift
//  App
//
//  Created by Benjamin Nassler on 21/05/2019.
//

import Foundation
import Vapor

/**
 
 Interface to SFCC OCAPI Slot Ressource
 
 */
protocol SlotPublisher {}

/// The type of the slot document type
enum SlotContextType: String, Codable {
  case products = "products"
  case category = "category"
  case contentAssets = "content_assets"
  case html = "html"
}

struct SlotScheduleContent: Content {
  var startDate: Date
  var endDate: Date
  enum CodingKeys: String, CodingKey {
    case startDate = "start_date"
    case endDate = "end_date"
  }
}

/// The content embedded in a SlotDocument
struct SlotContent: Content {
  var type: SlotContextType // Enum {products, categories, content_assets, html, recommended_products}
  var body: String? // The HTML body (valid only for type 'html').
  var contentAssetIds: Array<String>?
  enum CodingKeys: String, CodingKey {
    case type
    case body
    case contentAssetIds = "content_asset_ids"
  }
}

/// The slot document ressource. Set as body in slot api interactions
struct SlotConfigurationDocument: Content {
  var context: SlotContextType?
  var customerGroups: [String]?
  var enabled: Bool?
  var rank: Int?
  var description: String?
  var slotContent: SlotContent
  var schedule: SlotScheduleContent?
  enum CodingKeys: String, CodingKey {
    case context
    case customerGroups = "customer_groups"
    case enabled
    case rank
    case description
    case slotContent = "slot_content"
    case schedule
  }
}

extension SlotPublisher {
  
  /// Makes sure the needed request headers are present or throws
  func checkHeaders(request: Request) throws -> Void {
    guard request.hostExists else {
      throw Abort(.badRequest, reason: "missing 'Target-Host' in header")
    }
  }
  
  /// Constructs the OCAPI URL to publish to
  /// Not quite sure why we need the context="category"
  func url(forSite site: String, slot: String, context: String, configuration: String) -> String {
    return "/s/-/dw/data/v19_5/sites/\(site)/slots/\(slot)/slot_configurations/\(configuration)?context=\(context)"
  }
  
  
  // MARK: - Low level API -
  /// You should probably use one of the higher level requests
  
  
  ///
  ///  Updates a content slot with PUT
  ///
  func put(site: String, slot: String, document: SlotConfigurationDocument, token: Token, req: Request) throws -> EventLoopFuture<ClientResponse> {
    try self.checkHeaders(request: req)
    let url = try URI(withUnsafeString: "https://" + req.targetHost + self.url(forSite: site, slot: slot, context: "category", configuration: "foobar"))
    req.headers = ["Authorization" : "Bearer \(token.token)"]
    let putResponse = req.client.put(url, headers: ["Authorization" : "Bearer \(token.token)"]) { request in
      try request.content.encode(document)
      }.map() { response -> ClientResponse in
        print("put slot - \(response.status.code)")
        return response
    }
    return putResponse
  }
  
  
  
}
