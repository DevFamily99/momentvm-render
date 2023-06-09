//
//  RegexStringExtensions.swift
//  App
//
//  Created by Benjamin Nassler on 06.05.18.
//

import Foundation

// MARK: - General convenience methods -

extension String {
  
  
  /// Return all matches for a given pattern. Return the first match of the capture group for the pattern.
  func matches(forPattern pattern: String, captureGroup: Int) throws -> [String] {
    let regex = try NSRegularExpression(pattern: pattern) // .CaseInsensitive
    let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
    return try matches.map { match in
      // let wholeMatch = String(self[Range(match.range, in: self)!])
      // let subMatch = self[Range(match.range(at: captureGroup), in: self)!]
      let subMatchRangeOptional = Range(match.range(at: captureGroup), in: self)
      if let subMatchRange = subMatchRangeOptional {
        return String(self[subMatchRange])
      } else {
        throw RegexError(.invalidRange)
      }
    }
  }
  
  
  
  /// Searches a text string for DynamicImage markup.
  /// Markup is: dynamicimage::large:image_name::
  /// Returns only unique matches
  func markerMatches() throws -> [String] {
    let regex = try NSRegularExpression(pattern: #"<mvmrender([^<]+)<\/mvmrender>"#, options: [.useUnixLineSeparators]) // .CaseInsensitive
    let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
    let _: [String] = []
    for match in matches {
      guard
        let wholeMatchRange = Range(match.range, in: self),
        let imageSizeNameRange = Range(match.range(at: 1), in: self)
        //let imageNameRange = Range(match.range(at: 2), in: self)
        else {
          throw RegexError(.invalidRange)
      }
      let wholeMatch = String(self[wholeMatchRange])
      /// Fix empty match
      if wholeMatch.contains(":::") {
        continue
      }
      let _ = String(self[imageSizeNameRange])
      // let imageName = String(self[imageNameRange])
      // let dynamicImage = DynamicImageMatch(name: imageName, rawMatch: wholeMatch, variantName: imageSizeName)
//      if (dynamicImageMatches.contains { $0.name == imageName && $0.variantName == imageSizeName }) {
//        // Duplicate match
//      } else {
//        dynamicImageMatches.append(dynamicImage)
//      }
    }
    return []
  }
  
  
  /// Searches a text string for DynamicImage markup.
  /// Markup is: dynamicimage::large:image_name::
  /// Returns only unique matches
  func dynamicImageMatches() throws -> DynamicImageMatches {
    let regex = try NSRegularExpression(pattern: "dynamicimage::([^:].*?):([^:].*?)::") // .CaseInsensitive
    let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
    var dynamicImageMatches: DynamicImageMatches = []
    for match in matches {
      guard
        let wholeMatchRange = Range(match.range, in: self),
        let imageSizeNameRange = Range(match.range(at: 1), in: self),
        let imageNameRange = Range(match.range(at: 2), in: self) else {
          throw RegexError(.invalidRange)
      }
      let wholeMatch = String(self[wholeMatchRange])
      /// Fix empty match
      if wholeMatch.contains(":::") {
        continue
      }
      let imageSizeName = String(self[imageSizeNameRange])
      let imageName = String(self[imageNameRange])
      let dynamicImage = DynamicImageMatch(name: imageName, rawMatch: wholeMatch, variantName: imageSizeName)
      if (dynamicImageMatches.contains { $0.name == imageName && $0.variantName == imageSizeName }) {
        // Duplicate match
      } else {
        dynamicImageMatches.append(dynamicImage)
      }
    }
    return dynamicImageMatches
  }

  
  // MARK: - OLD -
  
  /// <script src="cms_assets/tiny-slider.js?$staticlink$"></script>
  func replace(pattern: String, closure: (String) -> String) throws -> String {
    var outputString = ""
    let regexLiteral = "<script.src..(.*?)\\?.*?script>"
    let stagingURL = "https://staging-web-stokke.demandware.net/on/demandware.static/-/Library-Sites-StokkeSharedLibrary/default/"
    let regex = try NSRegularExpression(pattern: regexLiteral) // .CaseInsensitive
    let _ = regex.matches(in: self, options: .withoutAnchoringBounds ,range: NSRange(self.startIndex..., in: self))
    outputString = regex.stringByReplacingMatches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count), withTemplate: "\(stagingURL)$1")
    return outputString
  }
  
  
  /// Returns matches from regex
  func regexMatches(for regex: String) -> [String] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let resultMatches = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
      var results: [String] = []
      for resultMatch in resultMatches {
        if let range = Range(resultMatch.range, in: self) {
          results.append(String(self[range]))
        } else {
          continue
        }
      }
      return results
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
  
  
}
