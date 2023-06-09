//
//  PublishingHelper.swift
//  App
//
//  Created by Benjamin Nassler on 17/05/2019.
//


import Foundation
import Vapor

// protocol ContentPublisher {}

extension ContentAssetDocument {
  
  
  var compressedBody: ContentAssetDocument {
    var newAsset = self
    newAsset.body = self.compress(body: self.body)
    return newAsset
  }
  
  fileprivate func compress(body: [String: LocalizedMarkup]) -> [String: LocalizedMarkup] {
    /// To compress the body we weed out all the localizations that have a more less variant
    /// which is the same. So if the markup for de-DE is the same as de, we dont need de
    var newBody: [String: LocalizedMarkup] = [:]
    for (locale, markup) in body {
      /// default we just take over
      if (locale == "default") {
        newBody["default"] = markup
        continue
      }
      /// de-DE
      if (locale.count > 2) {
        let lang = String(locale.prefix(2))
        /// If the language body is the same we can omit the more specific one
        let languageBasedPair = body[lang]
        if markup == languageBasedPair {
          continue
        }
        /// Also check for default
        guard let defaultMarkup = body["default"] else {
          continue
        }
        if markup == defaultMarkup {
          continue
        }
        /// Its unique so we add it to the dict
        newBody[locale] = markup
      }
      /// de
      if (locale.count == 2) {
        let lang = "default"
        /// If the language body is the same we can omit the more specific one
        let languageBasedPair = body[lang]
        if markup == languageBasedPair {
          continue
        }
        /// Unique, add it to the dict
        newBody[locale] = markup
      }
    }
    return newBody
  }
  
  
}



