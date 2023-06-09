//
//  ImageHelper.swift
//  App
//
//  Created by Benjamin Nassler on 26.05.18.
//

import Foundation
import Vapor

/// Interacts with the Main App
///
///

typealias ImageErrorCallback = (ImageMissingErrors) -> Void

struct ImageHelper {
  
  var mode: RenderType
  
  init(mode: RenderType) {
    self.mode = mode
  }
  
 /**
   Replace DynamicImage placeholders with the correct variant url
   webDAVPath is optional (for example for previewing)
   **/
  func replaceDynamicImages(_ images: DynamicImages, inHtml html: String, webDAVPath: String = "") throws -> ImageReplacementResult {
    var processedHtml = html
    var missingImages: ImageMissingErrors = []
    let matches = try html.dynamicImageMatches()
    for match in matches {
      // Handle image missing
      guard let image = images.first(where: { $0.name == match.name }) else {
        missingImages.append(ImageMissingError(name: match.name, variantName: match.variantName))
        continue
      }
      // Handle variant is missing
      guard let variant = image.variants!.first(where: { $0.name == match.variantName }) else {
        missingImages.append(ImageMissingError(name: match.name, variantName: match.variantName))
        continue
      }
      let replacementString = "dynamicimage::\(variant.name):\(image.name)::"
      switch self.mode {
      case .preview:
        processedHtml = processedHtml.replacingOccurrences(
          of: replacementString,
          with: variant.url
        )
      case .publishing:
        /// TODO: Fix fileending
        processedHtml = processedHtml.replacingOccurrences(
          of: replacementString,
          with: "\(self.sanitizedWebDAVPath(webDAVPath: webDAVPath))/\(image.name)__\(variant.name)\(image.fileEnding)?$staticlink$"
        )
      }
    }
    return ImageReplacementResult(html: processedHtml, missingImages: missingImages)
  }
 
  /// Extract the relative folder path from the entire url
  private func sanitizedWebDAVPath(webDAVPath: String) -> String {
     do {
       let matches = try webDAVPath.matches(forPattern: #"webdav\/Sites\/Libraries.*?default\/(.*?)\Z"#, captureGroup: 1)
       guard let firstMatch = matches.first else {
         return ""
       }
       return firstMatch
     } catch {
       return ""
     }
   }
  
  
}


