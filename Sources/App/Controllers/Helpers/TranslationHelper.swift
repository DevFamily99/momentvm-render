//
//  TranslationHelper.swift
//  App
//
//  Created by Benjamin Nassler on 20.05.18.
//

import Foundation
import Vapor

typealias TranslationErrorCallback = (TranslationErrors) -> Void


/// Interacts with the Translation Service
///
/// Uses a mode to decide how to cope with the locale fallback. E.g. in preview mode we want to see a realistic preview
/// and therefore fall through the locales. For publishing we want to only render a certain locale
///
/// - requestTranslations
/// - localize
struct TranslationHelper {
  
  var translationMatches: Array<String> = []
  var translations: Array<Translation> = []
  var client: Client
  
  func findLocalizations(in text: String) throws -> Array<String> {
    var matches = try text.matches(forPattern: "loc::([0-9]+)", captureGroup: 1)
    matches = Array(Set(matches)) // unique
    return matches
  }
  
  func findMinimalLocales() -> Array<String> {
    let locales = self.translations.map { translation in translation.body.map { localeBodyPair in localeBodyPair.key}}.flatMap { $0 }
    var newLocales: [String] = []
    for locale in locales {
      if (locale == "default") {
        newLocales.append(locale)
        continue
      }
      /// Language locale, check if a more specific one exists
      switch locale.count {
      case 2:
        /// How many specific locales like de-DE do we find?
        let moreSpecificMatches = locales.filter {
          $0.starts(with: locale)
            && $0.count > 2
            && $0 != "default" }
        if moreSpecificMatches.count > 0 {
          continue
        } else {
          newLocales.append(locale)
        }
      default:
        /// Specific locale which we need to return
        newLocales.append(locale)
      }
    }
    return []
  }
  
  /// Convenience
  func requestTranslations() throws -> EventLoopFuture<TranslationResult> {
    guard self.translationMatches.isEmpty == false else {
      let emptyResult = TranslationResult(translations: [], translationErrors: [])
      return self.client.eventLoop.future(emptyResult)
    }
    return try self.requestTranslations(forMatches: self.translationMatches)
      .map() { listRequest in
        var missingTranslations: TranslationErrors = []
        let namedTranslationsResponse = listRequest.translations.map { translation in return String(translation.translationID) }
        // Iterate through matches and check if they are in the response
        for translationMatch in self.translationMatches {
          if !namedTranslationsResponse.contains(translationMatch) {
            missingTranslations.append(TranslationError(missingTranslation: translationMatch))
          }
        }
        return TranslationResult(translations: listRequest.translations, translationErrors: missingTranslations)
    }
  }
  
  /// Interacts with the Translation Service to retrieve translations
  /// You probably want to use requestTranslations()
  func requestTranslations(forMatches matches: [String]) throws -> EventLoopFuture<TranslationListResponse> {
    let host = Environment.get("TRANSLATION_APP_HOST") ?? "http://0.0.0.0:6789"
    let user = Environment.get("TRANSLATION_APP_USER") ?? "translation"
    let password = Environment.get("TRANSLATION_APP_PASSWORD") ?? "pass"
    let b64Login = Data("\(user):\(password)".utf8).base64EncodedString(options: [])
    let url = "\(host)/api/translations/list"
    return client.post(URI(string: url), headers: ["Authorization" : "Basic \(b64Login)"]) { post in
      //let translationListRequest = TranslationListRequest(translations: matches.joined(separator: ","))
      let translationListRequest = TranslationListRequest(translations: matches)
      return try post.content.encode(translationListRequest)
    }.flatMapThrowing { response -> TranslationListResponse in
      guard response.status == .ok else {
        print("Error from TranslationService: \(response.status)")
        throw Connection(.failed, service: .translationService, statusCode: response.status)
      }
      return try response.content.decode(TranslationListResponse.self)
    }
  }
  
  /// Uses the translations we got back from the Translation Service to localize
  func localize(_ renderedTemplates: String, withTranslations translations: [Translation], locale: String) -> String {
    var localizedTemplates = renderedTemplates
    for translation in translations {
      let translatedText = self.translation(translation, forLocale: locale)
      if translatedText.contains("\n") {
        // translatedText = translatedText.markdown // Only when its clearly a text, e.g. not product-ids
      }
      localizedTemplates = localizedTemplates.replacingOccurrences(
        of: "loc::\(translation.translationID)",
        with: translatedText)
    }
    return localizedTemplates
  }
  
  
  /// Mode is for locale fallback
  func translation(_ translation: Translation, forLocale locale: String) -> String {
    do {
      return try getLocale(forLocale: locale, translation: translation)
    }
      /// Didnt work, lets see if its default
    catch {
      if locale == "default" { // Deepest level, return nothing
        return ""
      }
      /// if its on language level not found, try default
      if locale.count == 2 {
        do {
          return try getLocale(forLocale: "default", translation: translation)
        }
        catch {
          return ""
        }
      }
      /// If its site level, try language, then default
      if locale.count == 5 {
        do {
          let regex = try NSRegularExpression(pattern: "[a-z]{2}")
          guard let match = regex.firstMatch(in: locale, options: .reportCompletion, range: NSMakeRange(0, locale.count)) else {
            return ""
          }
          guard let matchRange = Range(match.range, in: locale) else {
            return ""
          }
          let languageLocale = String(locale[matchRange])
          return try getLocale(forLocale: languageLocale, translation: translation)
        }
        catch {
          do {
            return try getLocale(forLocale: "default", translation: translation)
          }
          catch {
            return ""
          }
        }
      }
      return ""
    }
  }
  
  
  /// Try to get a valid value back from a translation
  func getLocale(forLocale locale: String, translation: Translation) throws -> String {
    let translationLocalizedValue = translation.body[locale]
    guard let translationString = translationLocalizedValue else {
      throw TranslationError(missingTranslation: String(translation.translationID))
    }
    /// Quick fix to fall back if a translation exists, but is an empty String
    if translationString.count == 0 {
      throw TranslationError(reason: "Translation string found but empty")
    }
    return translationString
  }
  
  
}

