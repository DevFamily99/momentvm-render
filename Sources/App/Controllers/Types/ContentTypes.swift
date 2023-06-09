//
//  ContentModule.swift
//  App
//
//  Created by Benjamin Nassler on 24.04.18.
//

import Vapor
import Leaf
import Redis

enum RenderType: String {
  case publishing = "publishing"
  case preview = "preview"
}

/// The Response from the rendering
///
/// Contains a renderedContent [locale : String] and renderingErrors
struct RenderResponse: Content {
  var renderedContent: [String : String]
  var renderingErrors: [String]
  enum CodingKeys: String, CodingKey {
    case renderedContent = "rendered_content"
    case renderingErrors = "rendering_errors"
  }
}

// MARK: - Main Request -

/// The main Request
struct PreviewRequest: Content {
  var modules: ContentModules
  var nestedModules: ContentModules
  var templates: ContentTemplates
  var sites: [Site]?
  var images: DynamicImages
  var configuration: PreviewConfiguration
  enum CodingKeys: String, CodingKey {
    case modules = "modules"
    case nestedModules = "nested_modules"
    case templates = "templates"
    case sites = "sites"
    case images = "images"
    case configuration = "configuration"
  }
}

struct ImageRequest: Content {
  var images: Array<String>
}

/// The main Request
struct RenderRequest: Content {
  var modules: ContentModules
  var templates: ContentTemplates
  var images: DynamicImages
  var sites: [Site] // All sites
  var configuration: RenderingConfiguration
  var webDAVPath: String?
  enum CodingKeys: String, CodingKey {
    case modules
    case templates
    case images
    case sites
    case configuration
    case webDAVPath = "webdav_path"
  }
}

/// The main Request
struct RenderModuleRequest: Content {
  var contentAssetName: String
  var module: ContentModule
  var template: ContentTemplate
  var images: DynamicImages
  /// "de-DE"
  var locales: [String]
  var webDAVPath: String?
  enum CodingKeys: String, CodingKey {
    case contentAssetName = "content_asset_name"
    case module
    case template
    case images
    case locales
    case webDAVPath = "webdav_path"
  }
}

/// The request to update a content asset reference in a category
struct UpdateCategoryRequest: Content {
  var category: String
  var catalog: String
  var contentAsset: String
  enum CodingKeys: String, CodingKey {
    case category
    case catalog
    case contentAsset = "content_asset"
  }
}

struct PublishManifestRequest: Content {
  var manifest: String // name
  var modules: Array<String>
  var locales: [String]
  
  // These are all localization keys
  var pageURL: Int?
  var pageTitle: Int?
  var pageDescription: Int?
  var pageKeywords: Int?
  
  enum CodingKeys: String, CodingKey {
    case manifest
    case modules
    case locales
    case pageURL = "page_url"
    case pageTitle = "page_title"
    case pageDescription = "page_description"
    case pageKeywords = "page_keywords"
  }
}

struct Grant: Content {
  var grantType: String
  enum CodingKeys: String, CodingKey {
    case grantType = "grant_type"
  }
}

struct SlotPublishRequest: Content {
  var slotDocument: SlotConfigurationDocument
  var site: String
  var category: String
  var slot: String
  enum CodingKeys: String, CodingKey {
    case slotDocument = "slot_document"
    case site
    case category
    case slot
  }
}



/**
 *
 *  Persisted in Redis like so:
 *  <last 4 characters of client ID>$<token>$<Expiry Date>
 *
 */
struct Token: Content {
  var client: String
  var token: String
  var expiresIn: Date
}

/*
extension Token: RedisDataConvertible {
  
  static func convertFromRedisData(_ data: RedisData) throws -> Token {
    guard
      let list = data.array,
      let client = list[0].string,
      let token = list[1].string,
      let dateString = list[2].string,
      let date = Date.init(rfc1123: dateString)
      else {
        throw InconsistencyError(reason: "could not parse redis data to string")
    }
    return Token(client: client, token: token, expiresIn: date)
  }
  
  func convertToRedisData() throws -> RedisData {
    let client = try self.client.convertToRedisData()
    let token = try self.token.convertToRedisData()
    let expiresIn = try self.expiresIn.rfc1123.convertToRedisData()
    let redisData: RedisData = RedisData(arrayLiteral: [
      client,
      token,
      expiresIn
    ])
    return redisData
  }
}
*/
extension Token {
  var isValid: Bool {
    let now = Date()
    if self.expiresIn < now {
      return false
    } else {
      return true
    }
  }
}


/// The token response from SFCC
struct TokenResponse: Content {
  var accessToken: String
  var scope: String
  var tokenType: String
  var expiresIn: Int /// Seconds from when token was issued
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case scope
    case tokenType = "token_type"
    case expiresIn = "expires_in"
  }
}

