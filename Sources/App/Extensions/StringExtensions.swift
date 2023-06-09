//
//  StringExtensions.swift
//  App
//
//  Created by Benjamin Nassler on 02/06/2019.
//

import Foundation

extension String {
  
  func remove(regex: String) -> String {
    do {
      let regex = try NSRegularExpression(pattern: regex, options: [.useUnixLineSeparators]) // .CaseInsensitive
      return regex.stringByReplacingMatches(in: self, options: .reportProgress, range: NSRange(self.startIndex..., in: self), withTemplate: "")
    }
    catch {
      return self
    }
  }
  
  /**
   Removes `<mvmpublish>` tags
   */
  var strippedForPreview: String {
    get {
      self.remove(regex: #"<mvmpublish([^<]+)<\/mvmpublish>"#)
    }
  }
  /**
   Removes `<mvmpreview>` tags
   */
  var strippedForPublishing: String {
    get {
      self.remove(regex: #"<mvmpreview([^<]+)<\/mvmpreview>"#)
    }
  }
}