/// A Module
struct ContentModule: Content {
  // var localeBlackList: String
  var body: String
  //var page_id: Int
  var id: Int
  var rank: String
  var template_id: Int
  // var schedule: String
}
typealias ContentModules = Array<ContentModule>
/// A Template
struct ContentTemplate: Content {
  var name: String
  var body: String
  var secondaryBody: String
  var id: Int
  var createdAt: String
  var updatedAt: String
  enum CodingKeys: String, CodingKey {
    case name
    case body
    case secondaryBody = "secondary_body"
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}
typealias ContentTemplates = Array<ContentTemplate>
/// Config Publishing
struct RenderingConfiguration: Content {
  var countries: [String] // To render
  var velocity: Bool
}
/// Config Preview
struct PreviewConfiguration: Content {
  var localeToRender: String
  var site: String
  enum CodingKeys: String, CodingKey {
    case localeToRender = "locale"
    case site
  }
}

struct Locale: Content {
  var id: String
  var name: String
  enum CodingKeys: String, CodingKey {
    case id = "locale"
    case name
  }
}

struct Site: Content {
  var name: String
  var id: String
  var locales: Array<Locale>
}

struct Widget: Content{
  var name: String
  var placeholder: String
  var content: String
}

// MARK: - Translation -

struct Translation: Content {
  var body: [String : String]
  var createdAt: String
  var updatedAt: String
  var translationID: Int
  enum CodingKeys: String, CodingKey {
    case body
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case translationID = "id"
  }
}

/// Contains both translations and TranslationErros (for example translations which couldnt be found)
///
/// Used as a convenient wrapper around the acutal API call
struct TranslationResult: Content {
  var translations: Array<Translation>
  var translationErrors: Array<TranslationError>
}

/// A request to an API requesting a list of translations
struct TranslationListResponse: Content {
  var message: String
  var translations: Array<Translation>
}
struct TranslationListRequest: Content {
  var translations: Array<String>
}

struct ImageVariant: Content {
  var sizeName: String
  var path: String
  enum CodingKeys: String, CodingKey {
    case sizeName = "size_name"
    case path = "path"
  }
}
typealias ImageVariants = Array<ImageVariant>


/// Legacy
struct Image: Content {
  var id: Int
  var name: String
  var imageFileName: String
  var imageFileSize: Int
  var imageURLMedium: String
  var imageURLMobile: String
  var imageURLTablet: String
  var imageURLHigh: String
  var fileEnding: String // format: .jpg
  var variants: ImageVariants?
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case imageFileName = "image_file_name"
    case imageFileSize = "image_file_size"
    case imageURLMedium = "image_url_medium"
    case imageURLMobile = "image_url_mobile"
    case imageURLTablet = "image_url_tablet"
    case imageURLHigh = "image_url_high"
    case fileEnding = "file_ending"
    case variants = "variants"
  }
}
typealias Images = Array<Image>

/// Represents a match of a variant of a DynamicImage
struct DynamicImageMatch: Content {
  var name: String
  var rawMatch: String
  var variantName: String
  
  enum CodingKeys: String, CodingKey {
    case name = "name"
    case rawMatch = "raw_match"
    case variantName = "variant_name"
  }
}


/// A regex match for a dynamic image
struct DynamicImage: Content {
  // the raw query like img:large:my_image_name:
  var name: String
  var fileEnding: String
  var variants: Variants?

  struct Variant: Content {
    var name: String
    var url: String
  }
  
  enum CodingKeys: String, CodingKey {
    case name
    case variants
    case fileEnding = "file_ending"
  }
}
typealias DynamicImages = Array<DynamicImage>
typealias DynamicImageMatches = Array<DynamicImageMatch>
typealias Variants = Array<DynamicImage.Variant>


// Deprecate
struct ImageListResponse: Content {
  var assets: Images
  var message: String
}




struct FindImagesRequest: Content {
  var modules: ContentModules
  var nestedModules: ContentModules
  var templates: ContentTemplates
}
/// A response for images found.
/// Now the response is simplified and only returns DynamicImages
/// Legacy images will be returned as a DynamicImage with imageSize of value "legacy"
/// - It contains an array of DynamicImages which were found in the html
struct ImageMatchesContainer: Content {
  var images: DynamicImageMatches
}

struct WidgetResponse: Content {
  var widgetId: Int
  var content: String
}

struct WidgetRequest {
  var type: String
  var parameter: String
  var response: EventLoopFuture<ClientResponse>
  var placeholder: String
}

struct ImageReplacementResult {
  var html: String
  var missingImages: ImageMissingErrors
}




/// The request body that OCAPI accepts for writing content
struct ContentAssetDocument: Content {
  var online: [String:Bool]?
  var body: [String:LocalizedMarkup]
  var pageURL: [String:String]?
  var pageTitle: [String:String]?
  var pageDescription: [String:String]?
  var pageKeywords: [String:String]?
  
  enum CodingKeys: String, CodingKey {
    case online
    case body = "c_body"
    case pageURL = "page_url"
    case pageTitle = "page_title"
    case pageDescription = "page_description"
    case pageKeywords = "page_keywords"
  }
}


/**
 
 body markup needs to be wrapped with source and type
 
 ```json
 {
 "default": {
 "_type": "markup_text",
 "source": " <!-- the html goes here -->"
 },
 "de-DE" : …
 }
 ```
 
 */
struct LocalizedMarkup: Content, Equatable {
  var type: String
  var source: String
  
  init(type: String, source: String) {
    self.type = type
    self.source = source
  }
  init(source: String) {
    self.source = source
    self.type = "markup_text"
  }
  
  enum CodingKeys: String, CodingKey {
    case type = "_type"
    case source
  }
}
